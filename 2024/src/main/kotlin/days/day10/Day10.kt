package eu.azariasb.adventofocde.days.day10

import utils.Point
import utils.toGrid

class Day10(input: String) {

    private val map = input.lines().toGrid().mapValues { it.value.digitToInt() }
    private val trailHeads = map.filter { it.value == 0 }.keys

    /**
     * Little optimized version
     * Instead of creating a new set for every new solution,
     * only create a set at the start, and fill it as the program goes
     * Also use a mutable set for the visited states instead of creating a new one for each sub-solution
     * Add before calling recursive, remove once the function is done
     */
    private fun accessibleNines(history: MutableSet<Point>, current: Point, prev: Int, finals: MutableSet<Point>) {
        val pos = map[current] ?: return
        if ((pos - prev) != 1 || current in history) return
        if (pos == 9) return finals.add(current).let { }
        history.add(current)
        accessibleNines(history, current + Point.NORTH, pos, finals)
        accessibleNines(history, current + Point.SOUTH, pos, finals)
        accessibleNines(history, current + Point.WEST, pos, finals)
        accessibleNines(history, current + Point.EAST, pos, finals)
        history.remove(current)
    }

    private fun waysOfAccessingNines(history: Set<Point>, current: Point, prev: Int): Int {
        val pos = map[current] ?: return 0
        if ((pos - prev) != 1 || current in history) return 0
        if (pos == 9) return 1
        val nxHist = history + current
        return waysOfAccessingNines(nxHist, current + Point.NORTH, pos) + waysOfAccessingNines(
            nxHist,
            current + Point.SOUTH,
            pos
        ) + waysOfAccessingNines(nxHist, current + Point.WEST, pos) + waysOfAccessingNines(
            nxHist,
            current + Point.EAST,
            pos
        )
    }

    fun solve1() = trailHeads.sumOf {
        val finals = mutableSetOf<Point>()
        accessibleNines(mutableSetOf(), it, -1, finals)
        finals.size
    }

    fun solve2() = trailHeads.sumOf { waysOfAccessingNines(setOf(), it, -1) }

}
