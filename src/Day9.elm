module Day9 exposing (part1, part2)

import Helpers
import List.Extra exposing (last, scanl)
import Parser exposing ((|.), (|=), Parser, end, int, oneOf, spaces, succeed, symbol)
import ParserHelpers exposing (runOnList)
import Set exposing (Set)



-- STRUCTS


type Direction
    = Right
    | Left
    | Up
    | Down


type alias Move =
    { direction : Direction, times : Int }


type alias Position =
    ( Int, Int )


type alias State =
    { head : Position, tail : List Position, history : List Position }



-- SOLUTION


solve : Int -> List String -> String
solve size instructions =
    instructions
        |> runOnList moveParser
        |> simulateMoves size
        |> Set.size
        |> String.fromInt


part1 : List String -> String
part1 =
    solve 1


part2 : List String -> String
part2 =
    solve 9


simulateMoves : Int -> List Move -> Set Position
simulateMoves tailLength xs =
    simulateMovesHelper
        { head = ( 0, 0 )
        , tail = List.repeat tailLength ( 0, 0 )
        , history = []
        }
        xs
        |> Set.fromList


simulateMovesHelper : State -> List Move -> List Position
simulateMovesHelper state moves =
    case moves of
        [] ->
            []

        x :: xs ->
            let
                nwState =
                    moveState state x
            in
            nwState.history ++ simulateMovesHelper nwState xs


moveState : State -> Move -> State
moveState ({ head, tail, history } as state) { times, direction } =
    case times of
        0 ->
            state

        _ ->
            let
                nwHead =
                    applyDirection head direction

                nwTail =
                    scanl bringCloser nwHead tail |> List.tail |> Maybe.withDefault []

                nwLast =
                    last nwTail |> Maybe.withDefault ( 0, 0 )
            in
            moveState { head = nwHead, tail = nwTail, history = nwLast :: history } { times = times - 1, direction = direction }


bringCloser : Position -> Position -> Position
bringCloser ( xTail, yTail ) ( xHead, yHead ) =
    let
        xDiff =
            xHead - xTail

        yDiff =
            yHead - yTail

        xSign =
            if abs xDiff >= 2 || abs yDiff >= 2 then
                sign <| xDiff

            else
                0

        ySign =
            if abs yDiff >= 2 || abs xDiff >= 2 then
                sign <| yHead - yTail

            else
                0
    in
    ( xTail + xSign, yTail + ySign )


applyDirection : Position -> Direction -> Position
applyDirection ( x, y ) dir =
    case dir of
        Right ->
            ( x + 1, y )

        Left ->
            ( x - 1, y )

        Up ->
            ( x, y - 1 )

        Down ->
            ( x, y + 1 )


moveParser : Parser Move
moveParser =
    let
        directionParser =
            oneOf
                [ succeed Right |. symbol "R"
                , succeed Left |. symbol "L"
                , succeed Up |. symbol "U"
                , succeed Down |. symbol "D"
                ]
    in
    succeed Move |= directionParser |. spaces |= int |. end


sign : Int -> Int
sign x =
    if x < 0 then
        -1

    else if x == 0 then
        0

    else
        1



-- RUN


main =
    Helpers.solve part1 part2
