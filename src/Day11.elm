module Day11 exposing (part1, part2)

import Array exposing (Array)
import Helpers
import Parser exposing ((|.), (|=), Parser, Step(..), end, int, loop, map, oneOf, spaces, succeed, symbol)



-- STRUCTS


type Operation
    = Add Int
    | Multiply Int
    | Square


type alias Monkey =
    { worryReliever : Int
    , inspectedItems : Int
    , items : List Int
    , operation : Operation
    , divisibleTest : Int
    , testSuccessTarget : Int
    , testFailureTarget : Int
    }


defaultMonkey : Monkey
defaultMonkey =
    { worryReliever = 1
    , inspectedItems = 0
    , items = []
    , operation = Add 0
    , divisibleTest = 1
    , testFailureTarget = 0
    , testSuccessTarget = 0
    }



-- SOLUTION


resolve : Int -> Int -> List String -> String
resolve worry cycles deconstructed =
    deconstructed
        |> String.join "\n"
        |> jungleParser worry
        |> Array.fromList
        |> simulateJungle cycles
        --|> Debug.log "jungle is "
        |> Array.toList
        |> monkeyBusinessScore
        |> String.fromInt


part1 : List String -> String
part1 =
    resolve 3 20


part2 : List String -> String
part2 =
    resolve 1 10000


monkeyBusinessScore : List Monkey -> Int
monkeyBusinessScore =
    List.map (\m -> m.inspectedItems) >> List.sort >> List.reverse >> List.take 2 >> List.product


simulateJungle : Int -> Array Monkey -> Array Monkey
simulateJungle round monkeys =
    if round <= 0 then
        monkeys

    else
        simulateJungleHelper 0 monkeys |> simulateJungle (round - 1)


simulateJungleHelper : Int -> Array Monkey -> Array Monkey
simulateJungleHelper idx monkeys =
    if idx >= Array.length monkeys then
        monkeys

    else
        simulateMonkey idx monkeys |> simulateJungleHelper (idx + 1)


simulateMonkey : Int -> Array Monkey -> Array Monkey
simulateMonkey idx monkeys =
    let
        currentMonkey =
            Array.get idx monkeys |> Maybe.withDefault defaultMonkey

        currentItems =
            currentMonkey.items

        futureMonkey =
            { currentMonkey
                | inspectedItems = currentMonkey.inspectedItems + List.length currentMonkey.items
                , items = []
            }

        futureJungle =
            Array.set idx futureMonkey monkeys
    in
    itemInspection currentItems
        futureMonkey
        futureJungle


itemInspection : List Int -> Monkey -> Array Monkey -> Array Monkey
itemInspection items monkey jungle =
    case items of
        [] ->
            jungle

        x :: xs ->
            let
                worryLevel =
                    performOperation x monkey.operation // monkey.worryReliever

                modded =
                    modBy monkey.divisibleTest worryLevel
            in
            if modded == 0 then
                passItem worryLevel monkey.testSuccessTarget jungle |> itemInspection xs monkey

            else
                passItem worryLevel monkey.testFailureTarget jungle |> itemInspection xs monkey


performOperation : Int -> Operation -> Int
performOperation val op =
    case op of
        Square ->
            val * val

        Multiply x ->
            val * x

        Add x ->
            val + x


passItem : Int -> Int -> Array Monkey -> Array Monkey
passItem item target monkeys =
    let
        targetMonkey =
            Array.get target monkeys |> Maybe.withDefault defaultMonkey

        monkeyWithItem =
            { targetMonkey | items = targetMonkey.items ++ [ item ] }
    in
    Array.set target monkeyWithItem monkeys


jungleParser : Int -> String -> List Monkey
jungleParser worryReliever input =
    let
        jungleParserHelper acc =
            oneOf
                [ succeed (\monkey -> Loop (monkey :: acc)) |= monkeyParser worryReliever |. oneOf [ symbol "\n\n", end ]
                , succeed () |> map (\_ -> Done (List.reverse acc))
                ]

        parseRes =
            loop [] jungleParserHelper
    in
    case Parser.run parseRes input of
        Ok res ->
            res

        Err _ ->
            []


monkeyParser : Int -> Parser Monkey
monkeyParser worryReliever =
    succeed (Monkey worryReliever 0)
        |. symbol "Monkey "
        |. int
        |. symbol ":"
        |. spaces
        |. symbol "Starting items: "
        |= itemsParser
        |. spaces
        |. symbol "Operation: new = "
        |= operationParser
        |. spaces
        |. symbol "Test: divisible by "
        |= int
        |. spaces
        |. symbol "If true: throw to monkey "
        |= int
        |. spaces
        |. symbol "If false: throw to monkey "
        |= int


operationParser : Parser Operation
operationParser =
    oneOf
        [ succeed Square |. symbol "old * old"
        , succeed Multiply |. symbol "old * " |= int
        , succeed Add |. symbol "old + " |= int
        ]


itemsParser : Parser (List Int)
itemsParser =
    loop [] itemsParserHelper


itemsParserHelper : List Int -> Parser (Step (List Int) (List Int))
itemsParserHelper acc =
    oneOf
        [ succeed (\stmt -> Loop (stmt :: acc)) |= (int |. oneOf [ symbol ", ", symbol "\n" ])
        , succeed () |> map (\_ -> Done (List.reverse acc))
        ]



-- RUN


main =
    Helpers.solve part1 part2
