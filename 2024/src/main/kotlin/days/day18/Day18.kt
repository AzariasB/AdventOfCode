package eu.azariasb.adventofocde.days.day18

import utils.Dijkstra
import utils.Point

class Day18(input: String) {

    val bytes = input.lineSequence().map { line ->
        val (x, y) = line.split(",").map(String::toInt)
        Point(x, y)
    }.toList()

    fun solve1(): Any {
        val selectedBytes = bytes.take(1024).toSet()
        val mapRange = 0..70
        val path = Dijkstra.findPath(
            Point(0, 0),
            Point(70, 70),
            { it },
            { p ->
                val res = p.neighbors().filter {
                    it.x in mapRange && it.y in mapRange && it !in selectedBytes
                }
                res
            }
        ) ?: throw Exception("No path found")
        return path.steps
    }

    fun solve2(): Any {
        val mapRange = 0..70
        val start = Point(0, 0)
        val end = Point(70, 70)
        val id = { t: Any -> t }
        val part1Bytes = bytes.take(1024).toSet()
        var currentPath = Dijkstra.findPath(
            start,
            end,
            id
        ) { p ->
            val res = p.neighbors().filter {
                it.x in mapRange && it.y in mapRange && it !in part1Bytes
            }
            res
        }?.path?.toSet() ?: throw Exception("No path found")
        for (i in 1025..bytes.count()) {
            val nxtPoint = bytes[i]
            if (nxtPoint in currentPath) {
                val selectedBytes = bytes.take(i).toSet()
                currentPath = Dijkstra.findPath(
                    start,
                    end,
                    id
                ) { p ->
                    val res = p.neighbors().filter {
                        it.x in mapRange && it.y in mapRange && it !in selectedBytes
                    }
                    res
                }?.path?.toSet() ?: return selectedBytes.last().let { "${it.x},${it.y}" }
            }

        }
        throw Exception("Nothing is blocking the path")
    }

}
