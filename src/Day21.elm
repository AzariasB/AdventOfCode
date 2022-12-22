module Day21 exposing (part1, part2)

import Dict exposing (Dict)
import Helpers
import Parser exposing ((|.), (|=), Parser, end, int, oneOf, spaces, succeed, symbol)
import ParserHelpers exposing (basicString, runOnList)



-- STRUCTS


type Operand
    = Add
    | Subtract
    | Multiply
    | Divide


type alias Operation =
    { left : String, operand : Operand, right : String }


type Yell
    = Number Int
    | Result Operation


type alias Monkey =
    { name : String, yell : Yell }



-- SOLUTION


part1 : List String -> String
part1 monkeys =
    monkeys
        |> runOnList monkeyParser
        -- |> Debug.log "operations"
        |> monkeysToDict
        |> interpret "root"
        |> String.fromInt


part2 : List String -> String
part2 _ =
    "TODO"


interpret : String -> Dict String Monkey -> Int
interpret name jungle =
    let
        found =
            Dict.get name jungle
    in
    case found of
        Nothing ->
            Debug.log (name ++ " not found") 0

        Just { yell } ->
            case yell of
                Number i ->
                    i |> Debug.log ("eval " ++ name ++ " is ")

                Result { left, operand, right } ->
                    let
                        leftValue =
                            interpret left jungle

                        rightValue =
                            interpret right jungle

                        res =
                            applyOperand operand leftValue rightValue |> Debug.log ("eval " ++ name ++ " is ")
                    in
                    res


applyOperand : Operand -> Int -> Int -> Int
applyOperand op x y =
    case op of
        Add ->
            x + y

        Subtract ->
            x - y

        Multiply ->
            x * y

        Divide ->
            floor (toFloat x / toFloat y)



-- So, integer division in elm doesn't always work
-- the way it's compiled in javascript is using (x  / y) | 0
-- but in some cases, the | 0 operation doesn't just truncate the number, it changes it as well
-- In my case it fails when x = 185080101492012 and y = 12
-- The correct result is 15423341791001, but elm returns 114231065
-- So the workaround is to convert to float and back to int
-- but that a reallyyyy weird bug


monkeysToDict : List Monkey -> Dict String Monkey
monkeysToDict monkeys =
    List.foldl
        (\v acc -> Dict.insert v.name v acc)
        Dict.empty
        monkeys


monkeyParser : Parser Monkey
monkeyParser =
    succeed Monkey
        |= basicString
        |. symbol ":"
        |. spaces
        |= yellParser
        |. end


yellParser : Parser Yell
yellParser =
    oneOf
        [ succeed Number |= int
        , succeed Result |= operationParser
        ]


operationParser : Parser Operation
operationParser =
    succeed Operation
        |= basicString
        |. spaces
        |= operandParser
        |. spaces
        |= basicString


operandParser : Parser Operand
operandParser =
    oneOf
        [ succeed Add |. symbol "+"
        , succeed Subtract |. symbol "-"
        , succeed Multiply |. symbol "*"
        , succeed Divide |. symbol "/"
        ]



-- RUN


main =
    Helpers.solve part1 part2



-- 3453748220116 : javascript
-- 5697701040178 : elm
-- 5697701040178
-- 21120928600114 : python
