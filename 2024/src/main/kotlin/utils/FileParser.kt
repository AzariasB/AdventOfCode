package eu.azariasb.adventofocde.utils

import java.io.File

object FileParser {
    fun fileFromResources(day: Int): File {
        return File(
            javaClass.classLoader.getResource(
                "${day.toString().padStart(2, '0')}.txt"
            )?.toURI()
                ?: error("Input for day $day not found!")
        )
    }
}

fun readFile(day: Int): String {
    return FileParser.fileFromResources(day).readText().trim()
}