-- | Entry point of the test suite.
--   This module is responsible for parsing and validating command line
--   arguments.
module Main where
import TestAll
import RunCommand
import KompTest (underline, normal, bold, X86ABI (..), TestFunction)

import Data.List
import Data.Maybe
import System.Environment
import System.Exit
import System.IO
import Control.Exception
import Control.Monad
import System.Console.GetOpt
import System.FilePath
import System.Directory

-- | Workaround to be able to derive equality for 'Flag'.
newtype BackTest = BackTest ([Flag] -> FilePath -> TestFunction)
instance Eq BackTest where _ == _ = False

data Flag
  = SearchScript String
  | Extension    Extension
  | Back         BackTest
  | LLVMVersion  String
  | TestSuiteDir FilePath
  | GCCFlag      String
  | KeepTemp
  | PrintHelp
  | Error        String
    deriving Eq

flags :: [OptDescr Flag]
flags =
    [ Option "s" ["search-compiler"] (ReqArg SearchScript "<compiler>")
      "search for the specified compiler"
    , Option "x" ["extension"] (ReqArg extension "<extension>")
      "specify extensions to test; may be given multiple times"
    , Option "b" ["backend"] (ReqArg backend "<backend>") $
      "specify backend"
    , Option "l" ["llvm-version"] (ReqArg LLVMVersion "<version>")
      "specify LLVM version; only applicable to `-b LLVM'"
    , Option "t" ["testsuite"] (ReqArg TestSuiteDir "<dir>")
      "look for the suite of test programs in <dir>"
    , Option "k" ["keep-tempdir"] (NoArg KeepTemp)
      "don't remove temporary directories, if any"
    , Option "h?" ["help"] (NoArg PrintHelp)
      "print this message and exit"
    , Option "g" ["gcc-flag"] (ReqArg GCCFlag "<flag>")
      "print this message and exit"
    ]

-- | Read an extension flag from a string. Gives back an error flag if the
--   string didn't match any known extensions.
extension :: String -> Flag
extension str =
  head $ [Extension ext | ext <- [Arrays1 ..], extName ext == str] ++
         [Error $ "no such extension: " ++ str]

-- | Read a backend from a string. Gives back an error flag if the string
--   didn't match any known backends.
backend :: String -> Flag
backend "LLVM"   = Back $ BackTest $ \opts ->
  testLLVM ([f | GCCFlag f <- opts]) (last $ "" : ['-':v | LLVMVersion v <- opts])
backend "x86" = Back $ BackTest $ \opts ->
  testx86 [f | GCCFlag f <- opts] X86
backend "x86_64" = Back $ BackTest $ \opts ->
  testx86 [f | GCCFlag f <- opts] X86_64
backend "custom" = Back $ BackTest $ \opts ->
  testCustom $ last $ "jlc" : [s | SearchScript s <- opts]
backend b        = Error $ "unknown backend: " ++ b

helpMessage :: String -> String
helpMessage prog = init $ unlines
  [ bold ++ "DIT300/TDA283 compiler test suite" ++ normal
  , ""
  , bold ++ "usage: " ++ normal ++ prog ++ " [options] " ++
    underline ++ "submission" ++ normal
  , ""
  , "where " ++ underline ++ "submission" ++ normal ++
    " is the root directory of your submission " ++
    underline ++ "or" ++ normal ++ " a compressed tarball"
  , "containing your submission."
  , ""
  , "By default, the test suite looks for test programs in the `./testsuite' directory."
  , "If you are running the test suite from outside its root directory, you will need"
  , "to specify this directory yourself using the `-t' flag."
  , ""
  , bold ++ "Backends" ++ normal
  , "You may specify zero or more backends to test using the `-b' option."
  , "If no backend is specified, only parsing and type checking will be tested."
  , "If you specify a backend, it must be one of the following: LLVM, x86, x86_64,"
  , "custom."
  , ""
  , "For the LLVM, x86 and x86_64 backends, the test suite expects your compiler to"
  , "produce a file `foo.bc' (for LLVM) or `foo.o' (for x86 and x86_64) for each"
  , "file `foo.jl', in the " ++ underline ++ "same directory as the .jl file" ++ normal ++
    ". This object file should " ++ underline ++ "not" ++ normal
  , "be linked against your standard library, as the test suite performs this"
  , "linking itself."
  , "If the test suite is complaining about errors related to the linker"
  , "(/usr/bin/ld) when testing your backend, try passing the -no-pie GCC flag using the"
  , "-g option: `./Grade -g-no-pie ...'."
  , ""
  , "For the custom backend, the test suite expects your compiler to produce an"
  , "executable `a.out' in the " ++ underline ++ "current working directory" ++ normal ++ "."
  , "Your compiler is used for the whole compilation process, including linking."
  , "Note that your submission still needs to pass all tests with the LLVM backend;"
  , "the custom backend is " ++ underline ++ "only" ++ normal ++ " intended as a" ++
    " fallback for testing alternative code"
  , "generators."
  , ""
  , bold ++ "Extensions" ++ normal
  , "You may specify zero or more extensions to test using the `-x' option."
  , "The following extensions are supported:"
  , "  " ++ intercalate ", " (map extName [Arrays1 ..]) ++ "."
  , ""
  , bold ++ "Supported options" ++ normal
  ]

main :: IO ()
main = do
  prog <- getProgName
  argv <- getArgs
  case getOpt Permute flags argv of
    (opts,args,[]) -> do
      let compiler = last $ "jlc" : [s | SearchScript s <- opts]
          exts = [e | Extension e <- opts]
          errors = [e | Error e <- opts]
          backends = [b opts | Back (BackTest b) <- opts]
          tdirs = "." : [d | TestSuiteDir d <- opts]

      -- Should we just print a help message and quit?
      when (PrintHelp `elem` opts) $ do
        putStrLn $ usageInfo (helpMessage prog) flags
        exitSuccess

      -- Were there errors in the options?
      when (not $ null errors) $ do
        failWithHelpMsg prog $ unlines errors

      -- Were there too many backends?
      unless (length backends < 2) $ do
        failWithHelpMsg prog "at most one backend may be specified"

      -- Was there a submission directory?
      unless (length args == 1) $ do
        failWithHelpMsg prog "submission directory not specified"

      -- Can we find the Javalette test programs?
      ts <- filterM isTestSuite (tdirs ++ map (</> "testsuite") tdirs)
      when (null ts) $ do
        failWithHelpMsg prog $ concat
          [ "no test suite directory found; please specify one "
          , "with `-t <dir>'"
          ]
      testsuite <- makeAbsolute (head ts)

      -- If the file is a tarball, unpack, build and test in a temporary
      -- directory.
      istarball <- doesFileExist (head args)
      let test = testAll compiler (listToMaybe backends) exts testsuite
      if istarball
        then unpackBuildAndTest (KeepTemp `elem` opts) (head args) test
        else test (head args)
    (_,_,errs) -> do
      failWithHelpMsg prog (concat errs)
  where
    failWithHelpMsg prog err = do
      hPutStrLn stderr $ err ++ "\nsee `" ++ prog ++ " --help' for usage info"
      exitWith (ExitFailure 1)

    -- Test for some random files from the test suite; if all exist, this is
    -- probably a test suite.
    isTestSuite dir = do
      and <$> sequence
        [ doesDirectoryExist $ dir </> "good"
        , doesDirectoryExist $ dir </> "bad"
        ]

    -- Unpack a submitted archive, build it, and run the tests.
    unpackBuildAndTest keeptemp file test = do
      file' <- makeAbsolute file
      dir <- getCurrentDirectory
      withTempDir keeptemp "." $ \tmpdir -> do
        setCurrentDirectory tmpdir
        putStrLn $ "Unpacking " ++ file' ++ "..."
        unpack file'
        setCurrentDirectory dir
        normalize tmpdir
        putStrLn $ "Building..."
        res <- build tmpdir
        case res of
          (_, err, ExitFailure _) -> putStrLn $ "Build failed:\n" ++ err
          _                       -> test tmpdir

    -- Unpack a file of some archive format.
    unpack file = void $ do
      case takeExtension file of
        ".gz"  -> runCommandStrWait ("tar -xzf '" ++ file ++ "'") ""
        ".bz2" -> runCommandStrWait ("tar -xjf '" ++ file ++ "'") ""
        ".xz"  -> runCommandStrWait ("tar -xJf '" ++ file ++ "'") ""
        ".zip" -> runCommandStrWait ("unzip '" ++ file ++ "'") ""
        ".rar" -> runCommandStrWait ("unrar x '" ++ file ++ "'") ""

    -- Ensure that the src, lib, etc. directories are in the root of the
    -- submission.
    normalize dir = void $ do
      contents <- ls dir
      let childdir = dir </> head contents
      isdir <- doesDirectoryExist childdir
      when (isdir && length contents == 1) $ do
        childcontents <- ls childdir
        forM_ childcontents $ \f -> do
          let f' = childdir </> f
          isfile <- doesFileExist f'
          if isfile
            then renameFile f' (dir </> f)
            else renameDirectory f' (dir </> f)
        removeDirectory childdir
        normalize dir

    -- Build a submission residing in the given directory
    build dir = do
      olddir <- getCurrentDirectory
      setCurrentDirectory dir
      res <- runCommandStrWait "make -C src" ""
      setCurrentDirectory olddir
      return res

    -- Get the contents of the given directory, sans @.@ and @..@.
    ls dir = do
      contents <- getDirectoryContents dir
      pure [f | f <- contents, f /= ".", f /= ".."]

-- | Do something in a temporary directory that's optionally kept around.
withTempDir :: Bool -> FilePath -> (FilePath -> IO a) -> IO a
withTempDir keeptemp parent =
    bracket (mkTempDir parent) (unless keeptemp . removeDirectoryRecursive)

-- | Create a directory, in the given directory, with the name @tmpN@, where
--   @N@ is the lowest non-negative integer for which @tmpN@ does not alrady
--   exist.
mkTempDir :: FilePath -> IO FilePath
mkTempDir parent = go 0
  where
    go n = do
      dir' <- makeAbsolute $ parent </> "tmp" ++ show n
      nope <- or <$> sequence [doesFileExist dir', doesDirectoryExist dir']
      if nope
        then go (n+1)
        else createDirectory dir' >> return dir'
