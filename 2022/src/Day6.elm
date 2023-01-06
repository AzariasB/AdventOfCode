module Day6 exposing (part1, part2)

import Helpers
import Set



-- SOLUTION


resolve : Int -> List String -> String
resolve size stream =
    List.head stream
        |> Maybe.withDefault ""
        |> String.toList
        |> diffN size 0
        |> String.fromInt


part1 : List String -> String
part1 =
    resolve 4


part2 : List String -> String
part2 =
    resolve 14


diffN : Int -> Int -> List Char -> Int
diffN diff idx chars =
    let
        uniqs =
            chars
                |> List.take diff
                |> Set.fromList
                |> Set.size
    in
    if uniqs == diff then
        idx + diff

    else
        diffN diff (idx + 1) <| List.drop 1 chars



-- RUN


main =
    Helpers.solve part1 part2
