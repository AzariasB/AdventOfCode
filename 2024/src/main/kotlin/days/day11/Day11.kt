package eu.azariasb.adventofocde.days.day11

import com.google.common.math.IntMath
import kotlin.math.ceil
import kotlin.math.log10


class Day11(input: String) {

    private val stones = input.split(" ").map(String::toLong)
    private val memo = mutableMapOf<Pair<Long, Int>, Long>()

    private fun stoneCountAfter(value: Long, loop: Int): Long {
        if (loop == 0) return 1L
        val key = value to loop
        return memo[key] ?: kotlin.run {
            if (value == 0L) stoneCountAfter(1, loop - 1) else {
                val digits = ceil(log10((value + 1).toFloat())).toInt()
                if (digits and 1 == 0) {
                    val half = IntMath.pow(10, digits / 2)
                    val left = value / half
                    val right = value % half
                    stoneCountAfter(left, loop - 1) + stoneCountAfter(right, loop - 1)
                } else {
                    stoneCountAfter(value * 2024L, loop - 1)
                }
            }
        }.also { memo[key] = it }
    }

    fun solve1() = stones.sumOf { stoneCountAfter(it, 25) }

    fun solve2() = stones.sumOf { stoneCountAfter(it, 75) }

}
