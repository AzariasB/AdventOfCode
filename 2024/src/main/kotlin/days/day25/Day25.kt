package eu.azariasb.adventofocde.days.day25

class Day25(input: String) {

    private val locks = mutableListOf<List<Int>>()
    private val keys = mutableListOf<List<Int>>()

    init {
        input.split("\n\n").forEach {
            val lns = it.lines()
            val t = lns.fold(MutableList<Int>(lns[0].length, { -1 })) { a, b ->
                b.withIndex().forEach { (i, v) -> a[i] += if (v == '#') 1 else 0 }
                a
            }
            if (lns[0][0] == '#') {
                locks
            } else {
                keys
            }.add(t)
        }
    }

    private fun fits(lock: List<Int>, key: List<Int>) = lock.zip(key).all { (a, b) -> a + b <= 5 }

    fun solve1() = locks.sumOf { l -> keys.count { k -> fits(l, k) } }

    fun solve2() = ""

}
