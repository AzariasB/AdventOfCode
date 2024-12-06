package eu.azariasb.adventofocde.days.day1

import com.google.common.collect.TreeMultiset
import kotlin.math.absoluteValue

class Day1(puzzle: String) {

    private val left: TreeMultiset<Int> = TreeMultiset.create()
    private val right: TreeMultiset<Int> = TreeMultiset.create()

    private val left2 = mutableListOf<Int>()
    private val right2 = mutableMapOf<Int, Int>()


    init {
        for (line in puzzle.lines()) {
            val (l, r) = line.split("   ")
            left.add(l.toInt())
            right.add(r.toInt())
        }

        for (line in puzzle.lines()) {
            val (l, r) = line.split("   ")
            left2.addLast(l.toInt())
            right2.merge(r.toInt(), 1, Int::plus)
        }
    }

    fun solve1(): String {
        return left.zip(right).sumOf { (a, b) -> (a - b).absoluteValue }.toString()
    }

    fun solve2(): String {
        return left2.sumOf { l -> right2.getOrDefault(l, 0) * l }.toString()
    }

}
