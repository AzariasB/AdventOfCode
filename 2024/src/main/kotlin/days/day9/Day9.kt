package eu.azariasb.adventofocde.days.day9

import java.util.LinkedList

data class Block(var size: Int, var spanId: Int? = null) {
    companion object {
        val EMPTY = Block(0, 0)
    }
}

class Day9(input: String) {

    val spaces = input.toCharArray().map { it.digitToInt() }

    val blocks: LinkedList<Block>
        get() {
            var freeSpace = 0
            val target = LinkedList<Block>()
            for ((idx, s) in spaces.withIndex()) {
                if (idx and 1 == 0) {
                    target.add(Block(s, idx / 2))
                } else {
                    freeSpace += s
                    target.add(Block(s, null))
                }
            }
            return target
        }

    fun Iterable<Block>.score(): Long {
        var idx = 0
        return this.filter { it.size > 0 }.sumOf { block ->
            (0..<block.size).sumOf { i ->
                ((block.spanId ?: 0) * (i + idx)).toLong()
            }.also { idx += block.size }
        }
    }

    fun solve1(): String {
        val target = blocks


        val ordered = mutableListOf<Block>()
        while (target.isNotEmpty()) {
            val last = target.removeLast()
            while (target.isNotEmpty() && last.size > 0) {
                val nxt = target.removeFirst()
                ordered.add(nxt)
                val empty = target.removeFirst()
                if (empty.size > last.size) {
                    ordered.add(Block(last.size, last.spanId))
                    target.addFirst(Block(empty.size - last.size, null))
                    target.addFirst(Block.EMPTY)
                } else {
                    ordered.add(Block(empty.size, last.spanId))
                }
                last.size -= empty.size
            }
            if (target.isEmpty() && last.size > 0) {
                ordered.add(Block(last.size, last.spanId))
            }
            target.removeLastOrNull()
        }
        return ordered.score().toString()
    }


    fun solve2(): String {
        val target = blocks

        for (idx in (1..target.lastIndex).reversed()) {
            val current = target[idx]
            if (current.spanId == null) {
                continue
            }

            for ((i, empty) in target.withIndex()
                .filter { (i, b) -> b.spanId == null && idx >= i && b.size >= current.size }) {
                if (empty.size > current.size) {
                    target.add(i + 1, Block(empty.size - current.size, null))
                }
                empty.size = current.size
                empty.spanId = current.spanId
                current.spanId = null
                break
            }
        }

        return target.score().toString()
    }

}
