import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day12.Day12
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay12 {

    private val instance = Day12(readFile(12))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("1483212", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("897062", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
