module Main where

import Web.Slack
import System.Environment (lookupEnv)
import Data.Maybe (fromMaybe)
import HoogleBot

main :: IO ()
main = do
  apiToken <- fromMaybe (error "SLACK_API_TOKEN not set")
               <$> lookupEnv "SLACK_API_TOKEN"
  runBot (myConfig apiToken) hoogleBot ()
