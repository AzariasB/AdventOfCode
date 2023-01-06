module Day20 exposing (part1, part2)

import Helpers
import List.Extra exposing (elemIndex, findIndex, getAt, removeAt, splitAt)
import ParserHelpers exposing (betterInt, runOnList)



-- STRUCTS


type alias File =
    List ( Int, Int )



-- SOLUTION


part1 : List String -> String
part1 file =
    file
        |> runOnList betterInt
        |> List.indexedMap Tuple.pair
        |> performMoves 1
        |> List.map Tuple.second
        |> coordinatesFinder
        |> String.fromInt


part2 : List String -> String
part2 file =
    file
        |> runOnList betterInt
        |> List.indexedMap Tuple.pair
        |> List.map (Tuple.mapSecond ((*) 811589153))
        |> performMoves 10
        |> List.map Tuple.second
        |> coordinatesFinder
        |> String.fromInt


coordinatesFinder : List Int -> Int
coordinatesFinder xs =
    let
        zeroIdx =
            elemIndex 0 xs |> Maybe.withDefault 0

        wrap a =
            modBy (List.length xs) (a + zeroIdx)

        first =
            getAt (wrap 1000) xs |> Maybe.withDefault 0

        second =
            getAt (wrap 2000) xs |> Maybe.withDefault 0

        third =
            getAt (wrap 3000) xs |> Maybe.withDefault 0
    in
    first + second + third


performMoves : Int -> File -> File
performMoves rounds xs =
    if rounds <= 0 then
        xs

    else
        performMovesHelper 0 xs
            |> performMoves (rounds - 1)


performMovesHelper : Int -> File -> File
performMovesHelper idx xs =
    if idx >= List.length xs then
        xs

    else
        let
            nwFile =
                doSwap idx xs
        in
        performMovesHelper (idx + 1) nwFile


doSwap : Int -> File -> File
doSwap x xs =
    let
        realIndex =
            findIndex (Tuple.first >> (==) x) xs |> Maybe.withDefault 0

        ( origIndex, val ) =
            getAt realIndex xs |> Maybe.withDefault ( 0, 0 )

        move =
            modBy (List.length xs - 1) (realIndex + val)
    in
    if val == 0 then
        xs

    else
        removeAt realIndex xs |> insertAt move ( origIndex, val )


insertAt : Int -> a -> List a -> List a
insertAt idx x xs =
    if idx == 0 then
        xs ++ [ x ]

    else
        let
            ( left, right ) =
                splitAt idx xs
        in
        left ++ [ x ] ++ right



-- RUN


main =
    Helpers.solve part1 part2
