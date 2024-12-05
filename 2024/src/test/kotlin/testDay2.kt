import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day2.Day2
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay2 {

    private val instance = Day2()

    private val puzzle = readFile(2)

    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1(puzzle)
        }
        assertEquals("230", res)
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2(puzzle)
        }
        assertEquals("301", res)
        println("Part 2 - Time taken: $timeTaken")
    }
}
