package eu.azariasb.tasks

import org.gradle.api.DefaultTask
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.TaskAction
import java.io.File

abstract class Scaffold : DefaultTask() {

    @get:Input
    abstract var day: Int

    companion object {
        const val CLASS_TEMPLATE = """package eu.azariasb.adventofocde.days.day{0}

class Day{0}(input: String) {

    fun solve1(): String {
    
        return ""
    }
    
    fun solve2(): String {

        return ""
    }

}
"""

        const val TEST_TEMPLATE = """import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day{0}.Day{0}
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay{0} {

    private val instance = Day{0}(readFile({0}))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("", res)
        println("Part 1 - Time taken: ${'$'}timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("", res)
        println("Part 2 - Time taken: ${'$'}timeTaken")
    }
}
"""

    }

    @TaskAction
    fun scaffold() {
        val projectRoot = System.getProperty("user.dir")

        val mainCode = CLASS_TEMPLATE.replace("{0}", day.toString())
        val mainPath = "$projectRoot/src/main/kotlin/days/day$day"
        ensureDirExists(mainPath)

        val mainTarget = File("$mainPath/Day$day.kt")
        if(mainTarget.exists()) {
            println("File Day$day.kt already exist, skipping")
        } else {
            mainTarget.writeText(mainCode)
        }

        val testCode = TEST_TEMPLATE.replace("{0}", day.toString())
        File("$projectRoot/src/test/kotlin/testDay$day.kt").writeText(testCode)
    }


}
