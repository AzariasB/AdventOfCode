module Day10 exposing (part1, part2)

import Helpers
import List.Extra exposing (groupsOf, zip)
import Parser exposing ((|.), (|=), Parser, end, oneOf, succeed, symbol)
import ParserHelpers exposing (betterInt, runOnList)



-- STRUCTS


type Operation
    = NoOperation
    | Add Int


type alias State =
    { cycles : Int, register : Int }



-- SOLUTION


part1 : List String -> String
part1 operations =
    runOnList parseOperation operations
        |> valuesAtSteps [ 20, 60, 100, 140, 180, 220 ]
        |> List.sum
        |> String.fromInt


part2 : List String -> String
part2 operations =
    runOnList parseOperation operations
        |> draw
        |> String.toList
        |> groupsOf 40
        |> List.map String.fromList
        |> String.join "\n"



-- LOGIC


draw : List Operation -> String
draw =
    drawHelper { cycles = 1, register = 1 }


drawHelper : State -> List Operation -> String
drawHelper state ops =
    case ops of
        [] ->
            ""

        x :: xs ->
            let
                ( display, nwState ) =
                    cycle x state
            in
            display ++ drawHelper nwState xs


cycle : Operation -> State -> ( String, State )
cycle op ({ register, cycles } as state) =
    let
        baseMask =
            mask state

        nwState =
            runOperation state op
    in
    case op of
        NoOperation ->
            ( baseMask, nwState )

        Add _ ->
            ( baseMask ++ mask { state | cycles = cycles + 1 }, nwState )


mask : State -> String
mask { register, cycles } =
    let
        modCycle =
            modBy 40 cycles
    in
    if modCycle >= register && modCycle <= register + 2 then
        "#"

    else
        "."


valuesAtSteps : List Int -> List Operation -> List Int
valuesAtSteps xs ops =
    valuesAtStepsHelper xs ops { register = 1, cycles = 0 }
        |> zip xs
        |> List.map (\( a, b ) -> a * b)


valuesAtStepsHelper : List Int -> List Operation -> State -> List Int
valuesAtStepsHelper steps ops ({ register, cycles } as state) =
    case ( steps, ops ) of
        ( [], _ ) ->
            []

        ( _, [] ) ->
            []

        ( s :: ss, o :: oo ) ->
            let
                nwState =
                    runOperation state o
            in
            if nwState.cycles >= s then
                register :: valuesAtStepsHelper ss oo nwState

            else
                valuesAtStepsHelper (s :: ss) oo nwState


runOperation : State -> Operation -> State
runOperation state op =
    case op of
        NoOperation ->
            { state | cycles = state.cycles + 1 }

        Add x ->
            { cycles = state.cycles + 2, register = state.register + x }


parseOperation : Parser Operation
parseOperation =
    oneOf
        [ succeed NoOperation |. symbol "noop"
        , succeed Add |. symbol "addx " |= betterInt
        ]
        |. end



-- RUN


main =
    Helpers.solve part1 part2
