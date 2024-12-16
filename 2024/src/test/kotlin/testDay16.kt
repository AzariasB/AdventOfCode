import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day16.Day16
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay16 {

    private val instance = Day16(readFile(16))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("101492", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("543", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
