package eu.azariasb.adventofocde.days.day22

class Day22(input: String) {

    private data class Range(val a: Int = 0, val b: Int = 0, val c: Int = 0, val d: Int = 0) {
        fun push(value: Int): Range {
            return Range(b, c, d, value)
        }
    }

    val inputs = input.lines().map { line -> line.toInt() }
    val MASK = 16777215

    private fun secret(value: Int): Int {
        val a = ((value shl 6) xor value) and MASK
        val b = ((a shr 5) xor a) and MASK
        val c = ((b shl 11) xor b) and MASK
        return c
    }

    fun solve1() = inputs.sumOf {
        var current = it
        for (i in 1..2000) {
            current = secret(current)
        }
        current.toULong()
    }

    fun solve2() = buildMap<Range, Int> {
        inputs.map {
            var current = it
            var mRange = Range()
            val seenRange = mutableSetOf<Range>()
            for (i in 1..2000) {
                val next = secret(current)
                val price = next % 10
                mRange = mRange.push(price - (current % 10))
                if (i > 3 && seenRange.add(mRange)) {
                    merge(mRange, price, Int::plus)
                }
                current = next
            }
        }
    }.maxOf { it.value }

}