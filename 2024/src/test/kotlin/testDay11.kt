import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day11.Day11
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay11 {

    private val instance = Day11(readFile(11))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("186175", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("220566831337810", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
