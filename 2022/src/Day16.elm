module Day16 exposing (part1, part2)

import Dict exposing (Dict)
import Helpers
import Parser exposing ((|.), (|=), Parser, Step(..), end, int, loop, map, oneOf, succeed, symbol)
import ParserHelpers exposing (oneOrMore, runOnList, string)
import Set exposing (Set)



-- STRUCTS


type alias Valve =
    { opened : Bool
    , name : String
    , flowRate : Int
    , connect : List String
    }


type alias System =
    Dict String Valve



-- SOLUTION


part1 : List String -> String
part1 input =
    input
        |> runOnList valveParser
        |> toSystem
        |> bestAction "AA"
        |> String.fromInt


part2 : List String -> String
part2 _ =
    "TODO"


bestAction : String -> System -> Int
bestAction init =
    bestActionHelper Set.empty init 30 0


bestActionHelper : Set String -> String -> Int -> Int -> System -> Int
bestActionHelper visited current minutes decompressed system =
    if minutes <= 0 then
        decompressed

    else if Dict.values system |> List.all isConsummed then
        decompressed * minutes |> Debug.log ("remains " ++ String.fromInt minutes ++ " minutes to dec " ++ String.fromInt decompressed)

    else
        let
            details =
                Dict.get current system |> Maybe.withDefault { opened = True, name = "ZZ", flowRate = 0, connect = [] }

            nextUnvisited =
                details.connect |> List.filter (\v -> not <| Set.member v visited)

            asVisited =
                Set.insert current visited

            noActionOutcome =
                List.foldl (\v acc -> max acc <| bestActionHelper asVisited v (minutes - 1) decompressed system) -1 nextUnvisited

            openedSystem =
                Dict.insert current { details | opened = True } system

            openingOutcome =
                if details.flowRate > 0 && not details.opened && minutes >= 2 then
                    List.foldl
                        (\v acc ->
                            max acc <|
                                decompressed
                                    + bestActionHelper (Set.singleton current) v (minutes - 2) (decompressed + details.flowRate) openedSystem
                        )
                        -100000000
                        details.connect

                else
                    -100000000

            --
            --_ =
            --    Debug.log "current details" { visited = visited, details = details, nextUnvisited = nextUnvisited }
        in
        if List.isEmpty nextUnvisited && details.opened then
            decompressed * minutes

        else if details.opened then
            decompressed + noActionOutcome

        else
            decompressed + max noActionOutcome openingOutcome


isConsummed : Valve -> Bool
isConsummed { opened, flowRate } =
    opened || flowRate == 0


toSystem : List Valve -> System
toSystem =
    List.map (\v -> ( v.name, v )) >> Dict.fromList


valveParser : Parser Valve
valveParser =
    succeed (Valve False)
        |. symbol "Valve "
        |= string
        |. symbol " has flow rate="
        |= int
        |. symbol ";"
        |. introducerParser
        |= nameParser


nameParser : Parser (List String)
nameParser =
    loop [] nameParserHelper


nameParserHelper : List String -> Parser (Step (List String) (List String))
nameParserHelper acc =
    oneOf
        [ succeed (\str -> Loop (str :: acc)) |= pipeNameParser |. oneOf [ end, symbol ", " ]
        , succeed () |> map (\_ -> Done acc)
        ]


pipeNameParser : Parser String
pipeNameParser =
    oneOrMore "Pipe name" Char.isUpper


introducerParser : Parser String
introducerParser =
    oneOrMore "introducer" (\c -> c == ' ' || Char.isLower c)



-- RUN


main =
    Helpers.solve part1 part2
