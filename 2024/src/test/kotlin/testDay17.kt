import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day17.Day17
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay17 {

    private val instance = Day17(readFile(17))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("6,5,7,4,5,7,3,1,0", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("105875099912602", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
