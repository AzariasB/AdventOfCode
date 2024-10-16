package utils

fun Char.toIntValue(): Int = code - '0'.code

fun Char.toAlphabetIndex(): Int = lowercaseChar() - 'a'

fun List<Char>.asString(): String = joinToString(separator = "")

fun CharArray.asString(): String = String(this)

fun String.count(char: Char): Int = count { it == char }

fun List<String>.toGrid() = this
    .flatMapIndexed { col, line ->
        line.mapIndexed { row, char ->
            Point(row, col) to char
        }
    }
    .associate { it }