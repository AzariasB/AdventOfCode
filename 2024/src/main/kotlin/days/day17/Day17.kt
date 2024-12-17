package eu.azariasb.adventofocde.days.day17

import java.lang.Math.pow
import java.util.PriorityQueue


class Day17(input: String) {

    private data class Computer(val regA: Long, val regB: Long, val regC: Long, val instructions: List<Int>)

    private data class CPair(val left: Int, val right: Long) : Comparable<CPair> {
        override fun compareTo(other: CPair): Int {
            if (other.left == this.left) return right.compareTo(other.right)
            return left.compareTo(other.left)
        }

    }

    private val progReg = Regex(
        """
        Register A: (\d+)
        Register B: (\d+)
        Register C: (\d+)

        Program: (.+)
    """.trimIndent()
    )

    private val computer: Computer

    init {
        val match = progReg.matchEntire(input) ?: throw IllegalArgumentException("Invalid input")
        val instrs = match.groupValues[4].split(",").map(String::toInt)
        computer =
            Computer(
                match.groupValues[1].toLong(),
                match.groupValues[2].toLong(),
                match.groupValues[3].toLong(),
                instrs
            )
    }

    private fun runProgram(comp: Computer): List<Long> {
        var a = comp.regA
        var b = comp.regB
        var c = comp.regC

        val combo = { operand: Int ->
            when (operand) {
                in 0..3 -> operand.toLong()
                4 -> a
                5 -> b
                6 -> c
                else -> throw IllegalArgumentException("Invalid op code $operand")
            }
        }

        var instrPointer = 0

        return buildList {
            while (instrPointer < comp.instructions.size) {
                val instr = comp.instructions[instrPointer]
                val operand = comp.instructions[instrPointer + 1]
                when (instr) {
                    0 -> {
                        a /= pow(2.0, combo(operand).toDouble()).toLong()
                    }

                    1 -> {
                        b = b xor operand.toLong()
                    }

                    2 -> {
                        b = combo(operand) % 8
                    }

                    3 -> {
                        if (a != 0L) {
                            instrPointer = operand
                            continue
                        }
                    }

                    4 -> {
                        b = b xor c
                    }

                    5 -> {
                        add(combo(operand) % 8)
                    }

                    6 -> {
                        b = a / pow(2.0, combo(operand).toDouble()).toLong()
                    }

                    7 -> {
                        c = a / pow(2.0, combo(operand).toDouble()).toLong()
                    }

                    else -> throw IllegalArgumentException("Invalid instruction $instr")
                }
                instrPointer += 2
            }
        }
    }

    fun solve1() = runProgram(computer).joinToString(",")

    fun solve2(): Any {
        val target = computer.instructions.map(Int::toLong)
        val paths = PriorityQueue<CPair>()
            .also { it.addAll((0..7L).map { value -> CPair(0, value) }) }
        while (paths.isNotEmpty()) {
            val (shift, value) = paths.poll()
            val res = runProgram(Computer(value, 0, 0, computer.instructions))

            if (target.takeLast(shift + 1) == res) {
                if (res.size == target.size) {
                    return value
                }
                paths.addAll((0..7).map {
                    CPair((shift + 1), value.shl(3) + it)
                })
            }
        }
        throw IllegalStateException("Could not reach target")
    }

}
