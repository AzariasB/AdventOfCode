import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day22.Day22
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay22 {

    private val instance = Day22(readFile(22))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("14082561342", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("1568", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
