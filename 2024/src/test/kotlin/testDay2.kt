import eu.azariasb.adventofocde.utils.readFile
import eu.azariasb.adventofocde.days.day2.Day2
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals


class TestDay2 {

    private val instance = Day2()

    private val puzzle = readFile(2)

    @Test
    fun testSolve1() {
        val res = instance.solve1(puzzle)
        assertEquals("", res)
    }

    @Test
    fun testSolve2() {
        val res = instance.solve2(puzzle)
        assertEquals("", res)
    }
}
