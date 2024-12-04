package eu.azariasb.adventofocde.days.day1

import com.google.common.collect.TreeMultiset
import kotlin.math.absoluteValue

class Day1 {

    fun solve1(input: List<String>): String {
        val left = TreeMultiset.create<Int>()
        val right = TreeMultiset.create<Int>()

        for(line in input) {
            val (l, r) = line.split("   ")
            left.add(l.toInt())
            right.add(r.toInt())
        }

        return left.zip(right).sumOf { (a, b) -> (a - b).absoluteValue }.toString()
    }
    
    fun solve2(input: List<String>): String {
        val left = mutableListOf<Int>()
        val right = mutableMapOf<Int, Int>()

        for(line in input) {
            val (l, r) = line.split("   ")
            left.addLast(l.toInt())
            right.merge(r.toInt(), 1, Int::plus)
        }

        return left.sumOf { l -> right.getOrDefault(l, 0) * l }.toString()
    }

}
