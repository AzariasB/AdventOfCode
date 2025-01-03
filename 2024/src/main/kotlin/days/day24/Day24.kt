package eu.azariasb.adventofocde.days.day24

import org.apache.tools.ant.taskdefs.condition.Not

typealias Registry = MutableMap<String, Day24.Operation>

class Day24(input: String) {

    private val registry = mutableMapOf<String, Day24.Operation>()

    init {
        val (literals, os) = input.split("\n\n")
        literals.lineSequence().forEach {
            val (name, value) = it.split(": ")
            registry[name] = Literal(name, value.toInt())
        }
        os.lineSequence().forEach {
            val (left, op, right, _, target) = it.split(" ")
            registry[target] = BitwiseOp(
                left,
                right,
                when (op) {
                    "AND" -> Int::and
                    "OR" -> Int::or
                    "XOR" -> Int::xor
                    else -> throw IllegalArgumentException("Unrecognised op: $op")
                }
            )
        }
    }

    interface Operation {
        fun calculate(reg: Registry): Int

    }

    private data class Literal(private val name: String, private val content: Int) : Operation {

        override fun calculate(reg: Registry): Int = content

    }

    private class BitwiseOp(
        left: String,
        right: String,
        private val op: (Int, Int) -> Int,
    ) : Operation {
        private val left = minOf(left, right)
        private val right = maxOf(right, left)

        override fun calculate(reg: Registry) = op(
            (reg[left] ?: throw IllegalArgumentException("Unknown left argument name : $left")).calculate(reg),
            (reg[right] ?: throw IllegalArgumentException("Unknown right argument name: $right")).calculate(reg)
        )

        override fun equals(other: Any?): Boolean =
            other is BitwiseOp && op == other.op && left == other.left && right == other.right

        override fun hashCode(): Int = (left.hashCode() * 31 + op.hashCode()) * 31 + right.hashCode()

         override fun toString(): String = "BitwiseOp(left=$left, op=$op, right=$right)"
    }

    fun solve1() = registry.filter { it.key.startsWith("z") }
        .mapValues { it.value.calculate(registry) }
        .toSortedMap()
        .reversed()
        .values
        .joinToString("")
        .toLong(2)

    fun solve2() = buildSet {
        val connections = registry.entries.associateByTo(mutableMapOf(), { it.value }) { it.key }
        var carry: String? = null
        var first = true
        for (z in this@Day24.registry.keys.filter { it.startsWith("z") }.sorted()) {
            val x = z.replaceFirstChar { 'x' }
            val y = z.replaceFirstChar { 'y' }
            if (carry != null) {
                var halfAdd =
                    connections[BitwiseOp(x, y, Int::xor)]
                if (halfAdd == null) {
                    if (carry != z) {
                        check(add(carry) and add(z))
                        connections.swap(carry, z)
                    }
                    carry = null
                } else {
                    val fullAdd = connections[BitwiseOp(halfAdd, carry, Int::xor)] ?: run {
                        val alternative = connections.getValue(BitwiseOp(x, y, Int::and))
                        check(add(halfAdd!!) and add(alternative))
                        connections.swap(halfAdd!!, alternative)
                        halfAdd = alternative
                        connections.getValue(BitwiseOp(alternative, carry!!, Int::xor))
                    }
                    if (fullAdd != z) {
                        check(add(fullAdd) and add(z))
                        connections.swap(fullAdd, z)
                    }
                    carry = connections[BitwiseOp(x, y, Int::and)]?.let { overflow1 ->
                        connections[BitwiseOp(halfAdd!!, carry!!, Int::and)]?.let { overflow2 ->
                            connections[BitwiseOp(overflow1, overflow2, Int::or)]
                        }
                    }
                }
            } else {
                check(first)
                first = false
                val add = connections.getValue(BitwiseOp(x, y, Int::xor))
                if (add != z) {
                    check(add(add) and add(z))
                    connections.swap(add, z)
                }
                carry = connections[BitwiseOp(x, y, Int::and)]
            }
        }
    }.sorted().joinToString(",")


    companion object {

        private fun <K, V> MutableMap<K, V>.swap(u: V, v: V) {
            val iterator = iterator()
            for (entry in iterator) {
                when (entry.value) {
                    u -> entry.setValue(v)
                    v -> entry.setValue(u)
                }
            }
        }
    }
}
