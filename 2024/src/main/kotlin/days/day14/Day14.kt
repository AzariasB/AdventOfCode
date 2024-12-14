package eu.azariasb.adventofocde.days.day14

import eu.azariasb.adventofocde.utils.readFile
import utils.Point
import java.lang.Thread.sleep

data class Robot(val position: Point, val direction: Point) {
    fun positionAfterMove(move: Int, limit: Point): Point {
        return ((position + (direction * move)) % limit).let {
            Point((it.x + limit.x) % limit.x, (it.y + limit.y) % limit.y)
        }
    }
}

class Day14(input: String) {

    private val robots = input.lineSequence().map { line ->
        val (p, d) = line
            .split(" ")
            .map { it.substring(2).split(",").map { it.toInt() } }
        Robot(Point(p[0], p[1]), Point(d[0], d[1]))
    }

    private fun quadrant(point: Point, middle: Point): Int? {
        return when {
            point.x == middle.x || point.y == middle.y -> null
            point.y < middle.y -> if (point.x < middle.x) 0 else 1
            else -> if (point.x < middle.x) 2 else 3
        }
    }

    fun solve1(): Any {
        val limit = Point(101, 103)
        val middle = (limit - Point(1, 1)) / 2
        return robots.mapNotNull { robot -> quadrant(robot.positionAfterMove(100, limit), middle) }
            .groupBy { it }.values.fold(1) { acc, list -> acc * list.size }
    }

    /**
     * There are mathematical ways of solving this using the variance of the points
     * and detecting when a cluster of robots is formed
     * But I wanted to have a little "animation" of the robots playing
     * so here goes nothing
     */
    fun solve2(): Any {
        val limit = Point(101, 103)
        for (i in (1..(limit.x * limit.y))) {
            val grid = List(limit.y) { StringBuilder(".".repeat(limit.x)) }
            robots.map { robot -> robot.positionAfterMove(i, limit) }.forEach { grid[it.y][it.x] = '#' }
            val fullString = grid.joinToString("\n")
            if (fullString.contains("###############################")) {
                println("SECOND $i\n$fullString")
                return i
            }
        }
        return 0
    }

}
