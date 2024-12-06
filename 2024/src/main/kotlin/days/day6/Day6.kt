package eu.azariasb.adventofocde.days.day6

import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.count
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.runBlocking
import utils.Point

class Day6(input: String) {

    private val grid = input.lines()
    private val start = grid.withIndex().firstNotNullOf { (y, row) ->
        val x = row.indexOf('^')
        if (x >= 0) Point(x, y) else null
    }
    private val mGrid = grid.toMutableList()

    private val first by lazy {
        grid.walk(start).mapTo(mutableSetOf()) { it.first }
    }

    fun solve1() = first.size.toString()

    fun solve2() = runBlocking {
        val visited = mutableSetOf<Pair<Point, Point>>()
        first.asFlow().drop(1).count { (x, y) ->
            val original = grid[y]
            visited.clear()
            mGrid[y] = StringBuilder(original).apply { set(x, '#') }.toString()
            val res = !mGrid.walk(start).all(visited::add)
            mGrid[y] = original
            res
        }.toString()
    }

    companion object {
        private fun List<String>.walk(position: Point) = sequence {
            var (x, y) = position
            var dy = -1
            var dx = 0
            while (true) {
                yield(Pair(Point(x, y), Point(dx, dy)))
                val nextY = y + dy
                val nextX = x + dx
                when (getOrNull(nextY)?.getOrNull(nextX)) {
                    null -> break
                    '#' -> dy = dx.also { dx = -dy }
                    else -> {
                        y = nextY
                        x = nextX
                    }
                }
            }
        }
    }

}
