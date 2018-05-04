{-# OPTIONS_GHC -fno-warn-unused-do-bind #-}
-- GHC needs -threaded
module KompTest where

import Control.Monad
import Data.List
import System.Process
import System.Directory
import System.Exit
import System.IO
import System.FilePath
import System.IO.Temp (withTempFile)
import Data.Char
import RunCommand

-- | Program runner function for a backend: takes an object file, a source file,
--   a file to feed to the program's standard input, and a file containing its
--   expected standard output.
type BackendRunner = FilePath -> FilePath -> FilePath -> FilePath -> IO Bool

data Backend = Backend
  { name    :: String
  , objFile :: FilePath -> FilePath
  , run     :: BackendRunner
  }

--
-- * Error reporting and output checking
--

-- | Print an error message with the given color.
printErrorColor :: Color 
                -> String -- ^ command that failed
                -> String -- ^ how it failed
                -> FilePath -- ^ source file
                -> String -- ^ given input
                -> String -- ^ stdout output
                -> String -- ^ stderr output
                -> IO ()
printErrorColor col c m f i o e = do
  putStrLn $ color col $ c ++ " failed: " ++ m
  putStrLn $ "For source file " ++ f ++ ":"
  -- prFile f
  when (not (null i)) $ do
    putStrLn "Given this input:"
    putStrLn $ color blue $ i
  when (not (null o)) $ do
    putStrLn "It printed this to standard output:"
    putStrLn $ color blue $ o
  when (not (null e)) $ do
    putStrLn "It printed this to standard error:"
    putStrLn $ color blue $ e

-- | Print an error message.
printError :: String -- ^ command that failed
           -> String -- ^ how it failed
           -> FilePath -- ^ source file
           -> String -- ^ given input
           -> String -- ^ stdout output
           -> String -- ^ stderr output
           -> IO ()
printError = printErrorColor red

data ErrorReport = ErrorReport
  { repErr      :: String
  , repSeverity :: Severity
  , repCmd      :: String
  , repSrc      :: String
  , repStdIn    :: String
  , repStdOut   :: String
  , repStdErr   :: String
  }

data Severity = SWarning | SError | SInfo

defRep :: ErrorReport
defRep = ErrorReport
  { repErr      = "OK"
  , repSeverity = SInfo
  , repCmd      = ""
  , repSrc      = ""
  , repStdIn    = ""
  , repStdOut   = ""
  , repStdErr   = "" 
  }

-- | Turn an error report into an error or warning respectively.
(?!), (??) :: ErrorReport -> String -> ErrorReport
rep ?! msg = rep { repErr = msg, repSeverity = SError }
rep ?? msg = rep { repErr = msg, repSeverity = SWarning }

-- | Report an error. Returns @True@ if the error was just a notice, @False@
--   if it was a warning or an error.
reportError :: ErrorReport -> IO Bool
reportError er =
  case repSeverity er of
    SInfo ->
      return True
    _ -> do
      printError (repCmd er)
                 (repErr er)
                 (repSrc er)
                 (repStdIn er)
                 (repStdOut er)
                 (repStdErr er)
      return False

-- | Report an error, if any. Returns @True@ if there was no error to report.
reportMaybe :: Maybe ErrorReport -> IO Bool
reportMaybe = maybe (return True) reportError

-- | Print the contents of a file.
prFile :: FilePath -> IO ()
prFile f = do
  putStrLn $ "---------------- begin " ++ f ++ " ------------------" 
  s <- readFile f
  putStrLn $ color green s
  putStrLn $ "----------------- end " ++ f ++ " -------------------" 

-- | Report how many tests passed.
report :: String -> [Bool] -> IO ()
report n rs = 
  do let (p,t) = (length (filter id rs), length rs)
     putStrLn $ n ++ ": passed " ++ show p ++ " of " ++ show t ++ " tests"
--
-- * Generic running
--

runProg :: String -- ^ command
        -> FilePath -- ^ source file (for error reporting)
        -> FilePath -- ^ known input file
        -> FilePath -- ^ known output file
        -> IO Bool
runProg c f i o = do
  fe <- doesFileExist i
  input <- if fe then readFile i else return ""
  output <- readFile o
  (out,err,s) <- runCommandStrWait c input
  case s of
    ExitFailure x -> do
      printError c ("with status " ++ show x) f input out err
      return False
    ExitSuccess
      | not (null err) -> do
          printError c "Printed something to standard error" f input out err
          return False
      | output /= out -> do
          putStrLn $ color red $ c ++ " produced the wrong output:"
          putStrLn $ "For source file " ++ f ++ ":"
          prFile f
          when (not (null input)) $ do
            putStrLn "Given this input:"
            putStrLn $ color blue $ input
          putStrLn "It printed this to standard output:"
          putStrLn $ color blue $ out
          putStrLn "It should have printed this:"
          putStrLn $ color blue $ output
          return False
      | otherwise -> do
          putStrLn "output ok"
          return True

-- | Given a a list of source files and a backend, use the backend's runner to
--   test all source files. Assumes that the corresponding object file for each
--   source file already exists.
test :: [FilePath] -> Backend -> IO [Bool]
test fs b = do
  putStrLn $ color green $ "Backend: " ++ name b 
  mapM testProg fs
  where
    testProg f = do
      putStr $ "Testing " ++ takeFileName f ++ ": "
      hFlush stdout
      let n = dropExtension f
          o = n ++ ".output"
      let c = objFile b f
      ofe <- doesFileExist o
      if ofe then run b c f (n ++ ".input") o
         else do
              putStrLn $ color blue $ "skipping: " ++ o ++ " not found"
              return True


--
-- * Compilation
--

-- | A compiler test function: takes a compiler binary, a boolean indicating
--   whether the test is expected to pass, and a list of source files to test.
--   Returns a list of bools indicating for each test whether it passed or not.
type TestFunction = FilePath -> Bool -> [FilePath] -> IO [Bool]

-- | Takes a compiler command, a boolean indicating whether the tests are
--   expected to pass, and a list of source files. Returns a list of booleans
--   indicating for each test whether it behaved as expected (i.e.
--   failed/passed where supposed to).
testCompilation :: TestFunction
testCompilation c good fs = 
  do x <- doesFileExist c
     forM fs $ \t -> reportError =<< do
       if x then testCompilationProg c good t
            else return $ defRep {repCmd = c} ?! ("compiler " ++ c ++ " not found")

-- | Compile a test case and ensure that it passes/fails as expected.
testCompilationProg :: FilePath -> Bool -> FilePath -> IO ErrorReport
testCompilationProg path good f = do
  let c = path ++ " " ++ f
  putStrLn $ takeFileName path ++ " " ++ takeFileName f ++ "..."
  (out,err,_) <- runCommandStrWait c ""
  let rep = defRep {repCmd = f, repStdOut = out, repStdErr = err}
  lns <- return $ lines err
  return $ case filter (not . null) lns of 
    msgs | isOk    msgs -> if good
                             then rep
                             else rep ?! "passed BAD program" 
         | isError msgs -> if good
                             then rep ?! "failed OK program"
                             else rep
    _ -> rep ?! "invalid output"
  where
    isOk (s:_) | "OK" `isSuffixOf` tu s || "OK" `isPrefixOf` tu s = True
    isOk _ = False
    isError (s:_) | "ERROR" `isSuffixOf` tu s || "ERROR" `isPrefixOf` tu s = True
    isError ("Syntax Error, trying to recover and continue parse...":"ERROR":_) = True
    isError _ = False
    tu = map toUpper

--
-- * LLVM back-end
--
objFileLLVM :: FilePath -> FilePath
objFileLLVM f = dropExtension f <.> "bc"

linkLLVM :: [String] -- ^ Flags to pass to GCC
         -> String   -- ^ LLVM version
         -> FilePath -- ^ Library path (i.e. dir with runtime.bc)
         -> FilePath -- ^ .bc file to compile
         -> IO ()
linkLLVM gccflags ver libPath bcFile = do
  ec <- system "which llvm-ld"
  case ec of
    ExitSuccess -> linkLegacyLLVM
    _           -> linkModernLLVM
  where
    -- use llvm-ld if it exists...
    linkLegacyLLVM =
      void $ system $ unwords
        [ "llvm-ld", ver
        , bcFile
        , libPath </> runtimeBitcode
        ]

    -- ...otherwise use llvm-link + gcc
    linkModernLLVM = withTempFile "." "a.s" $ \file h -> void $ do
      hClose h
      system $ intercalate " | "
        [ "llvm-link" ++ ver ++ " " ++ bcFile ++ " " ++ libPath </> runtimeBitcode
        , "opt" ++ ver
        , "llc" ++ ver ++ " > " ++ file
        ]
      system ("gcc -oa.out " ++ intercalate " " gccflags ++ " " ++ file)

    -- bitcode file containing the runtime
    runtimeBitcode = "runtime.bc"


runLLVM :: [String] -- ^ Flags for GCC.
        -> String -- ^ LLVM version suffix
        -> String -- ^ libpath
        -> String -- ^ LLVM bitcode file
        -> FilePath -- ^ source file (for error reporting)
        -> FilePath -- ^ known input file
        -> FilePath -- ^ known output file
        -> IO Bool
runLLVM gccflags ver libPath bcFile src inp outp = do
  let dir = takeDirectory bcFile
  d0  <- System.Directory.getCurrentDirectory
  setCurrentDirectory dir
  withIntermediateFile bcFile src $ do
    killFile ("a.out")
    linkLLVM gccflags ver libPath bcFile
    result <- runProg "./a.out" src inp outp
    setCurrentDirectory d0
    return result

-- | Given an intermediate file, a source file and a computation, performs
--   the given computation iff the intermediate file exists.
--   Otherwise, reports a missing file error and returns @False@.
withIntermediateFile :: FilePath -> FilePath -> IO Bool -> IO Bool
withIntermediateFile f src m = do
  exists <- doesFileExist f
  if exists
    then m
    else reportMissingFile
  where
    reportMissingFile = do
      reportError $ (defRep ?! noFileError) {repSrc = src}
      return False
    noFileError = unwords
      [ "`" ++ takeFileName f ++ "'"
      , "not found in the same directory as the source file."
      ]

-- | Remove a file if it exists.
killFile :: FilePath -> IO ()
killFile f = do
  b <- doesFileExist f
  when b $ removeFile f

llvmBackend :: [String] -> String -> FilePath -> Backend
llvmBackend gccflags ver libpath = Backend
  { name = "LLVM"
  , objFile = objFileLLVM
  , run = runLLVM gccflags ver libpath
  }

--
-- * x86 back-end
--

-- | ABI for x86 backend
data X86ABI = X86 | X86_64
  deriving (Show, Eq)

objFilex86 :: FilePath -> FilePath
objFilex86 f = dropExtension f <.> "o"

runx86 :: [String] -- ^ Flags for GCC
       -> X86ABI   -- ^ 32 or 64 bit program?
       -> FilePath -- ^ Library path
       -> FilePath -- ^ Object file
       -> FilePath -- ^ Source file
       -> FilePath -- ^ stdin
       -> FilePath -- ^ stdout
       -> IO Bool
runx86 gccflags abi libPath oFile src inp outp = do
  let dir  = takeDirectory oFile
  d0  <- System.Directory.getCurrentDirectory
  setCurrentDirectory dir
  withIntermediateFile oFile src $ do
    killFile "a.out"
    system $ unwords
      [ "gcc"
      , unwords gccflags
      , unwords gccabi
      , oFile
      , libPath ++"/runtime.o"
      ]
    result <- runProg "./a.out" src inp outp
    setCurrentDirectory d0
    return result
  where
    gccabi
      | abi == X86 = ["-m32"]
      | otherwise  = ["-m64"]

x86Backend :: [String] -> X86ABI -> String -> Backend
x86Backend gccflags abi libpath = Backend
  { name = "x86"
  , objFile = objFilex86
  , run = runx86 gccflags abi libpath
  }

getTestFilesForPath :: String -> IO [String]
getTestFilesForPath f = do
  d <- doesDirectoryExist f
  if d then jlFiles f else do
    d' <- doesFileExist f
    if d' then return [f]
          else error $ "Not a file or directory: " ++ f

-- | Get all .jl files in the given directory.
jlFiles :: FilePath -> IO [FilePath]
jlFiles d = do
  fs <- getDirectoryContents d
  return $ map (d </>) $ sort $ filter ((".jl" ==) . takeExtension) fs


--
-- * Custom back-end
--
customBackend :: FilePath -> FilePath -> Backend
customBackend jlc lib = Backend
  { name = "custom"
  , objFile = const ""
  , run = runCustom jlc lib
  }


runCustom :: FilePath -- ^ jlc binary
          -> FilePath -- ^ Library path
          -> FilePath -- ^ Object file
          -> FilePath -- ^ Source file
          -> FilePath -- ^ stdin
          -> FilePath -- ^ stdout
          -> IO Bool
runCustom jlc _ _ src i o = do
  (_, _, code) <- runCommandStrWait (unwords ["." </> jlc, src]) ""
  exeExists <- doesFileExist "./a.out"
  if code == ExitSuccess && exeExists
    then runProg "./a.out" src i o
    else reportError ((defRep ?! missingAOut) {repSrc = src}) >> pure False
  where
    missingAOut = "a.out not written to current working directory"


--
-- * Terminal output colors
--

type Color = Int

color :: Color -> String -> String
color c s = fgcol c ++ s ++ normal

highlight, bold, underline, normal :: String
highlight = "\ESC[7m"
bold      = "\ESC[1m"
underline = "\ESC[4m"
normal    = "\ESC[0m"

fgcol, bgcol :: Color -> String
fgcol col = "\ESC[0" ++ show (30+col) ++ "m"
bgcol col = "\ESC[0" ++ show (40+col) ++ "m"

red, green, blue :: Color
red = 1
green = 2
blue = 4
