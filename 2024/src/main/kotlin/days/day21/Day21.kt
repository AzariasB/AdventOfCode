package eu.azariasb.adventofocde.days.day21

import utils.Point
import kotlin.math.absoluteValue

class Day21(input: String) {

    private val codes = input.lines()
    private val cache = mutableMapOf<Pair<String, Int>, Long>()

    private val digiCode = mapOf(
        '7' to Point(0, 0),
        '8' to Point(1, 0),
        '9' to Point(2, 0),
        '4' to Point(0, 1),
        '5' to Point(1, 1),
        '6' to Point(2, 1),
        '1' to Point(0, 2),
        '2' to Point(1, 2),
        '3' to Point(2, 2),
        '0' to Point(1, 3),
        'A' to Point(2, 3),
    )

    private val directions = mapOf(
        '^' to Point(1, 0),
        'A' to Point(2, 0),
        '<' to Point(0, 1),
        'v' to Point(1, 1),
        '>' to Point(2, 1),
    )

    private fun digiMoves(from: Point, to: Point): List<String> {
        return buildList {
            val yDist = to.y - from.y
            val xDist = to.x - from.x
            val yMove = (if (yDist > 0) "v" else "^").repeat(yDist.absoluteValue)
            val xMove = (if (xDist > 0) ">" else "<").repeat(xDist.absoluteValue)
            if (xDist == 0 || yDist == 0) {
                add("$xMove${yMove}A")
            } else {
                if (to.y == 3 && from.y < 3 && from.x == 0) {
                    add("$xMove${yMove}A")
                } else if (from.y == 3 && to.y < 3 && to.x == 0) {
                    add("$yMove${xMove}A")
                } else {
                    add("$yMove${xMove}A")
                    add("$xMove${yMove}A")
                }
            }
        }
    }

    private fun numPadMoves(from: Point, to: Point): List<String> {
        return buildList {
            val yDist = to.y - from.y
            val xDist = to.x - from.x
            val yMove = (if (yDist > 0) "v" else "^").repeat(yDist.absoluteValue)
            val xMove = (if (xDist > 0) ">" else "<").repeat(xDist.absoluteValue)
            if (xDist == 0 || yDist == 0) {
                add("$xMove${yMove}A")
            } else {
                if (to.y == 0 && from == Point(0, 1)) {
                    add("$xMove${yMove}A")
                } else if (from.y == 0 && to == Point(0, 1)) {
                    add("$yMove${xMove}A")
                } else {
                    add("$yMove${xMove}A")
                    add("$xMove${yMove}A")
                }
            }
        }
    }

    private fun bestDigiMove(sequence: String, depth: Int): Long {
        if (depth == 0) return sequence.length.toLong()
        val key = sequence to depth
        return cache[key] ?: kotlin.run {
            var rPos = directions['A']!!
            sequence.sumOf { c ->
                val dest = directions[c]!!
                numPadMoves(rPos, dest).minOf { sub ->
                    bestDigiMove(sub, depth - 1)
                }.also { rPos = dest }
            }.also { cache[key] = it }
        }
    }

    private fun solve(depth: Int): Long = codes.sumOf {
        var current = digiCode['A']!!
        it.sumOf { d ->
            val target = digiCode[d]!!
            digiMoves(current, target).minOf { path ->
                bestDigiMove(path, depth)
            }.also { current = target }
        } * it.dropLast(1).toInt()
    }

    fun solve1() = solve(2)

    fun solve2() = solve(25)
}