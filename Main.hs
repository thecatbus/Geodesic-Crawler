module Main where

import Graphics.Gloss
import Graphics.Gloss.Interface.Pure.Simulate
import System.Random

genSize = 700
gensPerSec = 5
pathlength = 100
start = (0,0)
target = (30,0)

type Angle = Float
type DNA = [Angle]
type Generation = [DNA]
type World = (Generation, StdGen)

hypDistance :: Point -> Point -> Float
hypDistance (x1,y1) (x2,y2) = acosh $
                              1 + ((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))/(2 * (y1+10) * (y2+10))

euclDistance :: Point -> Point -> Float
euclDistance (x1,y1) (x2,y2) = sqrt ((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))

toPath :: DNA -> Path
toPath = foldl takeStep [start]
  where takeStep ((x,y):xs) angle = (x + 0.5 * (cos angle), -- / (0.0005 * (y + 20) * (y + 20))),
                                     y + 0.5 * (sin angle)) -- / (0.0005 * (y + 20) * (y + 20))))
                                    : (x,y) : xs

score :: DNA -> Float
score dna = 1 / euclDistance target (head $ toPath dna)


probabilities :: Generation -> [Float]
probabilities generation = map (\x -> score x / maxscore) generation
  where maxscore = maximum $ map score generation

matingPool :: Generation -> [DNA]
matingPool generation = concatMap (\(x,p)-> replicate (round (100*p)) x) $
                   zip generation (probabilities generation)

breed :: StdGen -> [DNA] -> (DNA, StdGen)
breed rgen pool = (cross parent1 parent2, g2)
  where poolsize = length pool
        (index1, g1) = randomR (0, poolsize - 1) rgen
        (index2, g2) = randomR (0, poolsize - 1) g1
        parent1 = pool !! index1
        parent2 = pool !! index2
        cross a b = take (floor (fromIntegral pathlength / 2)) a ++
                    drop (floor (fromIntegral pathlength / 2)) b

populate :: [DNA] -> World -> World
populate pool (list, rgen)
  | length list < genSize = populate pool (child : list, g1)
  | otherwise = (list, rgen)
    where (child, g1) = breed rgen pool

view :: World -> Picture
view (xs, _) = scale 15 15 $
               Pictures $
               uncurry translate start (circle 5) :
               uncurry translate target (circle 5) :
               map (line . toPath) xs

initial :: World
initial = let anglelist = take (genSize * pathlength) (randomRs (0, 2*pi) (mkStdGen 120))
              splitup xs = if length xs <= pathlength then [xs]
                           else take pathlength xs: splitup (drop pathlength xs)
          in (splitup anglelist, mkStdGen 102)

update :: ViewPort -> Float -> World -> World
update _ _ (generation, g) = populate (matingPool generation) ([], g)

window :: Display
window = FullScreen

main :: IO()
main = simulate window white gensPerSec initial view update
