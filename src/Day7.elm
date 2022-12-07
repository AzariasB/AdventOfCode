module Day7 exposing (part1, part2)

import Helpers
import Parser exposing ((|.), (|=), Parser, Step(..), end, int, loop, map, oneOf, spaces, succeed, symbol)
import ParserHelpers exposing (string)



-- STRUCTS


type alias FileData =
    { size : Int, name : String }


type Node
    = Node { data : File, children : List Node }


type File
    = PlainFile FileData
    | Directory String


type Command
    = ChangeDirectory String
    | ListContent (List File)


type NodeType
    = FileType
    | DirectoryType


totalFreeSpace : Int
totalFreeSpace =
    70000000


neededSpace : Int
neededSpace =
    30000000



-- SOLUTION


toFileSystem : List String -> Node
toFileSystem commands =
    let
        parseHistory str =
            case Parser.run historyParser str of
                Ok res ->
                    res

                Err err ->
                    let
                        _ =
                            Debug.log "error" err
                    in
                    Debug.todo "Failed to parse commands"
    in
    commands
        |> String.join "\n"
        |> parseHistory
        |> List.tail
        |> Maybe.withDefault []
        |> commandsToTree (Node { data = Directory "/", children = [] })


part1 : List String -> String
part1 commands =
    commands
        |> toFileSystem
        |> sizeCounter
        |> sizeFilter
        |> String.fromInt


part2 : List String -> String
part2 commands =
    let
        folderSizes =
            commands
                |> toFileSystem
                |> sizeCounter

        ( _, usedSpace, _ ) =
            folderSizes
                |> List.head
                |> Maybe.withDefault ( "", 0, DirectoryType )

        availableSpace =
            totalFreeSpace - usedSpace

        missingSpace =
            neededSpace - availableSpace
    in
    folderSizes
        |> List.filterMap (isBigEnough missingSpace)
        |> List.sort
        |> List.head
        |> Maybe.withDefault 0
        |> String.fromInt


isBigEnough : Int -> ( String, Int, NodeType ) -> Maybe Int
isBigEnough min ( _, value, fileType ) =
    if fileType == DirectoryType && value >= min then
        Just value

    else
        Nothing


sizeFilter : List ( String, Int, NodeType ) -> Int
sizeFilter =
    List.filterMap
        (\( _, size, tp ) ->
            if tp == DirectoryType && size <= 100000 then
                Just size

            else
                Nothing
        )
        >> List.sum


rawNode : Node -> { data : File, children : List Node }
rawNode node =
    case node of
        Node content ->
            content


sizeCounter : Node -> List ( String, Int, NodeType )
sizeCounter node =
    let
        { data, children } =
            rawNode node
    in
    case data of
        PlainFile f ->
            List.singleton ( f.name, f.size, FileType )

        Directory name ->
            let
                allChildren =
                    List.map sizeCounter children |> List.concat

                selfSize =
                    List.filterMap
                        (\( _, size, docType ) ->
                            if docType == FileType then
                                Just size

                            else
                                Nothing
                        )
                        allChildren
                        |> List.sum
            in
            ( name, selfSize, DirectoryType ) :: allChildren


commandsToTree : Node -> List Command -> Node
commandsToTree parent commands =
    let
        ( updatedParent, otherCommands ) =
            process parent commands
    in
    case otherCommands of
        [] ->
            updatedParent

        xs ->
            commandsToTree updatedParent xs


process : Node -> List Command -> ( Node, List Command )
process node commands =
    case commands of
        [] ->
            ( node, [] )

        c :: xs ->
            case c of
                ChangeDirectory dir ->
                    if dir == ".." then
                        ( node, xs )

                    else
                        let
                            parent =
                                rawNode node

                            self =
                                Node { data = Directory dir, children = [] }

                            ( subDir, rest ) =
                                process self xs
                        in
                        process (Node { parent | children = subDir :: parent.children }) rest

                ListContent content ->
                    let
                        parent =
                            rawNode node

                        files =
                            List.filterMap
                                (\file ->
                                    case file of
                                        Directory _ ->
                                            Nothing

                                        fileData ->
                                            Just <| Node { data = fileData, children = [] }
                                )
                                content
                    in
                    process (Node { parent | children = files ++ parent.children }) xs


historyParser : Parser (List Command)
historyParser =
    loop [] commandParserHelper |. end


commandParserHelper : List Command -> Parser (Step (List Command) (List Command))
commandParserHelper acc =
    oneOf
        [ succeed (\command -> Loop (command :: acc)) |= commandParser
        , succeed () |> map (\_ -> Done <| List.reverse acc)
        ]


commandParser : Parser Command
commandParser =
    succeed identity
        |. symbol "$ "
        |= oneOf [ cdParser, lsParser ]


cdParser : Parser Command
cdParser =
    succeed ChangeDirectory
        |. symbol "cd"
        |. spaces
        |= string
        |. oneOf [ symbol "\n", end ]


lsParser : Parser Command
lsParser =
    succeed ListContent
        |. symbol "ls"
        |. spaces
        |= loop [] lsParserHelp


lsParserHelp : List File -> Parser (Step (List File) (List File))
lsParserHelp acc =
    oneOf
        [ succeed (\file -> Loop (file :: acc))
            |= lsLineParser
        , succeed () |> map (\_ -> Done acc)
        ]


lsLineParser : Parser File
lsLineParser =
    oneOf
        [ dirLineParser
        , fileLineParser
        ]
        |. oneOf
            [ symbol "\n"
            , end
            ]


dirLineParser : Parser File
dirLineParser =
    succeed Directory
        |. symbol "dir"
        |. spaces
        |= string


fileLineParser : Parser File
fileLineParser =
    succeed PlainFile
        |= (succeed FileData
                |= int
                |. spaces
                |= string
           )



-- RUN


main =
    Helpers.solve part1 part2
