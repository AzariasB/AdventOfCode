package eu.azariasb.adventofocde.days.day20

import utils.Dijkstra
import utils.Point
import utils.toGrid

class Day20(input: String) {
    private val map = input.lines().toGrid()
    private val height = input.lines().size - 2
    private val width = input.lines().first().length - 2
    private val start = map.firstNotNullOf { if (it.value == 'S') it.key else null }
    private val end = map.firstNotNullOf { if (it.value == 'E') it.key else null }
    private val shortestNoCheat by lazy {
        Dijkstra.findPath(
            start,
            end,
            { it },
        ) { pos -> pos.neighbors().filter { map[it] != '#' } } ?: throw Exception("No path found")
    }
    private val fastFind by lazy {
        shortestNoCheat.path.withIndex().associate { it.value to it.index }
    }

    fun solve1() = shortestNoCheat.path.sumOf { pos ->
        Point.DIRECTIONS.count { dir ->
            val search = pos + (dir * 2)
            if (map[pos + dir] == '#' && map.getOrDefault(search, '#') != '#') {
                val diff = fastFind[search] ?: throw Exception("Found shortcut outside of standard path")
                val min = fastFind[pos]!! + 100
                diff > min
            } else {
                false
            }
        }
    }

    private fun accessibles(start: Point): Int {
        val startDist = fastFind[start]!!
        return (maxOf(1, start.y - 20)..minOf(height, start.y + 20)).sumOf { y ->
            (maxOf(1, start.x - 20)..minOf(width, start.x + 20)).count { x ->
                val pos = Point(x, y)
                val dist = pos.manhatanDistance(start)
                dist <= 20 && map[pos] != '#' && fastFind[pos]!! - startDist - dist >= 100
            }
        }
    }

    fun solve2() = shortestNoCheat.path.dropLast(100).sumOf { pos ->
        accessibles(pos)
    }
}