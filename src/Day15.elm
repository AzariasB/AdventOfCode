module Day15 exposing (part1, part2)

import Helpers
import Parser exposing ((|.), (|=), Parser, int, succeed, symbol)
import ParserHelpers exposing (betterInt, runOnList)
import Set exposing (Set)



-- STRUCTS


type alias Position =
    ( Int, Int )


type alias Sensor =
    ( Position, Position )



-- SOLUTION


part1 : List String -> String
part1 sensors =
    sensors
        |> runOnList sensorParser
        --|> Debug.log "sensors"
        |> occupiedSpots
        |> String.fromInt


part2 : List String -> String
part2 _ =
    "TODO"


occupiedSpots : List Sensor -> Int
occupiedSpots xs =
    let
        searchRow =
            2000000

        allSpots =
            occupiedSpotsHelper Set.empty searchRow xs

        taken =
            List.map (isTakenBySensor searchRow) xs |> List.concat |> Set.fromList
    in
    taken
        |> Set.diff allSpots
        |> Set.size


isTakenBySensor : Int -> Sensor -> List Int
isTakenBySensor baseline ( ( sx, sy ), ( bx, by ) ) =
    let
        sensor =
            if sy == baseline then
                [ sx ]

            else
                []

        beacon =
            if by == baseline then
                [ bx ]

            else
                []
    in
    sensor ++ beacon


occupiedSpotsHelper : Set Int -> Int -> List Sensor -> Set Int
occupiedSpotsHelper occupied baseLine sensors =
    case sensors of
        [] ->
            occupied

        x :: xs ->
            let
                nwCover =
                    coveredRange x baseLine |> Set.union occupied
            in
            occupiedSpotsHelper nwCover baseLine xs


sensorRange : Sensor -> Int
sensorRange ( ( fx, fy ), ( tx, ty ) ) =
    abs (fx - tx) + abs (fy - ty)


yDistance : Sensor -> Int -> Int
yDistance ( ( _, fy ), _ ) target =
    abs (target - fy)


coveredRange : Sensor -> Int -> Set Int
coveredRange (( ( fx, _ ), _ ) as sensor) baseLine =
    let
        --_ =
        --    Debug.log "with sensor" sensor
        range =
            sensorRange sensor

        --|> Debug.log "range"
        --
        distance =
            yDistance sensor baseLine

        --|> Debug.log "distance from baseline"
        remains =
            range
                - distance

        --|> Debug.log "spread on baseline"
        covering =
            if remains > 0 then
                let
                    lower =
                        fx - remains

                    higher =
                        fx + remains
                in
                List.range lower higher

            else
                []

        --
        --_ =
        --    Debug.log "covering" covering
    in
    Set.fromList covering


sensorParser : Parser Sensor
sensorParser =
    succeed Tuple.pair
        |= (succeed Tuple.pair
                |. symbol "Sensor at x="
                |= int
                |. symbol ", y="
                |= int
           )
        |= (succeed Tuple.pair
                |. symbol ": closest beacon is at x="
                |= betterInt
                |. symbol ", y="
                |= betterInt
           )



-- RUN


main =
    Helpers.solve part1 part2
