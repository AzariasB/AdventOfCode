module Day4 exposing (part1, part2)

import Helpers
import Parser exposing ((|.), (|=), Parser, int, succeed, symbol)



-- STRUCTS


type alias Section =
    { aStart : Int, aEnd : Int, bStart : Int, bEnd : Int }



-- SOLUTION


part1 : List String -> String
part1 sections =
    sections
        |> List.map (toSection >> containsItself >> boolToInt)
        |> List.sum
        |> String.fromInt


part2 : List String -> String
part2 sections =
    sections
        |> List.map (toSection >> overlaps >> boolToInt)
        |> List.sum
        |> String.fromInt


rangeParser : Parser Section
rangeParser =
    succeed Section
        |= int
        |. symbol "-"
        |= int
        |. symbol ","
        |= int
        |. symbol "-"
        |= int


boolToInt : Bool -> Int
boolToInt b =
    if b then
        1

    else
        0


toSection : String -> Section
toSection str =
    case Parser.run rangeParser str of
        Ok section ->
            section

        Err _ ->
            Debug.todo <| "Failed to parse section " ++ str


containsItself : Section -> Bool
containsItself { aStart, aEnd, bStart, bEnd } =
    aStart >= bStart && aEnd <= bEnd || bStart >= aStart && bEnd <= aEnd


overlaps : Section -> Bool
overlaps { aStart, aEnd, bStart, bEnd } =
    aStart <= bStart && aEnd >= bStart || bStart <= aStart && bEnd >= aStart



-- RUN


main =
    Helpers.solve part1 part2
