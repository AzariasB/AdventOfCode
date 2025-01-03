import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day25.Day25
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay25 {

    private val instance = Day25(readFile(25))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("3451", "$res")
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
