import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day24.Day24
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay24 {

    private val instance = Day24(readFile(24))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("47666458872582", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("dnt,gdf,gwc,jst,mcm,z05,z15,z30", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
