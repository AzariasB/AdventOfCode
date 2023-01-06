module Day25 exposing (part1, part2)

import Helpers
import Parser exposing ((|.), Parser, oneOf, succeed, symbol)
import ParserHelpers exposing (runOnList)



-- SOLUTION
-- not 1-121==101=--=0


part1 : List String -> String
part1 inputs =
    inputs
        |> List.map (String.toList >> List.map String.fromChar >> runOnList snafuParser >> snafuToDecimal)
        |> List.sum
        |> decimalToSnafu


part2 : List String -> String
part2 _ =
    "TODO"


decimalToSnafu : Int -> String
decimalToSnafu value =
    let
        remains =
            modBy 5 value

        remove =
            if remains >= 3 then
                mIDiv (value + (5 - remains)) 5

            else
                mIDiv (value - remains) 5

        sym =
            toSnafu remains
    in
    if remove == 0 then
        sym

    else
        decimalToSnafu remove ++ sym


toSnafu : Int -> String
toSnafu val =
    case val of
        0 ->
            "0"

        1 ->
            "1"

        2 ->
            "2"

        3 ->
            "="

        _ ->
            "-"


snafuToDecimal : List Int -> Int
snafuToDecimal values =
    values |> List.reverse |> List.indexedMap (\i a -> a * (5 ^ i)) |> List.sum


snafuParser : Parser Int
snafuParser =
    oneOf
        [ succeed -2 |. symbol "="
        , succeed -1 |. symbol "-"
        , succeed 0 |. symbol "0"
        , succeed 1 |. symbol "1"
        , succeed 2 |. symbol "2"
        ]


mIDiv : Int -> Int -> Int
mIDiv x y =
    floor (toFloat x / toFloat y)



-- RUN


main =
    Helpers.solve part1 part2
