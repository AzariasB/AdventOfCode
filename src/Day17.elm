module Day17 exposing (part1, part2)

import Bitwise exposing (shiftLeftBy)
import Helpers
import List.Extra exposing (dropWhile, uncons, zip)



-- STRUCTS


type alias Simulation =
    List Int



-- SOLUTION


resolve : Int -> List String -> String
resolve maxRounds instructions =
    instructions
        |> String.join ""
        |> String.toList
        |> runTetrisSimulation 0 maxRounds []
        |> String.fromInt


part1 : List String -> String
part1 =
    resolve 2022


part2 : List String -> String
part2 =
    resolve 2022


runTetrisSimulation : Int -> Int -> Simulation -> List Char -> Int
runTetrisSimulation rounds max sim moves =
    let
        adding =
            emptyPad (3 + List.length currentShape)

        mwSim =
            adding ++ sim

        currentShape =
            genShape rounds

        ( nwSim, nwMoves ) =
            runTetrisSimulationHelper (List.length currentShape) moves currentShape mwSim
    in
    if rounds == max then
        List.length nwSim

    else
        runTetrisSimulation (rounds + 1) max nwSim nwMoves


runTetrisSimulationHelper : Int -> List Char -> Simulation -> Simulation -> ( Simulation, List Char )
runTetrisSimulationHelper shift instructions shape sim =
    let
        ( nxtMove, rest ) =
            uncons instructions |> Maybe.withDefault ( '>', [] )

        nwInstr =
            rest ++ [ nxtMove ]

        nwShape =
            applyMove nxtMove shape

        withSimMask =
            if validSim shift nwShape sim then
                nwShape

            else
                shape

        canShiftDown =
            validSim (shift + 1) withSimMask sim
    in
    if canShiftDown then
        runTetrisSimulationHelper (shift + 1) nwInstr withSimMask sim

    else
        ( applyShape shift withSimMask sim, nwInstr )


applyShape : Int -> Simulation -> Simulation -> Simulation
applyShape shift shape sim =
    let
        toApply =
            List.take shift sim

        rest =
            List.drop shift sim

        missing =
            max 0 (shift - List.length shape)

        applied =
            zip toApply (emptyPad missing ++ shape) |> List.map (\( a, b ) -> Bitwise.or a b)
    in
    dropWhile isEmpty applied ++ rest


isEmpty : Int -> Bool
isEmpty =
    (==) 0


validSim : Int -> Simulation -> Simulation -> Bool
validSim shift shape sim =
    if shift > List.length sim then
        False

    else
        let
            slice =
                List.take shift sim

            fullShape =
                emptyPad (shift - List.length shape) ++ shape
        in
        zip slice fullShape |> List.all canStack


canStack : ( Int, Int ) -> Bool
canStack ( x, y ) =
    Bitwise.or x y == x + y


genShape : Int -> Simulation
genShape x =
    listToSim
        (case modBy 5 x of
            0 ->
                [ 15 ]

            1 ->
                [ 2, 7, 2 ]

            2 ->
                [ 4, 4, 7 ]

            3 ->
                [ 1, 1, 1, 1 ]

            _ ->
                [ 3, 3 ]
        )


applyMove : Char -> Simulation -> Simulation
applyMove move sim =
    let
        mapped =
            if move == '>' then
                List.map shiftRight sim

            else
                List.map shiftLeft sim

        canMove =
            List.all Tuple.second mapped
    in
    if canMove then
        mapped |> List.map Tuple.first

    else
        sim


shiftLeft : Int -> ( Int, Bool )
shiftLeft row =
    if Bitwise.and row 1 == 1 then
        ( 0, False )

    else
        ( Bitwise.shiftRightBy 1 row, True )


shiftRight : Int -> ( Int, Bool )
shiftRight row =
    if Bitwise.and 64 row == 64 then
        ( 0, False )

    else
        ( Bitwise.shiftLeftBy 1 row, True )


listToSim : List Int -> Simulation
listToSim =
    List.map normalizeRow


normalizeRow : Int -> Int
normalizeRow =
    shiftLeftBy 2



--simToString : Simulation -> String
--simToString xs =
--    xs
--        |> List.map String.fromList
--        |> String.join "\n"


emptyPad : Int -> Simulation
emptyPad size =
    List.repeat size 0



-- RUN


main =
    Helpers.solve part1 part2
