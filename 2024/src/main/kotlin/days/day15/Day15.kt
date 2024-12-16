package eu.azariasb.adventofocde.days.day15

import utils.Point

typealias Storage = MutableList<StringBuilder>

operator fun Storage.get(point: Point) = this[point.y].getOrNull(point.x)
operator fun Storage.set(point: Point, value: Char) = this[point.y].set(point.x, value)
fun Storage.findStart() = this.withIndex().firstNotNullOf { (y, value) ->
    value.indexOf('@').let { x -> if (x > -1) Point(x, y) else null }
}

fun Storage.coordinates(ref: Char): Int = this.withIndex().sumOf { (y, l) ->
    l.toString().withIndex().sumOf { (x, c) ->
        if (c == ref) x + y * 100 else 0
    }
}

class Day15(input: String) {

    private data class Move(val possible: Boolean, val execute: () -> Unit = {}) {
        companion object {
            val NO_MOVE = Move(false)
            val YES_MOVE = Move(true)
        }

        fun whenPossible(block: () -> Unit) {
            if (possible) {
                execute()
                block()
            }
        }
    }

    private val almacen1: MutableList<StringBuilder>
    private val start1: Point

    private val almacen2: MutableList<StringBuilder>
    private val start2: Point

    private val directions: List<Point>


    init {
        val (a, b) = input.split("\n\n", limit = 2)
        almacen1 = a.lineSequence().map { StringBuilder(it) }.toMutableList()
        start1 = almacen1.findStart()

        almacen2 = a.lineSequence().map {
            StringBuilder(
                it.replace("#", "##")
                    .replace(".", "..")
                    .replace("@", "@.")
                    .replace("O", "[]")
            )
        }.toMutableList()
        start2 = almacen2.findStart()
        directions = b.replace("\n", "").toCharArray().map { c ->
            when (c) {
                '^' -> Point.NORTH
                'v' -> Point.SOUTH
                '<' -> Point.WEST
                '>' -> Point.EAST
                else -> throw IllegalArgumentException("Invalid grid character '$c'")
            }
        }
    }

    private fun canMoveHere(map: Storage, point: Point, direction: Point): Boolean {
        val chr = map[point] ?: return false
        return when (chr) {
            '.' -> true
            '#' -> false
            'O' -> {
                val target = point + direction
                if (canMoveHere(map, target, direction)) {
                    map[point] = '.'
                    map[target] = 'O'
                    true
                } else {
                    false
                }
            }

            else -> throw IllegalArgumentException("Invalid grid character '$chr'")
        }
    }

    private fun can2MoveHere(map: Storage, point: Point, direction: Point, history: MutableSet<Point>): Move {
        if (point in history) {
            return Move.YES_MOVE
        }
        val chr = map[point] ?: return Move.NO_MOVE

        val moveBigBox = { dir: Point, chr1: Char, chr2: Char ->
            history.add(point)
            history.add(point + dir)
            if (direction == dir) {
                val target = point + direction * 2
                val subMove = can2MoveHere(map, target, direction, history)
                if (subMove.possible) {
                    Move(true) {
                        subMove.execute()
                        map[point] = '.'
                        map[point + direction] = chr1
                        map[target] = chr2
                    }
                } else {
                    Move.NO_MOVE
                }
            } else {
                val target = point + direction
                val p2 = point + dir
                val target2 = p2 + direction
                val m1 = can2MoveHere(map, target, direction, history)
                val m2 = can2MoveHere(map, target2, direction, history)
                if (m1.possible && m2.possible) {
                    Move(true) {
                        m1.execute()
                        m2.execute()
                        map[point] = '.'
                        map[p2] = '.'
                        map[target] = chr1
                        map[target2] = chr2
                    }
                } else {
                    Move.NO_MOVE
                }
            }
        }

        return when (chr) {
            '.' -> Move.YES_MOVE
            '#' -> Move.NO_MOVE
            '[' -> moveBigBox(Point.EAST, '[', ']')
            ']' -> moveBigBox(Point.WEST, ']', '[')
            else -> throw IllegalArgumentException("Invalid grid character '$chr'")
        }
    }

    fun solve1(): Any {
        var current = start1
        directions.forEach { dir ->
            val target = current + dir
            if (canMoveHere(almacen1, target, dir)) {
                almacen1[current] = '.'
                almacen1[target] = '@'
                current = target
            }
        }
        return almacen1.coordinates('O')
    }

    fun solve2(): Any {
        var current = start2
        directions.forEach { dir ->
            val target = current + dir
            can2MoveHere(almacen2, target, dir, mutableSetOf()).whenPossible {
                almacen2[current] = '.'
                almacen2[target] = '@'
                current = target
            }
        }
        return almacen2.coordinates('[')
    }

}
