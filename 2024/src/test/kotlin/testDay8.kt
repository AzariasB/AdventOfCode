import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day8.Day8
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay8 {

    private val instance = Day8(readFile(8))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("394", res)
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("1277", res)
        println("Part 2 - Time taken: $timeTaken")
    }
}
