package eu.azariasb.adventofocde.days.day7

import com.google.common.math.LongMath.pow
import kotlin.math.ceil
import kotlin.math.log10

fun canTotalTo1(input: Long, current: Long, operables: List<Long>): Boolean {
    if (current > input) return false
    if (operables.isEmpty()) return input == current
    val nx = operables[0]
    val opsRem = operables.drop(1)
    return canTotalTo1(input, current * nx, opsRem) || canTotalTo1(input, current + nx, opsRem)
}

fun canTotalTo2(input: Long, current: Long, operables: List<Long>): Boolean {
    if (current > input) return false
    if (operables.isEmpty()) return input == current
    val nx = operables[0]
    return operables.drop(1).let {
        canTotalTo2(input, current * nx, it) || canTotalTo2(input, current + nx, it) || canTotalTo2(
            input,
            current * pow( 10, ceil(log10((nx+1).toDouble())).toInt()) + nx,
            it
        )
    }
}

data class Equation(val result: Long, val operables: List<Long>) {

    fun isValid1() = canTotalTo1(result, operables[0], operables.drop(1))

    fun isValid2() = canTotalTo2(result, operables[0], operables.drop(1))
}

class Day7(input: String) {

    private val equations = input.lines().map {
        val (res, ops) = it.split(":")
        val nums = ops.trim().split(" ").map(String::toLong)
        Equation(res.toLong(), nums)
    }

    fun solve1() = equations.filter(Equation::isValid1).sumOf(Equation::result).toString()

    fun solve2() = equations.filter(Equation::isValid2).sumOf(Equation::result).toString()

}
