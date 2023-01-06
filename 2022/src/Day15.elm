module Day15 exposing (part1, part2)

import Helpers
import Parser exposing ((|.), (|=), Parser, int, succeed, symbol)
import ParserHelpers exposing (betterInt, orElse, runOnList)
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
        |> occupiedSpots
        |> String.fromInt


part2 : List String -> String
part2 sensors =
    sensors
        |> runOnList sensorParser
        |> findFreeSpot
        |> toTuningFrequency
        |> String.fromInt


toTuningFrequency : Maybe Position -> Int
toTuningFrequency pos =
    case pos of
        Nothing ->
            Debug.log "Failed to find a free position" 0

        Just ( x, y ) ->
            x * 4000000 + y


findFreeSpot : List Sensor -> Maybe Position
findFreeSpot xs =
    List.foldl (orElse << lookAroundSensor xs) Nothing xs


lookAroundSensor : List Sensor -> Sensor -> Maybe Position
lookAroundSensor sensors (( origin, _ ) as sensor) =
    let
        distance =
            sensorRange sensor
    in
    lookAroundSensorHelper sensors ( combine origin ( distance + 1, 0 ), ( -1, -1 ) ) distance
        |> orElse (lookAroundSensorHelper sensors ( combine origin ( distance + 1, 0 ), ( -1, 1 ) ) distance)
        |> orElse (lookAroundSensorHelper sensors ( combine origin ( -distance - 1, 0 ), ( 1, -1 ) ) distance)
        |> orElse (lookAroundSensorHelper sensors ( combine origin ( -distance - 1, 0 ), ( 1, 1 ) ) distance)


lookAroundSensorHelper : List Sensor -> Sensor -> Int -> Maybe Position
lookAroundSensorHelper sensors ( current, increase ) steps =
    if steps <= 0 then
        Nothing

    else
        let
            taken =
                List.any (isCoveredBySensor current) sensors

            next =
                combine current increase
        in
        if isValidPosition current && not taken then
            Just current

        else
            lookAroundSensorHelper sensors ( next, increase ) (steps - 1)


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


isCoveredBySensor : Position -> Sensor -> Bool
isCoveredBySensor pos (( origin, _ ) as sensor) =
    sensorRange sensor >= sensorRange ( pos, origin )


isValidPosition : Position -> Bool
isValidPosition ( x, y ) =
    x >= 0 && x <= 4000000 && y >= 0 && y <= 4000000


sensorRange : Sensor -> Int
sensorRange ( ( fx, fy ), ( tx, ty ) ) =
    abs (fx - tx) + abs (fy - ty)


yDistance : Sensor -> Int -> Int
yDistance ( ( _, fy ), _ ) target =
    abs (target - fy)


combine : Position -> Position -> Position
combine ( x, y ) ( ix, iy ) =
    ( x + ix, y + iy )


coveredRange : Sensor -> Int -> Set Int
coveredRange (( ( fx, _ ), _ ) as sensor) baseLine =
    let
        range =
            sensorRange sensor

        distance =
            yDistance sensor baseLine

        remains =
            range
                - distance

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
