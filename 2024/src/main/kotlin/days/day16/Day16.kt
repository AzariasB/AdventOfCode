package eu.azariasb.adventofocde.days.day16

import utils.Point
import utils.toGrid

class Day16(input: String) {

    private data class State(val position: Point, val dir: Point, val score: Long, val path: Set<Point>)

    private val map = input.lines().toGrid()
    private val end = Point(input.lineSequence().first().lastIndex - 1, 1)
    private val start = Point(1, input.lineSequence().count() - 2)

    fun solve1(): Any {
        val queue = ArrayDeque<State>().also {
            it.add(State(start, Point.EAST, 0, setOf()))
        }
        val bestScores = mutableMapOf<Point, Long>()
        while (queue.isNotEmpty()) {
            val current = queue.removeFirst()
            val bst = bestScores.merge(current.position, current.score, ::minOf)!!
            if (bst < current.score) {
                continue
            }

            val nxHist = current.path + current.position
            Point.DIRECTIONS.forEach { dir ->
                val nextPos = current.position + dir
                val value = map[nextPos] ?: return@forEach
                if (value != '#' && !nxHist.contains(nextPos)) {
                    queue.add(
                        State(
                            nextPos,
                            dir,
                            current.score + if (dir == current.dir) 1 else 1001,
                            nxHist
                        )
                    )
                }
            }
        }
        return bestScores[end] ?: throw IllegalStateException("No path found")
    }

    fun solve2(): Any {
        val queue = ArrayDeque<State>().also {
            it.add(State(start, Point.EAST, 0, setOf(start)))
        }
        val bestScores = mutableMapOf<Point, Long>()
        val finalPaths = mutableListOf<State>()
        while (queue.isNotEmpty()) {
            val current = queue.removeFirst()
            if (current.position == end) {
                finalPaths.firstOrNull()?.let { ex ->
                    if (current.score < ex.score) {
                        finalPaths.clear()
                        finalPaths.add(current)
                    } else if (current.score == ex.score) {
                        finalPaths.add(current)
                    } else {
                        // current.score > ex.score -> discard it
                    }
                } ?: kotlin.run {
                    finalPaths.add(current)
                }
                continue
            }
            val bst = bestScores.merge(current.position, current.score, ::minOf)!!

            if (bst < (current.score - 1000)) {
                continue
            }

            val path = current.path + current.position

            Point.DIRECTIONS.forEach { dir ->
                if (dir.isOppositeOf(current.dir)) return@forEach
                val nextPos = current.position + dir
                val value = map[nextPos] ?: return@forEach
                if (value != '#' && !current.path.contains(nextPos)) {
                    if (current.dir == dir) {
                        queue.add(
                            State(
                                nextPos,
                                dir,
                                current.score + 1,
                                path
                            )
                        )
                    } else {
                        queue.add(
                            State(
                                nextPos,
                                dir,
                                current.score + 1001,
                                path
                            )
                        )
                    }

                }
            }
        }

        return finalPaths.flatMapTo(mutableSetOf()) { it.path }.size + 1
    }

}
