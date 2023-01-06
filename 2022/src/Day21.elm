module Day21 exposing (part1, part2)

import Arithmetic exposing (gcd)
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


type alias Ratio =
    ( Int, Int )


type EquationSide
    = Constant Ratio
    | LinearEquation Ratio Ratio



-- SOLUTION


part1 : List String -> String
part1 monkeys =
    monkeys
        |> runOnList monkeyParser
        |> monkeysToDict
        |> interpret "root"
        |> String.fromInt



-- 3453748220115 too low


part2 : List String -> String
part2 monkeys =
    monkeys
        |> runOnList monkeyParser
        |> monkeysToDict
        |> resolveEquation "root"
        |> String.fromInt


resolveEquation : String -> Dict String Monkey -> Int
resolveEquation name jungle =
    let
        sides =
            Dict.get name jungle
    in
    case sides of
        Nothing ->
            Debug.log (name ++ " not found") 0

        Just { yell } ->
            case yell of
                Number i ->
                    i

                Result { left, right } ->
                    let
                        leftEq =
                            createEquation left jungle |> Debug.log "left"

                        rightEq =
                            createEquation right jungle |> Debug.log "right"
                    in
                    case ( leftEq, rightEq ) of
                        ( Constant c, LinearEquation a b ) ->
                            solveEquation c a b

                        ( LinearEquation a b, Constant c ) ->
                            solveEquation c a b

                        _ ->
                            Debug.log "unsupported equations" -1



-- (constantV/constantD) = (aValue/aDivisor)x + (bValue/bDivisor)
-- x = ((constantV/constantD) - (bValue/bDivisor)) / (aValue/aDivisor)


solveEquation : Ratio -> Ratio -> Ratio -> Int
solveEquation constant a b =
    let
        diff =
            applyRatioOperand Subtract constant b

        ( fact, div ) =
            applyRatioOperand Divide diff a
    in
    mIDiv fact div + 1


createEquation : String -> Dict String Monkey -> EquationSide
createEquation name jungle =
    if name == "humn" then
        LinearEquation ( 1, 1 ) ( 0, 1 )

    else
        let
            found =
                Dict.get name jungle
        in
        case found of
            Nothing ->
                Debug.log (name ++ " not found") Constant ( 1, 1 )

            Just { yell } ->
                case yell of
                    Number i ->
                        Constant ( i, 1 )

                    Result { left, operand, right } ->
                        let
                            leftValue =
                                createEquation left jungle

                            rightValue =
                                createEquation right jungle
                        in
                        mergeEquations leftValue rightValue operand


mergeEquations : EquationSide -> EquationSide -> Operand -> EquationSide
mergeEquations left right op =
    case ( left, right ) of
        ( Constant a, Constant b ) ->
            Constant <| applyRatioOperand op a b

        ( LinearEquation a b, Constant c ) ->
            case op of
                Add ->
                    LinearEquation a (applyRatioOperand Add b c)

                Subtract ->
                    LinearEquation a (applyRatioOperand Subtract b c)

                Multiply ->
                    LinearEquation (applyRatioOperand Multiply a c) (applyRatioOperand Multiply b c)

                Divide ->
                    LinearEquation (applyRatioOperand Divide a c) (applyRatioOperand Divide b c)

        ( Constant c, LinearEquation a b ) ->
            case op of
                Add ->
                    LinearEquation a (applyRatioOperand Add b c)

                Subtract ->
                    LinearEquation (neg a) (applyRatioOperand Subtract c b)

                Multiply ->
                    LinearEquation (applyRatioOperand Multiply a c) (applyRatioOperand Multiply b c)

                Divide ->
                    LinearEquation (applyRatioOperand Divide c a) (applyRatioOperand Divide c b)

        _ ->
            Debug.log "Unsupported equation" Constant ( 0, 1 )


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
                    i

                Result { left, operand, right } ->
                    let
                        leftValue =
                            interpret left jungle

                        rightValue =
                            interpret right jungle
                    in
                    applyOperand operand leftValue rightValue


applyRatioOperand : Operand -> Ratio -> Ratio -> Ratio
applyRatioOperand op ( a, b ) ( c, d ) =
    case op of
        -- a/b + c/d = (a*d + c*b) / b*d
        Add ->
            ( a * d + c * b, b * d ) |> simplify

        -- a/b - c/d = (a*d - c*b) / b*d
        Subtract ->
            ( a * d - c * b, b * d ) |> simplify

        -- a/b * c/d = a*c / b*d
        Multiply ->
            ( a * c, d * b ) |> simplify

        -- a/b / c/d = a*d / b*c
        Divide ->
            ( a * d, b * c ) |> simplify


simplify : Ratio -> Ratio
simplify ( a, b ) =
    let
        g =
            gcd a b
    in
    ( mIDiv a g, mIDiv b g )


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
            mIDiv x y


mIDiv : Int -> Int -> Int
mIDiv x y =
    floor (toFloat x / toFloat y)


neg : Ratio -> Ratio
neg ( a, b ) =
    ( -a, b )



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
