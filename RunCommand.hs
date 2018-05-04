{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -fno-warn-unused-do-bind #-}
module RunCommand (runCommandStrWait) where
import Prelude hiding (fromLeft)
import System.Process
import System.Exit
import System.IO
import Control.Concurrent
import Data.Either hiding (fromLeft)

type Pipe = Chan (Either Char ())

pipeGetContents :: Pipe -> IO String
pipeGetContents p = do
  s <- getChanContents p
  return $ map fromLeft $ takeWhile isLeft s

pipeWrite :: Pipe -> String -> IO ()
pipeWrite p s = writeList2Chan p (map Left s)

-- close the pipe for writing
pipeClose :: Pipe -> IO ()
pipeClose p = writeChan p (Right ())


--
-- * Either utilities
--

fromLeft :: Either a b -> a
fromLeft =  either id (error "fromLeft: Right")

--
-- * Various versions of runCommand
--

runCommandChan :: String -- ^ command
              -> IO (Pipe,Pipe,Pipe,ProcessHandle) -- ^ stdin, stdout, stderr, process
runCommandChan c = do
  inC  <- newChan
  outC <- newChan
  errC <- newChan
  (pin,pout,perr,p) <- runInteractiveCommand c
  forkIO (pipeGetContents inC >>= hPutStr pin >> hClose pin)
  forkIO (hGetContents pout >>= pipeWrite outC >> pipeClose outC)
  forkIO (hGetContents perr >>= pipeWrite errC >> pipeClose errC)
  return (inC,outC,errC,p)

runCommandStr :: String -- ^ command
              -> String -- ^ stdin data
              -> IO (String,String,ProcessHandle) -- ^ stdout, stderr, process
runCommandStr c inStr = do
  (inC,outC,errC,p) <- runCommandChan c
  forkIO (pipeWrite inC inStr >> pipeClose inC)
  out <- pipeGetContents outC
  err <- pipeGetContents errC
  return (out,err,p)

runCommandStrWait :: String -- ^ command
                  -> String -- ^ stdin data
                  -> IO (String,String,ExitCode) -- ^ stdout, stderr, process exit status
runCommandStrWait c inStr = do
  (out,err,p) <- runCommandStr c inStr
  s <- waitForProcess p
  return (out,err,s)
