import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day21.Day21
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay21 {

    private val instance = Day21(readFile(21))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
