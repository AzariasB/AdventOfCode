package eu.azariasb.adventofocde.utils

import java.io.File

object FileParser {
    fun fileFromResources(day: Int): File {
        return File(
            javaClass.classLoader.getResource(
                "$day.txt"
            )?.toURI()
                ?: error("Input for day $day not found!")
        )
    }
}

fun readFile(day: Int): List<String> {
    return FileParser.fileFromResources(day).readLines()
}