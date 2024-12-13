package eu.azariasb.adventofocde.days.day13

data class MachineMatrix(val a: Long, val c: Long, val b: Long, val d: Long, val x: Long, val y: Long) {

    private val div = a * d - b * c

    private fun inv(toInv: Long) = if (toInv % div == 0L) toInv / div else null

    fun solve(add: Long): Long {
        val buttonA = inv((x + add) * d + (y + add) * -c) ?: return 0L
        val buttonB = inv((x + add) * -b + (y + add) * a) ?: return 0L
        return buttonA * 3L + buttonB
    }
}

class Day13(input: String) {

    companion object {
        val buttonRegex = Regex("""Button [AB]: X\+(\d+), Y\+(\d+)""")
        val prizeRegex = Regex("""Prize: X=(\d+), Y=(\d+)""")
    }

    private val machines = input.split("\n\n").mapNotNull { configs ->
        val (a, b, x) = configs.split("\n", limit = 3)
        val aVals = buttonRegex.find(a)?.groupValues ?: return@mapNotNull null
        val bVals = buttonRegex.matchEntire(b)?.groupValues ?: return@mapNotNull null
        val prizes = prizeRegex.matchEntire(x)?.groupValues ?: return@mapNotNull null
        MachineMatrix(
            aVals[1].toLong(), bVals[1].toLong(),
            aVals[2].toLong(), bVals[2].toLong(),
            prizes[1].toLong(), prizes[2].toLong()
        )
    }

    fun solve1() = machines.sumOf { it.solve(0L) }

    fun solve2() = machines.sumOf { it.solve(10000000000000L) }

}
