module Day1 exposing (part1, part2)

import Helpers



-- SOLUTION


part1 : List String -> String
part1 calories =
    calories
        |> Helpers.toInts
        |> split 0
        |> topNSum 1
        |> String.fromInt


maxSum : Int -> List Int -> Int
maxSum current xs =
    case xs of
        [] ->
            current

        0 :: rest ->
            max current (maxSum 0 rest)

        a :: rest ->
            maxSum (current + a) rest


part2 : List String -> String
part2 calories =
    calories
        |> Helpers.toInts
        |> split 0
        |> topNSum 3
        |> String.fromInt


split : Int -> List Int -> List Int
split current xs =
    case xs of
        [] ->
            [ current ]

        0 :: rest ->
            current :: split 0 rest

        a :: rest ->
            split (current + a) rest


topNSum : Int -> List Int -> Int
topNSum top sums =
    let
        sorted =
            List.reverse <| List.sort sums
    in
    List.sum <| List.take top sorted



-- RUN


main =
    Helpers.solve part1 part2
