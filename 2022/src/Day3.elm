module Day3 exposing (part1, part2)

import Helpers
import Set



-- SOLUTION


part1 : List String -> String
part1 sacks =
    sacks
        |> List.map (splitInHalf >> commonLetter >> letterPriority)
        |> List.sum
        |> String.fromInt


splitInHalf : String -> ( String, String )
splitInHalf str =
    let
        strlen =
            String.length str // 2
    in
    ( String.slice 0 strlen str
    , String.slice strlen (String.length str) str
    )


commonLetter : ( String, String ) -> Char
commonLetter ( a, b ) =
    let
        toSet v =
            String.toList v |> Set.fromList
    in
    Set.intersect (toSet a) (toSet b)
        |> Set.toList
        |> List.head
        |> Maybe.withDefault 'a'


letterPriority : Char -> Int
letterPriority c =
    String.indexes (String.fromChar c) letterOrder
        |> List.head
        |> Maybe.withDefault 0


letterOrder : String
letterOrder =
    let
        lowerCase =
            List.map (Char.fromCode >> String.fromChar) (List.range 97 122) |> String.join ""

        upperCase =
            List.map (Char.fromCode >> String.fromChar) (List.range 65 90) |> String.join ""
    in
    " " ++ lowerCase ++ upperCase


part2 : List String -> String
part2 calories =
    calories
        |> group3
        |> List.map (common3 >> letterPriority)
        |> List.sum
        |> String.fromInt


group3 : List String -> List ( String, String, String )
group3 xs =
    case xs of
        a :: b :: c :: lst ->
            ( a, b, c ) :: group3 lst

        _ ->
            []


common3 : ( String, String, String ) -> Char
common3 ( a, b, c ) =
    let
        toSet v =
            String.toList v |> Set.fromList
    in
    Set.intersect (toSet a) (toSet b)
        |> Set.intersect (toSet c)
        |> Set.toList
        |> List.head
        |> Maybe.withDefault 'a'



-- RUN


main =
    Helpers.solve part1 part2
