module Day7 exposing (part1, part2)

import Helpers
import List.Extra exposing (takeWhile)
import Parser exposing ((|.), (|=), Parser, Step(..), end, int, loop, map, oneOf, spaces, succeed, symbol, variable)
import ParserHelpers exposing (runOnList, string)
import Set



-- STRUCTS


type alias FileData =
    { size : Int, name : String }


type alias DirectoryData =
    { name : String, files : List Tree }


type File
    = PlainFile FileData
    | Directory String


type Command
    = ChangeDirectory String
    | ListContent (List File)


type Tree
    = DirNode DirectoryData
    | FileNode FileData


type FolderSize
    = Valid Int
    | Invalid (List Int)



-- SOLUTION


part1 : List String -> String
part1 commands =
    let
        parseHistory str =
            case Parser.run historyParser str of
                Ok res ->
                    res

                Err err ->
                    let
                        msg =
                            Debug.log "error" err
                    in
                    Debug.todo "Failed to parse commands"
    in
    commands
        |> String.join "\n"
        |> parseHistory
        |> commandsToTree []
        |> Debug.log "tree is "
        |> sizeFilter
        |> Debug.log "size filer is "
        |> (\size ->
                case size of
                    Valid v ->
                        v

                    Invalid v ->
                        List.sum v
           )
        |> String.fromInt


part2 : List String -> String
part2 _ =
    "TODO"


commandsToTree : List Tree -> List Command -> List Tree
commandsToTree node commands =
    let
        ( trees, rest ) =
            process node commands
    in
    case rest of
        [] ->
            trees

        xs ->
            commandsToTree trees xs


process : List Tree -> List Command -> ( List Tree, List Command )
process acc commands =
    case commands of
        [] ->
            ( acc, [] )

        c :: xs ->
            case c of
                ChangeDirectory dir ->
                    if dir == ".." then
                        ( acc, xs )

                    else
                        let
                            ( subDir, rest ) =
                                process [] xs
                        in
                        ( DirNode { name = dir, files = subDir } :: acc, rest )

                ListContent content ->
                    let
                        files =
                            List.filterMap
                                (\node ->
                                    case node of
                                        PlainFile data ->
                                            Just <| FileNode data

                                        _ ->
                                            Nothing
                                )
                                content
                    in
                    process files xs


sizeSum : FolderSize -> Int
sizeSum size =
    case size of
        Valid val ->
            val

        Invalid val ->
            List.sum val


isInvalid : FolderSize -> Bool
isInvalid size =
    case size of
        Invalid _ ->
            True

        _ ->
            False


sizeFilter : List Tree -> FolderSize
sizeFilter xs =
    case xs of
        [] ->
            Valid 0

        total ->
            let
                foldersSize =
                    Debug.log "folder size is" <|
                        List.filterMap
                            (\f ->
                                case f of
                                    DirNode dir ->
                                        Just <| sizeFilter dir.files

                                    _ ->
                                        Nothing
                            )
                            total

                validFolders =
                    List.map
                        (\f ->
                            case f of
                                Invalid res ->
                                    res

                                Valid value ->
                                    [ value ]
                        )
                        foldersSize
                        |> List.concat

                hasInvalids =
                    List.any isInvalid foldersSize
            in
            if hasInvalids then
                Invalid validFolders

            else
                let
                    filesSize =
                        List.filterMap
                            (\f ->
                                case f of
                                    FileNode file ->
                                        Just file.size

                                    _ ->
                                        Nothing
                            )
                            total
                            |> List.sum

                    myTotalSize =
                        filesSize
                            + (List.map
                                (\f ->
                                    case f of
                                        Valid v ->
                                            v

                                        _ ->
                                            0
                                )
                                foldersSize
                                |> List.sum
                              )
                in
                if myTotalSize <= 100000 then
                    Valid myTotalSize

                else
                    Invalid validFolders


historyParser : Parser (List Command)
historyParser =
    loop [] commandParserHelper


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
