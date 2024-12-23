package eu.azariasb.adventofocde.days.day21

import utils.Point
import kotlin.math.absoluteValue

class Day21(input: String) {

    private val codes = input.lines()

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

    private fun moves(from: Point, to: Point, reverse: Boolean = false): String {
        val yDist = to.y - from.y
        val xDist = to.x - from.x
        val yMove = (if (yDist > 0) "v" else "^").repeat(yDist.absoluteValue)
        val xMove = (if (xDist > 0) ">" else "<").repeat(xDist.absoluteValue)
        return if(yDist < 0 == reverse) {
           "$xMove${yMove}A"
        } else {
           "$yMove${xMove}A"
        }
    }

    fun solve1(): Any {
        return codes.sumOf {
            var current = digiCode['A']!!
            var robot1 = directions['A']!!
            var robot2 = robot1
            val myMoves = StringBuilder()
            it.map { d ->
                val target = digiCode[d]!!
                val digiMove = moves(current, target)
                println("Moves in digicode is $digiMove")
                digiMove.map { r1 ->
                    val r1t = directions[r1]!!
                    val r1move = moves(robot1, r1t, true)
                    println("Moves for robot1 is $r1move")
                    r1move.map { r2 ->
                        val r2t = directions[r2]!!
                        val r2move = moves(robot2, r2t, true)
                        println("Moves for robot2 is $r2move")
                        myMoves.append(r2move)
                        robot2 = r2t
                    }
                    robot1 = r1t
                }
                current = target
            }
            println(myMoves.toString())
            myMoves.length * it.dropLast(1).toInt()
        }

    }

    fun solve2(): Any {

        return ""
    }

}

/*
v<<A>>^AAv<A<A>>^AAvAA<^A>Av<A>^AA<A>Av<A<A>>^
<vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^
 */