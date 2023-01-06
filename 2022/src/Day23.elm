module Day23 exposing (part1, part2)

import Dict exposing (Dict)
import Helpers



-- STRUCTS


type Direction
    = North
    | South
    | West
    | East


type alias Position =
    ( Int, Int )


type alias Proposition =
    ( Position, ( Position, Position ) )


type alias Map =
    Dict Position Elf


type alias State =
    { map : Map, direction : Direction }


type alias PosElf =
    ( Position, Elf )


type alias Elf =
    { proposition : Maybe Position }


type alias Square =
    { minX : Int, minY : Int, maxX : Int, maxY : Int }



-- SOLUTION


part1 : List String -> String
part1 rows =
    rows
        |> List.indexedMap toElves
        |> List.concat
        |> Dict.fromList
        |> runNRounds 10
        |> countFloorTiles
        |> String.fromInt


part2 : List String -> String
part2 rows =
    rows
        |> List.indexedMap toElves
        |> List.concat
        |> Dict.fromList
        |> runUntilNoMove
        |> String.fromInt


runNRounds : Int -> Map -> Map
runNRounds n map =
    (runNRoundsHelper n { map = map, direction = North }).map


runUntilNoMove : Map -> Int
runUntilNoMove map =
    runUntilNoMoveHelper { map = map, direction = North }


runUntilNoMoveHelper : State -> Int
runUntilNoMoveHelper state =
    let
        updatedMap =
            state |> roundFirstHalf

        continue =
            needUpdating updatedMap
    in
    if continue then
        1 + runUntilNoMoveHelper { direction = nextDirection state.direction, map = roundSecondHalf updatedMap }

    else
        1


needUpdating : Map -> Bool
needUpdating map =
    map
        |> Dict.values
        |> List.map (\v -> v.proposition)
        |> List.any isJust


isJust : Maybe a -> Bool
isJust val =
    case val of
        Nothing ->
            False

        Just _ ->
            True


runNRoundsHelper : Int -> State -> State
runNRoundsHelper n state =
    if n <= 0 then
        state

    else
        let
            updatedMap =
                state |> roundFirstHalf |> roundSecondHalf
        in
        runNRoundsHelper (n - 1) { direction = nextDirection state.direction, map = updatedMap }


countFloorTiles : Map -> Int
countFloorTiles map =
    let
        totalArea =
            Dict.foldl countFloorTilesHelper { minX = 0, minY = 0, maxY = 0, maxX = 0 } map |> toArea
    in
    totalArea - Dict.size map


toArea : Square -> Int
toArea { minX, minY, maxX, maxY } =
    (1 + maxY - minY) * (1 + maxX - minX)


countFloorTilesHelper : Position -> Elf -> Square -> Square
countFloorTilesHelper ( x, y ) _ { minX, minY, maxX, maxY } =
    let
        nwMinX =
            min minX x

        nwMinY =
            min minY y

        nwMaxX =
            max maxX x

        nwMaxY =
            max maxY y
    in
    { minX = nwMinX, minY = nwMinY, maxX = nwMaxX, maxY = nwMaxY }


roundSecondHalf : Map -> Map
roundSecondHalf map =
    let
        flatten =
            map |> Dict.toList
    in
    flatten
        |> List.map Tuple.second
        |> countPropositions
        |> applyPropositions flatten
        |> Dict.fromList


applyPropositions : List PosElf -> Dict Position Int -> List PosElf
applyPropositions elves props =
    case elves of
        [] ->
            []

        ( pos, { proposition } ) :: xs ->
            let
                rest =
                    applyPropositions xs props

                nwElf =
                    { proposition = Nothing }
            in
            case proposition of
                Nothing ->
                    ( pos, nwElf ) :: rest

                Just prop ->
                    if (Dict.get prop props |> Maybe.withDefault 0) > 1 then
                        ( pos, nwElf ) :: rest

                    else
                        ( prop, nwElf ) :: rest


countPropositions : List Elf -> Dict Position Int
countPropositions elves =
    let
        addProposition elf dict =
            case elf.proposition of
                Nothing ->
                    dict

                Just prop ->
                    case Dict.get prop dict of
                        Nothing ->
                            Dict.insert prop 1 dict

                        Just val ->
                            Dict.insert prop (val + 1) dict
    in
    List.foldl addProposition Dict.empty elves


roundFirstHalf : State -> Map
roundFirstHalf { map, direction } =
    map
        |> Dict.toList
        |> List.map (updateElf map direction)
        |> Dict.fromList


updateElf : Map -> Direction -> PosElf -> PosElf
updateElf map dir ( pos, _ ) =
    if hasNothingAround pos map then
        ( pos, { proposition = Nothing } )

    else
        ( pos, searchFoNewSpot pos dir map )


searchFoNewSpot : Position -> Direction -> Map -> Elf
searchFoNewSpot pos dir map =
    let
        searches =
            searchSpots pos dir
    in
    { proposition = findFreeSpot searches map }


hasNothingAround : Position -> Map -> Bool
hasNothingAround pos map =
    around pos |> List.any (\v -> Dict.member v map) |> not


findFreeSpot : List Proposition -> Map -> Maybe Position
findFreeSpot pos map =
    case pos of
        [] ->
            Nothing

        ( target, ( a, b ) ) :: xs ->
            let
                isValidProposition =
                    not (Dict.member target map || Dict.member a map || Dict.member b map)
            in
            if isValidProposition then
                Just target

            else
                findFreeSpot xs map


searchSpots : Position -> Direction -> List Proposition
searchSpots ( x, y ) dir =
    let
        north =
            ( ( x, y - 1 ), ( ( x - 1, y - 1 ), ( x + 1, y - 1 ) ) )

        south =
            ( ( x, y + 1 ), ( ( x - 1, y + 1 ), ( x + 1, y + 1 ) ) )

        west =
            ( ( x - 1, y ), ( ( x - 1, y - 1 ), ( x - 1, y + 1 ) ) )

        east =
            ( ( x + 1, y ), ( ( x + 1, y - 1 ), ( x + 1, y + 1 ) ) )
    in
    case dir of
        North ->
            [ north, south, west, east ]

        South ->
            [ south, west, east, north ]

        West ->
            [ west, east, north, south ]

        East ->
            [ east, north, south, west ]


around : Position -> List Position
around ( x, y ) =
    [ ( x - 1, y - 1 )
    , ( x, y - 1 )
    , ( x + 1, y - 1 )
    , ( x - 1, y )
    , ( x + 1, y )
    , ( x - 1, y + 1 )
    , ( x, y + 1 )
    , ( x + 1, y + 1 )
    ]


toElves : Int -> String -> List ( Position, Elf )
toElves y chars =
    String.toList chars
        |> List.indexedMap (toElf y)
        |> List.filterMap identity


toElf : Int -> Int -> Char -> Maybe PosElf
toElf y x c =
    if c == '#' then
        Just ( ( x, y ), { proposition = Nothing } )

    else
        Nothing


nextDirection : Direction -> Direction
nextDirection dir =
    case dir of
        North ->
            South

        South ->
            West

        West ->
            East

        East ->
            North



-- RUN


main =
    Helpers.solve part1 part2
