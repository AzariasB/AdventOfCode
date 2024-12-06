import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day1.Day1
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue


class TestDay1 {

    private val instance = Day1(readFile(1))

    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("1388114", res)
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
          instance.solve2()
        }
        assertEquals("23529853", res)
        println("Part 2 - Time taken: $timeTaken")

    }
}
