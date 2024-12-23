import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day23.Day23
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.time.measureTimedValue

class TestDay23 {

    private val instance = Day23(readFile(23))


    @Test
    fun testSolve1() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve1()
        }
        assertEquals("1308", "$res")
        println("Part 1 - Time taken: $timeTaken")
    }

    @Test
    fun testSolve2() {
        val (res, timeTaken) = measureTimedValue {
            instance.solve2()
        }
        assertEquals("bu,fq,fz,pn,rr,st,sv,tr,un,uy,zf,zi,zy", "$res")
        println("Part 2 - Time taken: $timeTaken")
    }
}
