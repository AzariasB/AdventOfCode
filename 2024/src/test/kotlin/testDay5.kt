import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day5.Day5
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay5 {

    private val instance = Day5(readFile(5))

    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("4790", res)
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("6319", res)
        println("Part 2 - Time taken: $timeTaken")
    }
}
