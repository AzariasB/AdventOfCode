package eu.azariasb.tasks

import java.nio.file.Files
import java.nio.file.Paths

public fun ensureDirExists(dir: String) {
    Files.createDirectories(Paths.get(dir))
}