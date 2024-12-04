import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day3.Day3
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay3 {

    private val instance = Day3()

    private val puzzle = readFile(3)

    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1(puzzle)
        }
        assertEquals("175015740", res)
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2(puzzle)
        }
        assertEquals("112272912", res)
        println("Part 2 - Time taken: $timeTaken")
    }
}
