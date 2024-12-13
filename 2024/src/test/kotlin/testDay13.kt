import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day13.Day13
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay13 {

    private val instance = Day13(readFile(13))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("37686", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("77204516023437", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
