module MyLib (someFunc) where

someFunc :: IO ()
someFunc =
  putStrLn "hello from \'private\' repository"
