module HoogleBot where

import Control.Monad.IO.Class
import Web.Slack
import Web.Slack.Message
import System.IO
import System.Process
import qualified Data.Text as T

myConfig :: String -> SlackConfig
myConfig apiToken = SlackConfig
         { _slackApiToken = apiToken -- Specify your API token here
         }

hoogleBot :: SlackBot ()
hoogleBot (Message cid _ message _ _ _)
  | match == T.pack "hoogle " && not (T.null target) = send cid target
  where
    (match, target) = T.breakOnEnd (T.pack "hoogle ") message
hoogleBot _ = return ()

send :: ChannelId -> T.Text -> Slack s ()
send cid target =
  (sendMessage cid =<<) . liftIO $ do
    (_, out, _, _) <- runInteractiveCommand str
    seeearched <- System.IO.hGetContents out
    return $ T.pack seeearched
  where
    str = searchWords $ T.unpack target

searchWords :: String -> String
searchWords target = "stack exec hoogle '" ++ escapeReplace target ++ "'"

escapeReplace :: String -> String
escapeReplace "" = ""
escapeReplace ('&' : rest) = case rest of
                               "" -> "$"
                               [s] -> s : ""
                               ('l' : 't' : ';' : xss) -> "<" ++ escapeReplace xss
                               ('g' : 't' : ';' : xss) -> ">" ++ escapeReplace xss
                               ('a' : 'm' : 'p' : ';' : xss) -> "&" ++ escapeReplace xss
                               _ -> '&' : escapeReplace rest
escapeReplace (x:xs) = x : escapeReplace xs
