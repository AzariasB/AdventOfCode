package eu.azariasb.adventofocde.days.day12

import utils.Point
import utils.toGrid

typealias Border = Pair<Point, Point>

class Day12(input: String) {

    val map = input.lines().toGrid()

    private fun floodFill(point: Point): Pair<Set<Border>, Set<Point>> {
        val chr = map[point] ?: throw IllegalStateException("No flood fill found for $point")
        val queue = ArrayDeque<Point>().also { it.add(point) }
        val insides = mutableSetOf(point)
        return (buildSet {
            while (queue.isNotEmpty()) {
                val current = queue.removeFirst()
                for (d in Point.DIRECTIONS) {
                    val nxt = d + current
                    val value = map[nxt]
                    when (value) {
                        null -> {
                            add(nxt to d)
                            continue
                        }

                        chr -> {
                            if (insides.add(nxt)) queue.add(nxt)
                        }

                        else -> add(nxt to d)
                    }
                }
            }
        } to insides)
    }

    private fun uniqueSides(borders: Map<Point, List<Border>>) = borders.entries.sumOf { (key, value) ->
        1 + value.map { (a, _) -> (a.x * key.y + a.y * key.x) / (key.x + key.y) }
            .sorted()
            .zipWithNext()
            .sumOf { (a, b) -> (if (b - a > 1) 1 as Int else 0) }
    }

    private fun solve(borderCalc: (Set<Border>) -> Int): Any {
        val queue = ArrayDeque<Point>().also { it.add(Point(0, 0)) }
        val visited = mutableSetOf<Point>()
        var fencingPrice = 0
        while (queue.isNotEmpty()) {
            val current = queue.removeFirst()
            if (!visited.add(current)) continue
            val (borders, insides) = floodFill(current)
            fencingPrice += insides.size * borderCalc(borders)
            visited += insides
            queue.addAll(borders.filter { (b, _) -> map.contains(b) && !visited.contains(b) }.map { it.first })
        }
        return fencingPrice
    }

    fun solve1() = solve { it.size }

    fun solve2() = solve {
        uniqueSides(it.groupBy { (b, d) ->
            Point(
                (b.x + 2) * d.x,
                (b.y + 2) * d.y
            )
        })
    }

}
