import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day20.Day20
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay20 {

    private val instance = Day20(readFile(20))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("1307", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("986545", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
