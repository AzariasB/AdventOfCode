package utils

fun Char.toIntValue(): Int = code - '0'.code

fun Char.toAlphabetIndex(): Int = lowercaseChar() - 'a'

fun List<Char>.asString(): String = joinToString(separator = "")

fun CharArray.asString(): String = String(this)

fun String.count(char: Char): Int = count { it == char }

fun String.count(sub: String): Int = windowed(sub.length) { if (it == sub) 1 else 0 }.sum()

fun List<String>.toGrid() = this
    .flatMapIndexed { col, line ->
        line.mapIndexed { row, char ->
            Point(row, col) to char
        }
    }
    .associate { it }

fun clearPrint(data: Any) = println("\u001b[H\u001b[2J$data")