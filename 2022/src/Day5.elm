module Day5 exposing (part1, part2)

import Array
import Helpers
import Parser exposing ((|.), (|=), Parser, Step(..), end, int, loop, map, oneOf, succeed, symbol, variable)
import ParserHelpers exposing (runOnList)
import Set



-- STRUCTS


type alias MoveAction =
    { count : Int
    , origin : Int
    , destination : Int
    }



-- SOLUTION


resolve : Bool -> List String -> String
resolve withReverse sections =
    let
        initialState =
            sections
                |> List.map lineDebug
                |> List.filter (List.isEmpty >> not)
                |> rotateMatrix
                |> List.map (List.filter (String.isEmpty >> not))
                |> List.reverse

        moves =
            sections
                |> List.drop (List.length initialState + 1)
                |> List.filter (String.isEmpty >> not)
                |> runOnList moveParser

        movesApplied =
            List.foldl (applyMove withReverse) initialState moves
    in
    movesApplied
        |> List.map (List.head >> Maybe.withDefault "")
        |> String.join ""


part1 : List String -> String
part1 =
    resolve True


part2 : List String -> String
part2 =
    resolve False


applyMove : Bool -> MoveAction -> List (List String) -> List (List String)
applyMove reverse { count, origin, destination } lst =
    let
        ( removed, kept ) =
            getElem (origin - 1) lst |> (\value -> ( List.drop count value, List.take count value ))

        added =
            getElem (destination - 1) lst
                |> List.append
                    (if reverse then
                        List.reverse kept

                     else
                        kept
                    )
    in
    List.indexedMap
        (\i xs ->
            if i == (origin - 1) then
                removed

            else if i == (destination - 1) then
                added

            else
                xs
        )
        lst


rotateMatrix : List (List String) -> List (List String)
rotateMatrix xs =
    let
        rowsCount =
            getElem 0 xs |> List.length
    in
    List.range 0 (rowsCount - 1) |> List.map (\i -> List.map (getElem i) xs)


getElem : Int -> List a -> a
getElem i lst =
    case Array.fromList lst |> Array.get i of
        Just res ->
            res

        Nothing ->
            Debug.todo ("Elem with index " ++ String.fromInt i ++ " not found")


lineDebug : String -> List String
lineDebug str =
    case Parser.run lineParser str of
        Ok res ->
            res

        Err _ ->
            Debug.todo "Parsing error"


lineParser : Parser (List String)
lineParser =
    loop [] internalLineParser


internalLineParser : List String -> Parser (Step (List String) (List String))
internalLineParser rest =
    oneOf
        [ succeed (\str -> Loop (str :: rest))
            |= crateParser
            |. oneOf [ symbol " ", end ]
        , succeed () |> map (\_ -> Done rest)
        ]


crateParser : Parser String
crateParser =
    oneOf
        [ charParser
        , symbol "   " |> map (\_ -> "")
        ]


charParser : Parser String
charParser =
    succeed identity
        |. symbol "["
        |= variable
            { start = \_ -> True
            , inner = \c -> Char.isAlpha c
            , reserved = Set.empty
            }
        |. symbol "]"


moveParser : Parser MoveAction
moveParser =
    succeed MoveAction
        |. symbol "move "
        |= int
        |. symbol " from "
        |= int
        |. symbol " to "
        |= int



-- RUN


main =
    Helpers.solve part1 part2
