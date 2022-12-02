module Day2 exposing (..)

import Dict exposing (Dict)
import Helpers



-- SOLUTION


part1 : List String -> String
part1 calories =
    calories
        |> toPairs
        |> List.map totalPoints
        |> List.sum
        |> String.fromInt


part2 : List String -> String
part2 calories =
    calories
        |> toPairs
        |> List.map guessPoints
        |> List.sum
        |> String.fromInt


toPairs : List String -> List ( String, String )
toPairs lst =
    List.map (String.split " " >> lstToPair) lst


guessPoints : ( String, String ) -> Int
guessPoints ( his, result ) =
    let
        myPlay =
            Dict.get (his ++ result) equivalences |> Maybe.withDefault "X"
    in
    totalPoints ( his, myPlay )


totalPoints : ( String, String ) -> Int
totalPoints ( his, mine ) =
    let
        basePoints =
            shapePoints mine

        battlePoints =
            Dict.get (his ++ mine) outcomes |> Maybe.withDefault 0
    in
    basePoints + battlePoints


shapePoints : String -> Int
shapePoints str =
    case str of
        "X" ->
            1

        "Y" ->
            2

        "Z" ->
            3

        _ ->
            0


outcomes : Dict String Int
outcomes =
    Dict.fromList
        [ ( "AX", 3 )
        , ( "AY", 6 )
        , ( "AZ", 0 )
        , ( "BX", 0 )
        , ( "BY", 3 )
        , ( "BZ", 6 )
        , ( "CX", 6 )
        , ( "CY", 0 )
        , ( "CZ", 3 )
        ]


equivalences : Dict String String
equivalences =
    Dict.fromList
        [ ( "AX", "Z" )
        , ( "AY", "X" )
        , ( "AZ", "Y" )
        , ( "BX", "X" )
        , ( "BY", "Y" )
        , ( "BZ", "Z" )
        , ( "CX", "Y" )
        , ( "CY", "Z" )
        , ( "CZ", "X" )
        ]


lstToPair : List String -> ( String, String )
lstToPair xs =
    case xs of
        a :: b :: _ ->
            ( a, b )

        _ ->
            ( "", "" )



-- RUN


main =
    Helpers.solve part1 part2
