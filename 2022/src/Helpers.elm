port module Helpers exposing (..)

-- RUN

import Platform


port startPart1 : (List String -> msg) -> Sub msg


port startPart2 : (List String -> msg) -> Sub msg


port output : String -> Cmd msg


type Msg
    = Part1 (List String)
    | Part2 (List String)


solve : (List String -> String) -> (List String -> String) -> Program () () Msg
solve part1 part2 =
    Platform.worker
        { init = init
        , update = update part1 part2
        , subscriptions = subscriptions
        }


init : () -> ( (), Cmd Msg )
init _ =
    ( (), Cmd.none )


update part1 part2 msg _ =
    case msg of
        Part1 lines ->
            ( (), showOutputFor "Part 1" <| part1 <| lines )

        Part2 lines ->
            ( (), showOutputFor "Part 2" <| part2 <| lines )


showOutputFor label result =
    output <| label ++ ": " ++ result


subscriptions _ =
    Sub.batch
        [ startPart1 Part1
        , startPart2 Part2
        ]



-- HELPERS


toInts list =
    list
        |> List.map String.toInt
        |> List.map (Maybe.withDefault 0)
