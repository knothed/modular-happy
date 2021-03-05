module Frontend (parseYFile, Grammar(..)) where
  
import Grammar
import GHC.Base
import Data.List
import Parser
import ParseMonad
import System.IO
import System.Environment
import System.Exit (exitWith, ExitCode(..))

parseYFile :: String -> IO Grammar
parseYFile fl_name = do
  file' <- readFile fl_name
  (file, _) <- possDelit (reverse fl_name) file'

  abssyn <- case runP ourParser file 1 of
    Left err -> die (fl_name ++ ':' : err)
    Right abssyn -> return abssyn

  g <- case {-# SCC "Mangler" #-} (mangler fl_name abssyn) of
    Left  s -> die (unlines s ++ "\n")
    Right g -> return g

  return g
  
-- Delit
possDelit :: String -> String -> IO (String,String)
possDelit ('y':'l':'.':nm) fl = return (deLitify fl,reverse nm)
possDelit ('y':'.':nm) fl     = return (fl,reverse nm)
possDelit f            _      =
      dieHappy ("`" ++ reverse f ++ "' does not end in `.y' or `.ly'\n")

deLitify :: String -> String
deLitify = deLit
 where
      deLit ('>':' ':r)  = deLit1 r
      deLit ('>':'\t':r)  = '\t' : deLit1 r
      deLit ('>':'\n':r)  = deLit r
      deLit ('>':_)  = error "Error when de-litify-ing"
      deLit ('\n':r) = '\n' : deLit r
      deLit r        = deLit2 r
      deLit1 ('\n':r) = '\n' : deLit r
      deLit1 (c:r)    = c : deLit1 r
      deLit1 []       = []
      deLit2 ('\n':r) = '\n' : deLit r
      deLit2 (_:r)    = deLit2 r
      deLit2 []       = []


-- Die
die :: String -> IO a
die s = hPutStr stderr s >> exitWith (ExitFailure 1)

dieHappy :: String -> IO a
dieHappy s = getProgramName >>= \prog -> die (prog ++ ": " ++ s)

getProgramName :: IO String
getProgramName = liftM (`withoutSuffix` ".bin") getProgName
   where str' `withoutSuffix` suff
            | suff `isSuffixOf` str' = take (length str' - length suff) str'
            | otherwise              = str'