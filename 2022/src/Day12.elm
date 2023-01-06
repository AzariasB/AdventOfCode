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


resolve : (Matrix Location -> Int) -> List String -> String
resolve solver map =
    map
        |> List.map (String.toList >> List.map toLocation)
        |> fromLists
        |> Maybe.withDefault Matrix.empty
        |> solver
        |> String.fromInt


part1 : List String -> String
part1 =
    resolve shortestPath


part2 : List String -> String
part2 =
    resolve closestLower


findLocation : Location -> Position -> Matrix Location -> Position
findLocation search ( x, y ) map =
    if x >= Matrix.width map then
        findLocation search ( 0, y + 1 ) map

    else if y >= Matrix.height map then
        ( -1, -1 )

    else
        let
            current =
                getLocation ( x, y ) map
        in
        if current == search then
            ( x, y )

        else
            findLocation search ( x + 1, y ) map


shortestPath : Matrix Location -> Int
shortestPath map =
    let
        start =
            findLocation Start ( 0, 0 ) map

        search =
            [ { move = ( start, 0 ), steps = 0 } ]
    in
    studyMove search Set.empty map


closestLower : Matrix Location -> Int
closestLower map =
    let
        end =
            findLocation End ( 0, 0 ) map

        search =
            [ { move = ( end, 0 ), steps = 0 } ]
    in
    reverseSearch search Set.empty map


reverseSearch : List Path -> Set Move -> Matrix Location -> Int
reverseSearch list history map =
    case list of
        [] ->
            -1

        path :: xs ->
            if Set.member path.move history then
                reverseSearch xs history map

            else
                let
                    pos =
                        Tuple.first path.move

                    alt =
                        Tuple.second path.move

                    currentLocation =
                        getLocation pos map

                    updatedHistory =
                        Set.insert path.move history
                in
                case currentLocation of
                    Unreachable ->
                        reverseSearch xs updatedHistory map

                    Start ->
                        path.steps

                    End ->
                        let
                            nwChoices =
                                neighbours path 25
                        in
                        reverseSearch (xs ++ nwChoices) updatedHistory map

                    Step fromAlt ->
                        if (alt - fromAlt) <= 1 then
                            if fromAlt == 0 then
                                path.steps

                            else
                                let
                                    nwChoices =
                                        neighbours path fromAlt
                                in
                                reverseSearch (xs ++ nwChoices) updatedHistory map

                        else
                            reverseSearch xs updatedHistory map


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
    Matrix.get (y + 1) (x + 1) map |> Maybe.withDefault Unreachable


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
