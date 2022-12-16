module Day12 exposing (part1, part2)

import Helpers
import Matrix exposing (Matrix, fromLists)
import Set exposing (Set)



-- STRUCTS


type Location
    = Start
    | End
    | Step Int
    | Unreachable


type alias Position =
    ( Int, Int )


type alias Move =
    ( Position, Int )


type alias Path =
    { move : Move, steps : Int }



-- SOLUTION


part1 : List String -> String
part1 map =
    map
        |> List.map (String.toList >> List.map toLocation)
        |> fromLists
        |> Maybe.withDefault Matrix.empty
        |> shortestPath
        |> String.fromInt


part2 : List String -> String
part2 _ =
    "TODO"


startPosition : Position -> Matrix Location -> Position
startPosition ( x, y ) map =
    if x >= Matrix.width map then
        startPosition ( 0, y + 1 ) map

    else if y >= Matrix.height map then
        ( -1, -1 )

    else
        let
            current =
                getLocation ( x, y ) map
        in
        case current of
            Start ->
                ( x, y )

            _ ->
                startPosition ( x + 1, y ) map


shortestPath : Matrix Location -> Int
shortestPath map =
    let
        start =
            startPosition ( 0, 0 ) map

        search =
            [ { move = ( start, 0 ), steps = 0 } ]
    in
    studyMove search Set.empty map


studyMove : List Path -> Set Move -> Matrix Location -> Int
studyMove list history map =
    case list of
        [] ->
            -1

        path :: xs ->
            if Set.member path.move history then
                studyMove xs history map

            else
                let
                    pos =
                        Tuple.first path.move

                    fromAlt =
                        Tuple.second path.move

                    currentLocation =
                        getLocation pos map

                    updatedHistory =
                        Set.insert path.move history
                in
                case currentLocation of
                    Unreachable ->
                        studyMove xs updatedHistory map

                    Start ->
                        let
                            nwChoices =
                                neighbours path 0
                        in
                        studyMove (xs ++ nwChoices) updatedHistory map

                    End ->
                        if fromAlt >= 25 then
                            path.steps

                        else
                            studyMove xs updatedHistory map

                    Step alt ->
                        if (alt - fromAlt) <= 1 then
                            let
                                nwChoices =
                                    neighbours path alt
                            in
                            studyMove (xs ++ nwChoices) updatedHistory map

                        else
                            studyMove xs updatedHistory map


getLocation : Position -> Matrix Location -> Location
getLocation ( x, y ) map =
    Matrix.get x y map |> Maybe.withDefault Unreachable


neighbours : Path -> Int -> List Path
neighbours { move, steps } alt =
    let
        ( ( x, y ), _ ) =
            move
    in
    [ { move = ( ( x + 1, y ), alt ), steps = steps + 1 }
    , { move = ( ( x - 1, y ), alt ), steps = steps + 1 }
    , { move = ( ( x, y - 1 ), alt ), steps = steps + 1 }
    , { move = ( ( x, y + 1 ), alt ), steps = steps + 1 }
    ]


toLocation : Char -> Location
toLocation x =
    case x of
        'S' ->
            Start

        'E' ->
            End

        step ->
            Step <| Char.toCode step - 97



-- RUN


main =
    Helpers.solve part1 part2
