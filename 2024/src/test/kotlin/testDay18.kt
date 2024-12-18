import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day18.Day18
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay18 {

    private val instance = Day18(readFile(18))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("312", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("28,26", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
