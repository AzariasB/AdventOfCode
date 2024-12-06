package eu.azariasb.adventofocde.days.day3

class Day3(puzzle: String) {

    private val input = puzzle.lines().joinToString(" ")

    companion object {
        val MUL_REG = Regex("""mul\((\d{1,3}),(\d{1,3})\)""")
        val FORMUL_REG = Regex("""mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)""")
    }

    fun solve1(): String {
        return MUL_REG.findAll(input).sumOf { mul ->
            mul.groupValues[1].toInt() * mul.groupValues[2].toInt()
        }.toString()
    }

    fun solve2(): String {
        var toggle = true;
        return FORMUL_REG.findAll(input).sumOf { op ->
            if (op.value.startsWith("do") || !toggle) {
                toggle = op.value == "do()"
                0
            } else {
                op.groupValues[1].toInt() * op.groupValues[2].toInt()
            }
        }.toString()
    }

}
