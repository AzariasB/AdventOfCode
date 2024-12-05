package eu.azariasb.adventofocde.days.day2

import kotlin.math.absoluteValue
import kotlin.math.sign

class Day2 {


    fun solve1(input: List<String>): String {
        return input.count { vals -> isSafe(vals.split(' ').map(String::toInt)) }.toString()
    }

    private fun isSafe(lst: List<Int>): Boolean {
        val sign = lst.windowed(2).sumOf { pairs -> (pairs[1] - pairs[0]).sign }.sign
        return lst.windowed(2).all { vals ->
            val diff = (vals[1] - vals[0])
            val aDiff = diff.absoluteValue
            aDiff in 1..3 && diff.sign == sign
        }
    }

    private fun isSafeWithDampener(report: List<Int>): Boolean {
        val sign = report.windowed(2).sumOf { pairs -> (pairs[1] - pairs[0]).sign }.sign
        for ((i, v) in report.drop(1).withIndex()) {
            val diff = v - report[i]
            if (diff.sign != sign || diff.absoluteValue !in 1..3) {
                val mut = report.toMutableList()
                val mut2 = report.toMutableList()
                mut.removeAt(i)
                mut2.removeAt(i + 1)
                return isSafe(mut) || isSafe(mut2)
            }
        }
        return true
    }

    fun solve2(input: List<String>): String {
        return input.count { vals -> isSafeWithDampener(vals.split(' ').map(String::toInt)) }.toString()
    }

}
