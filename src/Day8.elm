module Day8 exposing (part1, part2)

import Helpers
import List.Extra exposing (getAt, transpose)
import Set



-- Structs


type alias Grid =
    List (List Int)


type alias Coordinate =
    ( Int, Int )


type Orientation
    = Vertical
    | Horizontal



-- SOLUTION


toGrid : List String -> Grid
toGrid trees =
    trees
        |> List.map String.toList
        |> List.map (List.map (String.fromChar >> String.toInt >> Maybe.withDefault 0))


part1 : List String -> String
part1 rows =
    let
        baseGrid =
            toGrid rows

        rowsCount =
            baseGrid |> List.indexedMap (bothWays Horizontal) |> List.concat

        columnsCount =
            baseGrid |> transpose |> List.indexedMap (bothWays Vertical) |> List.concat
    in
    Set.fromList (rowsCount ++ columnsCount)
        |> Set.size
        |> String.fromInt


bothWays : Orientation -> Int -> List Int -> List Coordinate
bothWays orientation i xs =
    let
        toCoordinate c =
            case orientation of
                Horizontal ->
                    ( c, i )

                Vertical ->
                    ( i, c )
    in
    (visibleCount ( -1, 0, 1 ) xs ++ (List.reverse xs |> visibleCount ( -1, List.length xs - 1, -1 )))
        |> List.map toCoordinate


visibleCount : ( Int, Int, Int ) -> List Int -> List Int
visibleCount ( max, index, incr ) rest =
    case rest of
        [] ->
            []

        x :: xs ->
            if x > max then
                index :: visibleCount ( x, index + incr, incr ) xs

            else
                visibleCount ( max, index + incr, incr ) xs


part2 : List String -> String
part2 trees =
    let
        baseGrid =
            toGrid trees
    in
    List.indexedMap (\y xs -> List.indexedMap (\x _ -> scenicScore ( x, y ) baseGrid) xs) baseGrid
        |> List.concat
        |> List.maximum
        |> Maybe.withDefault 0
        |> String.fromInt


scenicScore : ( Int, Int ) -> Grid -> Int
scenicScore ( x, y ) grid =
    let
        myValue =
            getAt y grid
                |> Maybe.andThen (\lst -> getAt x lst)
                |> (\v ->
                        case v of
                            Just res ->
                                res

                            Nothing ->
                                Debug.todo "Failed to find my value"
                   )

        row =
            case getAt y grid of
                Just res ->
                    res

                Nothing ->
                    Debug.todo "Failed to access row index"

        left =
            List.take x row |> List.reverse

        right =
            List.drop (x + 1) row

        column =
            grid
                |> transpose
                |> getAt x
                |> (\res ->
                        case res of
                            Just v ->
                                v

                            Nothing ->
                                Debug.todo ("Failed to access grid coordinate x=" ++ String.fromInt x ++ " y=" ++ String.fromInt y)
                   )

        top =
            List.take y column |> List.reverse

        bottom =
            List.drop (y + 1) column
    in
    directionScore myValue left * directionScore myValue right * directionScore myValue top * directionScore myValue bottom


directionScore : Int -> List Int -> Int
directionScore max rest =
    case rest of
        [] ->
            0

        x :: xs ->
            if x < max then
                1 + directionScore max xs

            else
                1



-- RUN


main =
    Helpers.solve part1 part2
