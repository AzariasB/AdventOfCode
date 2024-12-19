package eu.azariasb.adventofocde.days.day19

class Day19(input: String) {

    private val availablePatterns: Set<String>
    private val expectedPatterns: List<String>
    private val longestAvailable: Int

    init {
        val (a, e) = input.split("\n\n", limit = 2)
        availablePatterns = a.split(", ").toSet()
        expectedPatterns = e.lines()
        longestAvailable = availablePatterns.maxBy { it.length }.length
    }

    private fun canBeCreated(cache: MutableMap<String, Boolean>, motif: String): Boolean {
        if (motif in availablePatterns) return true
        if (motif.length < 2) return false
        return cache[motif] ?: kotlin.run {
            (minOf(longestAvailable, motif.length) downTo 1).any { i ->
                (motif.substring(0, i) in availablePatterns && canBeCreated(cache, motif.substring(i)))
            }
        }.also { cache[motif] = it }
    }

    fun solve1() = mutableMapOf<String, Boolean>().let { cache -> expectedPatterns.count { canBeCreated(cache, it) } }

    private fun waysOfCreating(cache: MutableMap<String, Long>, motif: String): Long {
        return cache[motif] ?: kotlin.run {
            (if (motif in availablePatterns) 1L else 0L) + (1..minOf(longestAvailable, motif.length)).sumOf { i ->
                val sub = motif.substring(0, i)
                if (sub in availablePatterns) {
                    waysOfCreating(cache, motif.substring(i))
                } else {
                    0
                }
            }
        }.also { cache[motif] = it }
    }

    fun solve2() = (mutableMapOf<String, Long>() to mutableMapOf<String, Boolean>()).let { (cache, cache1) ->
        expectedPatterns.filter { canBeCreated(cache1, it) }.sumOf { waysOfCreating(cache, it) }
    }

}
