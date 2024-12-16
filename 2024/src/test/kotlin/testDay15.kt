import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day15.Day15
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay15 {

    private val instance = Day15(readFile(15))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("1406628", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("1432781", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
