module Day14 exposing (part1, part2)

import Array exposing (Array)
import Dict exposing (Dict)
import Helpers
import Maths exposing (sign)
import Parser exposing ((|.), (|=), Parser, Step(..), end, int, loop, map, oneOf, succeed, symbol)
import ParserHelpers exposing (runOnList)



-- STRUCTS


type alias Point =
    ( Int, Int )


type alias Structure =
    List Point


type alias FixedSimulation =
    Array (Array Int)


type alias FreeSimulation =
    { points : Dict ( Int, Int ) Int
    , floor : Int
    }


type PointInfo
    = Void
    | Free
    | Occupied



-- SOLUTION


part1 : List String -> String
part1 pipes =
    let
        ( rawPipes, xChange ) =
            pipes
                |> runOnList structureParser
                |> simplify

        map =
            toMap rawPipes
    in
    runFixedSimulation map (500 - xChange) 0 |> String.fromInt


part2 : List String -> String
part2 pipes =
    pipes
        |> runOnList structureParser
        |> toFreeSimulation
        |> runFreeSimulation 1
        |> String.fromInt


runFixedSimulation : FixedSimulation -> Int -> Int -> Int
runFixedSimulation sim xGen steps =
    let
        ( nwSim, stop ) =
            fixedSimulationStep ( xGen, 0 ) sim
    in
    if stop then
        steps

    else
        runFixedSimulation nwSim xGen (steps + 1)


runFreeSimulation : Int -> FreeSimulation -> Int
runFreeSimulation step sim =
    let
        ( nwSim, stop ) =
            freeSimulationStep ( 500, 0 ) sim
    in
    if stop then
        step

    else
        runFreeSimulation (step + 1) nwSim


freeSimulationStep : Point -> FreeSimulation -> ( FreeSimulation, Bool )
freeSimulationStep current ({ floor, points } as sim) =
    let
        downPos =
            down current
    in
    if isSpotFree downPos sim then
        freeSimulationStep downPos sim

    else
        let
            dlPos =
                downLeft current
        in
        if isSpotFree dlPos sim then
            freeSimulationStep dlPos sim

        else
            let
                drPos =
                    downRight current
            in
            if isSpotFree drPos sim then
                freeSimulationStep drPos sim

            else
                ( { sim | points = Dict.insert current 2 points }, current == ( 500, 0 ) )


isSpotFree : Point -> FreeSimulation -> Bool
isSpotFree (( _, y ) as point) { points, floor } =
    not (Dict.member point points) && y < floor


fixedSimulationStep : Point -> FixedSimulation -> ( FixedSimulation, Bool )
fixedSimulationStep current sim =
    let
        downPos =
            down current

        downValue =
            probeSimulation downPos sim
    in
    -- First we look down
    case downValue of
        Void ->
            ( sim, True )

        Free ->
            fixedSimulationStep downPos sim

        Occupied ->
            -- Then we look on the left
            let
                dl =
                    downLeft current

                dlVal =
                    probeSimulation dl sim
            in
            case dlVal of
                Void ->
                    ( sim, True )

                Free ->
                    fixedSimulationStep dl sim

                Occupied ->
                    -- And then on the right
                    let
                        rl =
                            downRight current

                        rlVal =
                            probeSimulation rl sim
                    in
                    case rlVal of
                        Void ->
                            ( sim, True )

                        Free ->
                            fixedSimulationStep rl sim

                        Occupied ->
                            ( addGrainOfSand current sim, False )


addGrainOfSand : Point -> FixedSimulation -> FixedSimulation
addGrainOfSand ( x, y ) sim =
    let
        targetRow =
            Array.get y sim |> Maybe.withDefault Array.empty

        nwRow =
            Array.set x 2 targetRow
    in
    Array.set y nwRow sim


probeSimulation : Point -> FixedSimulation -> PointInfo
probeSimulation ( x, y ) sim =
    let
        value =
            Array.get y sim |> Maybe.andThen (Array.get x)
    in
    case value of
        Nothing ->
            Void

        Just cell ->
            if cell == 0 then
                Free

            else
                Occupied


down : Point -> Point
down ( x, y ) =
    ( x, y + 1 )


downLeft : Point -> Point
downLeft ( x, y ) =
    ( x - 1, y + 1 )


downRight : Point -> Point
downRight ( x, y ) =
    ( x + 1, y + 1 )


simplify : List Structure -> ( List Structure, Int )
simplify structures =
    let
        minX =
            dimensionExtreme Tuple.first List.minimum structures

        mapStructure struct =
            List.map (\( x, y ) -> ( x - minX, y )) struct
    in
    ( List.map mapStructure structures, minX )


toFreeSimulation : List Structure -> FreeSimulation
toFreeSimulation structs =
    toFreeSimulationHelper structs { floor = 0, points = Dict.empty }


toFreeSimulationHelper : List Structure -> FreeSimulation -> FreeSimulation
toFreeSimulationHelper structs sim =
    case structs of
        [] ->
            sim

        x :: xs ->
            maskStructure x sim |> toFreeSimulationHelper xs


maskStructure : Structure -> FreeSimulation -> FreeSimulation
maskStructure struct sim =
    case struct of
        [] ->
            sim

        a :: b :: xs ->
            maskStructure (b :: xs) (maskLine a b sim)

        x :: xs ->
            maskStructure xs (maskLine x x sim)


maskLine : Point -> Point -> FreeSimulation -> FreeSimulation
maskLine ( x, y ) ( tX, tY ) { floor, points } =
    let
        nwPoints =
            Dict.insert ( x, y ) 1 points

        nwFloor =
            max floor (y + 2)

        nwSim =
            { floor = nwFloor, points = nwPoints }
    in
    if x == tX && y == tY then
        nwSim

    else
        maskLine ( x + sign (tX - x), y + sign (tY - y) ) ( tX, tY ) nwSim


toMap : List Structure -> FixedSimulation
toMap structures =
    let
        mapHeight =
            dimensionExtreme Tuple.second List.maximum structures

        mapWidth =
            dimensionExtreme Tuple.first List.maximum structures

        emptyMap =
            Array.repeat (mapHeight + 1) (Array.repeat (mapWidth + 1) 0)
    in
    List.foldl applyStructure emptyMap structures


applyStructure : Structure -> FixedSimulation -> FixedSimulation
applyStructure points map =
    case points of
        [] ->
            map

        from :: to :: xs ->
            activateCells from to map |> applyStructure (to :: xs)

        a :: xs ->
            activateCells a a map |> applyStructure xs


activateCells : Point -> Point -> FixedSimulation -> FixedSimulation
activateCells ( x, y ) ( tX, tY ) map =
    let
        targetRow =
            Array.get y map |> Maybe.withDefault Array.empty

        nwRow =
            Array.set x 1 targetRow

        nwMap =
            Array.set y nwRow map
    in
    if x == tX && y == tY then
        nwMap

    else
        activateCells ( x + sign (tX - x), y + sign (tY - y) ) ( tX, tY ) nwMap


dimensionExtreme : (Point -> Int) -> (List Int -> Maybe Int) -> List Structure -> Int
dimensionExtreme transformer aggregator =
    List.concat >> List.map transformer >> aggregator >> Maybe.withDefault 0


structureParser : Parser Structure
structureParser =
    loop [] structureParserHelper


structureParserHelper : Structure -> Parser (Step Structure Structure)
structureParserHelper acc =
    oneOf
        [ succeed (\point -> Loop (point :: acc)) |= pointParser |. oneOf [ symbol " -> ", end ]
        , succeed () |> map (\_ -> Done (List.reverse acc))
        ]


pointParser : Parser Point
pointParser =
    succeed Tuple.pair |= int |. symbol "," |= int



-- DEBUG
--prettyPrint : FixedSimulation -> String
--prettyPrint =
--    Array.map rowPrint >> Array.toList >> String.join "\n"
--
--
--rowPrint : Array Int -> String
--rowPrint =
--    Array.map simChar >> Array.toList >> String.fromList
--
--
--simChar : Int -> Char
--simChar x =
--    case x of
--        2 ->
--            '.'
--
--        1 ->
--            '#'
--
--        _ ->
--            ' '
--
--
-- RUN


main =
    Helpers.solve part1 part2
