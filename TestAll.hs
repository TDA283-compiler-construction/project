-- | Contains the top level test runner for the test suite.
--   This module is responsible for setting up the test environment,
--   dispatching tests to "KompTest", and printing the test summary.
module TestAll where
import RunCommand
import KompTest hiding (name, run)

import Data.Char (toLower)
import Data.List
import System.Directory
import System.FilePath
import Control.Monad

data Extension
  = Arrays1  -- Single-dimensional arrays
  | Arrays2  -- Multi-dimensional arrays
  | Objects1 -- Static objects
  | Objects2 -- Objects with inheritance
  | Pointers -- Structs
    deriving (Show, Eq, Enum)

-- | The name of the extension as used in project description and test suite.
extName :: Extension -> String
extName = map toLower . show

-- | Run a shell command, then print its stdout and stderr.
run :: String -> IO ()
run c = do
  putStrLn c
  (out,err,_) <- runCommandStrWait c ""
  putStrLn out
  putStrLn err

-- | Unpack and build a submission, if any.
maybeBuild :: FilePath             -- ^ Submission root directory.
           -> [(String, FilePath)] -- ^ Flags to tar + name of archive.
           -> IO ()
maybeBuild _ [] = return ()
maybeBuild groupPath0 ((tarOpt,subm) : _) = do
   run $ "tar -C "++groupPath0 ++" -"++ tarOpt++"xvf "++ show (groupPath0 </> subm)
   run $ "make -C " ++ show (groupPath0 </> "src")

-- | Run all applicable tests.
testAll :: FilePath      -- ^ Path to the jlc compiler binary
        -> Maybe (FilePath -> TestFunction) -- ^ Backend to test, if any
        -> [Extension]   -- ^ List of extensions to test
        -> FilePath      -- ^ Test suite root directory
        -> FilePath      -- ^ Submission root directory
        -> IO ()
testAll compiler testProg exts testSuitePath00 groupPath0 = do
  allFiles <- getDirectoryContents groupPath0
  let submissions = [ (opts, s)
                    | (opts, suff) <- [ ("z", ".tar.gz")
                                      , ("j", ".tar.bz2")
                                      , ("j", ".tar.bzip2")
                                      , ("", ".tar")
                                      ]
                    , s <- filter (suff `isSuffixOf`) allFiles
                    ]
  maybeBuild groupPath0 submissions
  let testSuitePath0 = groupPath0 </> "graderTestSuite"
  run $ "rm -r " ++ testSuitePath0
  run $ "cp -R " ++ testSuitePath00 ++ " " ++ testSuitePath0
  let exePath0 = groupPath0 </> compiler

  exePath <- makeAbsolute exePath0
  groupPath <- makeAbsolute groupPath0
 
  testSuitePath <- makeAbsolute testSuitePath0
  curDir <- getCurrentDirectory
  let exeDir = takeDirectory exePath

  exeExists <- doesFileExist exePath
  when (not exeExists) $ error "jlc executable does not exist"

  putStrLn $ "Running tests for " ++ exePath
  let libpath = groupPath </> "lib"
  setCurrentDirectory exeDir
  summary <- forM (testSpecs testProg exts libpath) $ \(points, name, tests) -> do
    putStrLn $ name ++ "..."
    results <- forM tests $ \(good, p, testFunction) -> do
        testFiles <- getTestFilesForPath (testSuitePath </> p)
        putStrLn $ p ++ "..."
        rs <- testFunction exePath good testFiles
        report p rs 
        return (p, rs)
    putStrLn $ "Passed suites: " ++ (concat $ intersperse ", " $ [p | (p,rs) <- results, and rs])
    let tally = concat (map snd results)
    return (name, if and tally then points else (0 :: Int), tally)

  setCurrentDirectory curDir

  putStrLn $ "Summary:\n" ++ unlines (map summaryLine summary)
  putStrLn $ "Credits total: " ++ show (sum [x | (_,x,_) <- summary])

-- | Left pad a string with @n@ spaces.
padl :: Int -> String -> String
padl n s = replicate (n - length s) ' ' ++ s

-- | Format a line of the grading summary.
summaryLine :: (String, Int, [Bool]) -> String
summaryLine (name, points, tests) = unwords
  [ padl 2 (show points)
  , name
  , "(" ++ show (length (filter id tests)) ++ "/" ++ show (length tests) ++ ")"
  ]

-- | Run all enabled tests
testSpecs :: Maybe (FilePath -> TestFunction)
          -> [Extension]
          -> FilePath
          -> [(Int, String, [(Bool, String, TestFunction)])]
testSpecs testProg exts libpath =
    concat [coreComp, extComp, coreCG testProg, extCG testProg]
  where
    -- Core compilation tests
    coreComp =
      [( 0
      ,  "Compiling core programs"
      ,  [(True, "good",testCompilation), (False, "bad", testCompilation)]
      )]

    -- Extension compilation tests
    extComp = flip map exts $ \x ->
      (0, "Compiling extension " ++ extName x, [( True
                                             , "extensions" </> extName x
                                             , testCompilation)])

    -- Core codegen tests
    coreCG Nothing        = []
    coreCG (Just backEnd) =
      [(0, "Running core programs", [(True, "good", backEnd libpath)])]

    -- Extension codegen tests
    extCG Nothing        = []
    extCG (Just backEnd) = flip map exts $ \x ->
      (1, "Running extension " ++ extName x, [( True
                                           , "extensions" </> extName x
                                           , backEnd libpath)])

-- | Backend tests ignore the compiler binary and instead assume that the
--   intermediate files for each test are already generated.
testBack :: Backend -> TestFunction
testBack back _cmd good fs = if good then test fs back else return []

testLLVM :: [String] -> String -> FilePath -> TestFunction
testLLVM gccflags llvmversion libpath =
  testBack (llvmBackend gccflags llvmversion libpath)

testx86 :: [String] -> X86ABI -> FilePath -> TestFunction
testx86 gccflags abi libpath = testBack (x86Backend gccflags abi libpath)

testCustom :: FilePath -> FilePath -> TestFunction
testCustom jlc libpath = testBack (customBackend jlc libpath)
