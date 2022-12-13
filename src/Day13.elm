module Day13 exposing (part1, part2)

import Helpers
import List.Extra exposing (findIndices, greedyGroupsOf)
import Parser exposing ((|.), (|=), Parser, Step(..), end, int, loop, map, oneOf, succeed, symbol)
import ParserHelpers exposing (runOnList)



-- STRUCTS


type alias Packet =
    List PacketContent


type PacketContent
    = Simple Int
    | Composed Packet



-- SOLUTION


part1 : List String -> String
part1 allPackets =
    allPackets
        |> greedyGroupsOf 3
        |> List.map (String.join "\n")
        |> runOnList packetPairParser
        |> List.indexedMap (\i ( a, b ) -> ( i + 1, comparePacket a b ))
        |> List.filterMap filterComparaison
        |> List.sum
        |> String.fromInt


part2 : List String -> String
part2 allPackets =
    allPackets
        |> greedyGroupsOf 3
        |> List.map (String.join "\n")
        |> runOnList packetPairParser
        |> List.foldl concatPacket []
        |> List.append dividerPackets
        |> List.sortWith comparePacket
        |> findIndices isDividerPacket
        |> List.map ((+) 1)
        |> List.product
        |> String.fromInt


filterComparaison : ( Int, Order ) -> Maybe Int
filterComparaison ( i, o ) =
    if o /= GT then
        Just i

    else
        Nothing


isDividerPacket : Packet -> Bool
isDividerPacket packet =
    List.any (\v -> v == packet) dividerPackets


dividerPackets : List Packet
dividerPackets =
    [ [ Composed [ Simple 2 ] ], [ Composed [ Simple 6 ] ] ]


concatPacket : ( Packet, Packet ) -> List Packet -> List Packet
concatPacket ( a, b ) acc =
    a :: b :: acc


comparePacket : Packet -> Packet -> Order
comparePacket a b =
    case ( a, b ) of
        ( [], [] ) ->
            EQ

        ( _, [] ) ->
            GT

        ( [], _ ) ->
            LT

        ( x :: xs, y :: ys ) ->
            let
                cmp =
                    comparePacketContent ( x, y )
            in
            if cmp /= EQ then
                cmp

            else
                comparePacket xs ys


comparePacketContent : ( PacketContent, PacketContent ) -> Order
comparePacketContent content =
    case content of
        ( Simple a, Simple b ) ->
            compare a b

        ( Composed a, Composed b ) ->
            comparePacket a b

        ( Simple a, Composed b ) ->
            comparePacket [ Simple a ] b

        ( Composed a, Simple b ) ->
            comparePacket a [ Simple b ]


packetPairParser : Parser ( Packet, Packet )
packetPairParser =
    succeed Tuple.pair |= packetParser |. symbol "\n" |= packetParser |. oneOf [ symbol "\n", end ]


packetParser : Parser Packet
packetParser =
    loop [] packetParserHelper


packetParserHelper : Packet -> Parser (Step Packet Packet)
packetParserHelper acc =
    oneOf
        [ succeed (\packet -> Loop (packet :: acc)) |= packetContentParser |. oneOf [ symbol ",", symbol "" ]
        , succeed () |> map (\_ -> Done (List.reverse acc))
        ]


packetContentParser : Parser PacketContent
packetContentParser =
    oneOf
        [ succeed Simple |= int
        , succeed Composed |. symbol "[" |= packetParser |. symbol "]"
        ]



-- RUN


main =
    Helpers.solve part1 part2
