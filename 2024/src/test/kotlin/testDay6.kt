import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day6.Day6
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay6 {

    private val instance = Day6(readFile(6))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("5516", res)
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("2008", res)
        println("Part 2 - Time taken: $timeTaken")
    }
}
