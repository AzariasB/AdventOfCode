import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day19.Day19
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay19 {

    private val instance = Day19(readFile(19))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("347", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("919219286602165", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
