{-# LANGUAGE OverloadedStrings #-}

module HoogleBot where

import Web.Slack
import Web.Slack.Message
import qualified Data.Text as T

myConfig :: String -> SlackConfig
myConfig apiToken = SlackConfig
         { _slackApiToken = apiToken -- Specify your API token here
         }

hoogleBot :: SlackBot ()
hoogleBot (Message cid _ message _ _ _)
  | match == T.pack "hoogle " && not (T.null suffix) = sendMessage cid suffix
  where
    (match, suffix) = T.breakOnEnd (T.pack "hoogle ") message
hoogleBot _ = return ()
