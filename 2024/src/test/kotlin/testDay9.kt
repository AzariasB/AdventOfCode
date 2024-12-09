import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day9.Day9
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay9 {

    private val instance = Day9(readFile(9))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("6337921897505", res)
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("6362722604045", res)
        println("Part 2 - Time taken: $timeTaken")
    }
}
