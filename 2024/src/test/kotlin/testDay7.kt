import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day7.Day7
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay7 {

    private val instance = Day7(readFile(7))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("1038838357795", res)
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("254136560217241", res)
        println("Part 2 - Time taken: $timeTaken")
    }
}
