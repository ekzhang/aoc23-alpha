{-
It's not my first time using Haskell for sure, but this was really fun!

Particularly nice today was the way I could apply lazy evaluation to infinite
lists, and it would just work. The code actually executed pretty fast too,
despite all of the laziness.

Work became a lot easier when I got used to `mapM` and `mapM_`.

Haskell feels a little bit different, since I learn something new every time I
come back to it. It's an experience worth repeating many times.
-}

module Main where

import Control.Monad (void)
import Data.List (findIndex)
import Data.Map (Map, fromList, lookup)
import Text.Parsec (char, letter, many1, parse, string)
import Text.Parsec.String (Parser)

type Graph = Map String (String, String)

edgeE :: Parser (String, (String, String))
edgeE = do
  node <- many1 letter
  void $ string " = ("
  left <- many1 letter
  void $ string ", "
  right <- many1 letter
  void $ char ')'
  pure (node, (left, right))

parseLineOrExit :: String -> IO (String, (String, String))
parseLineOrExit s = case parse edgeE "<input>" s of
  Left pe -> error $ show pe
  Right tr -> pure tr

-- Move a specific sequence of steps from a starting point, stopping at "ZZZ".
move :: Graph -> String -> String -> String
move g = go
  where
    go :: String -> String -> String
    go node "" = node
    go "ZZZ" _ = "ZZZ"
    go node (c : rest) = case Data.Map.lookup node g of
      Nothing -> error $ "No node " <> node
      Just (left, right) -> case c of
        'L' -> go left rest
        'R' -> go right rest
        _ -> error $ "Invalid direction " <> [c]

-- Find the smallest non-negative integer that satisfies the predicate, repeatedly doubling.
binSearchInt :: (Int -> Bool) -> Int
binSearchInt p = go 1
  where
    go :: Int -> Int
    go n = if p n then search 0 n else go (2 * n)
    search :: Int -> Int -> Int
    search lo hi
      | lo == hi = lo
      | p mid = search lo mid
      | otherwise = search (mid + 1) hi
      where
        mid = (lo + hi) `div` 2

-- Return a list of nodes from moving from a starting point.
path :: Graph -> String -> String -> [String]
path _ node "" = [node]
path g node (c : rest) = node : path g next rest
  where
    next = case Data.Map.lookup node g of
      Nothing -> error $ "No node " <> node
      Just (left, right) -> case c of
        'L' -> left
        'R' -> right
        _ -> error $ "Invalid direction " <> [c]

isStart2 :: String -> Bool
isStart2 node = last node == 'A'

isFinal2 :: String -> Bool
isFinal2 node = last node == 'Z'

main :: IO ()
main = do
  directions <- getLine
  _ <- getLine
  inp <- getContents
  edges <- mapM parseLineOrExit $ lines inp
  let nodes = map fst edges
  let g = fromList edges

  -- Part 1
  print $ binSearchInt (\n -> move g "AAA" (take n $ cycle directions) == "ZZZ")

  -- Hmm, after inspection, it seems from printing out the actual valid indices that they're just
  -- integer multiples of the first valid index. So we can just take the LCM.

  {-
  mapM_ (go g directions) $ filter isStart2 nodes
  where
    go :: Graph -> String -> String -> IO ()
    go g directions node = do
      print node
      print $ take 100 $ findIndices isFinal2 $ path g node (cycle directions)
  -}

  -- Part 2
  let indices =
        map
          ( \node -> case findIndex isFinal2 $ path g node (cycle directions) of
              Nothing -> error $ "No path from " <> node
              Just n -> n
          )
          $ filter isStart2 nodes

  print $ foldl lcm 1 indices
