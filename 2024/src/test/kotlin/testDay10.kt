import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day10.Day10
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay10 {

    private val instance = Day10(readFile(10))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("538", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("1110", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
