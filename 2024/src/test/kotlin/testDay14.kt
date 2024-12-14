import eu.azariasb.adventofocde.days.day14.Day14
import eu.azariasb.adventofocde.utils.readFile
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay14 {

    private val instance = Day14(readFile(14))

    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("228421332", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("7790", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
