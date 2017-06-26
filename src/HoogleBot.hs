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
    (_, stdout, _, _) <- runInteractiveProcess  "stack" (searchWords (T.unpack target)) Nothing Nothing
    seeearched <- hGetContents stdout
    return $ T.pack seeearched

searchWords :: String -> [String]
searchWords target = ["exec", "hoogle"] ++ words target ++ ["--", "--count=30"]
