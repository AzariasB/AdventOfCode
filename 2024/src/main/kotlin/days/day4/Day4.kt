package eu.azariasb.adventofocde.days.day4


class Day4 {

    /**
     * Using regex for this problem is probably not the most optimized way
     * to do things as we could "simply" loop over the list in various ways
     * to find the patterns we're looking for
     * But this would take much more time and code, so ... no
     */
    fun solve1(input: List<String>): String {
        val equalLength = input[0].length
        val positiveLength = equalLength + 1
        val negativeLength = equalLength - 1

        val test = { count: Int ->
            val vChars = "[XMAS\\n]{$count}"
            "(?=X${vChars}M${vChars}A${vChars}S)|(?=S${vChars}A${vChars}M${vChars}X)"
        }

        val patterns = listOf(
            "(?=SAMX)",
            "(?=XMAS)",
            test(equalLength),
            test(positiveLength),
            test(negativeLength),
        )

        val search = input.joinToString(separator = "\n")
        return "${patterns.sumOf { pat -> Regex(pat).findAll(search).count() }}"
    }

    /**
     * Same thing than for part 1.
     * Using regexp is a luxury and isn't the fastest way to do it
     * But the problem is still solved in under a second. So that's find by me
     */
    fun solve2(input: List<String>): String {
        val equalLength = input[0].length

        val test = { order: Array<Char> ->
            "(?=${order[0]}.${order[1]}[XMAS\\n]{${equalLength - 1}}A[XMAS\\n]{${equalLength - 1}}${order[2]}.${order[3]})"
        }

        val patterns = listOf(
            test(arrayOf('M', 'S', 'M', 'S')),
            test(arrayOf('M', 'M', 'S', 'S')),
            test(arrayOf('S', 'M', 'S', 'M')),
            test(arrayOf('S', 'S', 'M', 'M'))
        )

        val search = input.joinToString(separator = "\n")
        return "${
            patterns.sumOf { pat ->
                Regex(pat).findAll(search).count()
            }
        }"
    }

}
