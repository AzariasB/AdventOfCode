package eu.azariasb.adventofocde.days.day8

import utils.Point
import utils.toGrid

class Day8(input: String) {

    val lines = input.lines()

    val antenas =
        lines.toGrid().filter { it.value != '.' }
            .map { it.value to it.key }
            .groupBy { it.first }
            .mapValues {
                it.value.map { p -> p.second }
            }
            .filter { it.value.size > 1 }
    val validX = lines.first().indices
    val validY = lines.indices

    private fun antinodes(nodes: List<Point>, saved: MutableSet<Point>) {
        for (x1 in 0 until nodes.lastIndex) {
            for (x2 in (x1 + 1)..nodes.lastIndex) {
                val p1 = nodes[x1]
                val p2 = nodes[x2]
                val xDist = p1.x - p2.x
                val yDist = p1.y - p2.y
                val nxPoint1 = p1.x + xDist
                val nyPoint1 = p1.y + yDist
                if (nxPoint1 in validX && nyPoint1 in validY) {
                    saved.add(Point(nxPoint1, nyPoint1))
                }
                val nxPoint2 = p2.x - xDist
                val nyPoint2 = p2.y - yDist
                if (nxPoint2 in validX && nyPoint2 in validY) {
                    saved.add(Point(nxPoint2, nyPoint2))
                }
            }
        }
    }

    private fun antinodes2(nodes: List<Point>, saved: MutableSet<Point>) {
        for (x1 in 0 until nodes.lastIndex) {
            for (x2 in (x1 + 1)..nodes.lastIndex) {
                val p1 = nodes[x1]
                val p2 = nodes[x2]
                val xDist = p1.x - p2.x
                val yDist = p1.y - p2.y
                var nxPoint = p1.x
                var nyPoint = p1.y
                while (nxPoint in validX && nyPoint in validY) {
                    saved.add(Point(nxPoint, nyPoint))
                    nxPoint += xDist
                    nyPoint += yDist
                }
                nxPoint = p2.x
                nyPoint = p2.y
                while (nxPoint in validX && nyPoint in validY) {
                    saved.add(Point(nxPoint, nyPoint))
                    nxPoint -= xDist
                    nyPoint -= yDist
                }
            }
        }
    }

    fun solve1(): String {
        val cache = mutableSetOf<Point>()
        antenas.values.forEach { a -> antinodes(a, cache) }
        return cache.size.toString()
    }

    fun solve2(): String {
        val cache = mutableSetOf<Point>()
        antenas.values.forEach { a -> antinodes2(a, cache) }
        return cache.size.toString()
    }

}
