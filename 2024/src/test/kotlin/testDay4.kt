import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day4.Day4
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay4 {

    private val instance = Day4(readFile(4))

    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("2543", res)
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("1930", res)
        println("Part 2 - Time taken: $timeTaken")
    }
}
