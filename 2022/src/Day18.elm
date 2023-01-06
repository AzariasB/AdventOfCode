module Day18 exposing (part1, part2)

import Dict exposing (Dict)
import Helpers
import Parser exposing ((|.), (|=), Parser, int, succeed, symbol)
import ParserHelpers exposing (runOnList)
import Set exposing (Set)


type alias Cube =
    ( Int, Int, Int )


type alias Store =
    Dict Cube Cube


type alias Checked =
    Dict Cube Int


type alias Bounds =
    ( Cube, Cube )



-- SOLUTION


part1 : List String -> String
part1 cubes =
    let
        allCubes =
            cubes |> runOnList cubeParser

        store =
            allCubes |> List.map singleton |> Dict.fromList
    in
    allCubes
        |> List.map (countFreeSides store)
        |> List.sum
        |> String.fromInt



-- 560 too low


part2 : List String -> String
part2 cubes =
    cubes
        |> runOnList cubeParser
        |> externalFreeSides
        |> String.fromInt


externalFreeSides : List Cube -> Int
externalFreeSides cubes =
    let
        store =
            cubes |> List.map singleton |> Dict.fromList

        bounds =
            cubes |> limits |> Debug.log "limits are "
    in
    floodFill bounds Set.empty store [ ( 0, 0, 0 ) ]


floodFill : Bounds -> Set Cube -> Store -> List Cube -> Int
floodFill bounds visited filled queue =
    case queue of
        [] ->
            0

        x :: xs ->
            let
                nwVisited =
                    Set.insert x visited
            in
            if (not <| inBounds bounds x) || Set.member x visited then
                floodFill bounds nwVisited filled xs

            else if Dict.member x filled then
                1 + floodFill bounds visited filled xs

            else
                floodFill bounds nwVisited filled (xs ++ faces x)


inBounds : Bounds -> Cube -> Bool
inBounds ( ( minX, minY, minZ ), ( maxX, maxY, maxZ ) ) ( x, y, z ) =
    x >= minX && x <= maxX && y >= minY && y <= maxY && z >= minZ && z <= maxZ


limits : List Cube -> Bounds
limits cubes =
    case cubes of
        [] ->
            ( ( 100, 100, 100 ), ( 0, 0, 0 ) )

        ( x, y, z ) :: xs ->
            let
                ( ( minX, minY, minZ ), ( maxX, maxY, maxZ ) ) =
                    limits xs
            in
            ( ( min (x - 1) minX, min (y - 1) minY, min (z - 1) minZ )
            , ( max (x + 1) maxX, max (y + 1) maxY, max (z + 1) maxZ )
            )


countFreeSides : Store -> Cube -> Int
countFreeSides store cube =
    cube
        |> faces
        |> List.filter (\c -> not <| Dict.member c store)
        |> List.length


faces : Cube -> List Cube
faces ( x, y, z ) =
    [ ( x - 1, y, z )
    , ( x + 1, y, z )
    , ( x, y - 1, z )
    , ( x, y + 1, z )
    , ( x, y, z - 1 )
    , ( x, y, z + 1 )
    ]


singleton : a -> ( a, a )
singleton x =
    ( x, x )


triple : Int -> Int -> Int -> Cube
triple x y z =
    ( x, y, z )


cubeParser : Parser Cube
cubeParser =
    succeed triple
        |= int
        |. symbol ","
        |= int
        |. symbol ","
        |= int



-- RUN


main =
    Helpers.solve part1 part2
