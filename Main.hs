module Main where

import Graphics.Gloss
import Graphics.Gloss.Interface.Pure.Simulate
import System.Random

genSize = 200
gensPerSec = 8
pathlength = 210
start = (-10,0)
target = (10,0)
hyperbolic = 5 -- how far up the plane

type Angle = Float
type DNA = [Angle]
type Generation = [DNA]
type World = (Generation, StdGen)

hypDistance :: Point -> Point -> Float
hypDistance (x1,y1) (x2,y2) = acosh $
                              1 + ((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))/(2 * (y1+hyperbolic) * (y2+hyperbolic))

euclDistance :: Point -> Point -> Float
euclDistance (x1,y1) (x2,y2) = sqrt ((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))

toPath :: DNA -> Path
toPath = foldl takeStep [start]
  where takeStep ((x,y):xs) angle = (x + stepsize * (cos angle),
                                     y + stepsize * (sin angle))
                                    : (x,y) : xs
          where stepsize = (y+hyperbolic)*(y+hyperbolic)*0.003

score :: DNA -> Float
score dna = 1 / hypDistance target (head $ toPath dna)

probabilities :: Generation -> [Float]
probabilities generation = map (\x -> score x / maxscore) generation
  where maxscore = maximum $ map score generation

matingPool :: Generation -> [DNA]
matingPool generation = concatMap (\(x,p)-> replicate (round (100*p)) x) $
                   zip generation (probabilities generation)

cross :: StdGen -> DNA -> DNA -> DNA
cross rgen [] _ = []
cross rgen _ [] = []
cross rgen (x:xs) (y:ys) = (if p > 0.5 then x else y) : cross g xs ys
  where (p,g) = randomR (0,1) rgen :: (Float, StdGen)

breed :: StdGen -> [DNA] -> (DNA, StdGen)
breed rgen pool = (cross g2 parent1 parent2, g2)
  where poolsize = length pool
        (index1, g1) = randomR (0, poolsize - 1) rgen
        (index2, g2) = randomR (0, poolsize - 1) g1
        parent1 = pool !! index1
        parent2 = pool !! index2

mutate :: (DNA, StdGen) -> (DNA, StdGen)
mutate ([], rgen) = ([], rgen)
mutate (x:xs, rgen) = (y:ys, g2)
  where (p,g1) = randomR (0,1) rgen :: (Float, StdGen)
        (ys, g2) = mutate (xs, g1)
        y = if p < 0.01 then fst $ randomR (0, 2*pi) g2 else x

populate :: [DNA] -> World -> World
populate pool (list, rgen)
  | length list < genSize = populate pool (child : list, g1)
  | otherwise = (list, rgen)
    where (child, g1) = mutate $ breed rgen pool

view :: World -> Picture
view (xs, _) = scale 15 15 $
               Pictures $
               line [(-500, 0 - hyperbolic) , (500, 0 - hyperbolic)] :
               uncurry translate start (circle 1) :
               uncurry translate target (circle 1) :
               map (line . toPath) xs

initial :: World
initial = let anglelist = take (genSize * pathlength) (randomRs (0, 2*pi) (mkStdGen 12))
              splitup xs = if length xs <= pathlength then [xs]
                           else take pathlength xs: splitup (drop pathlength xs)
          in (splitup anglelist, mkStdGen 10)

update :: ViewPort -> Float -> World -> World
update _ _ (generation, g) = populate (matingPool generation) ([], g)

window :: Display
window = FullScreen

main :: IO()
main = simulate window white gensPerSec initial view update
