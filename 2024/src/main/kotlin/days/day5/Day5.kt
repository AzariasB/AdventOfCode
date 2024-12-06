package eu.azariasb.adventofocde.days.day5

typealias Rule = Map<Int, Set<Int>>

class Day5(puzzle: String) {

    private val rules: Rule
    private val orders: List<List<Int>>

    init {
        val (r, o) = this.parseInput(puzzle.lines())
        this.rules = r
        this.orders = o
    }

    private fun parseInput(input: List<String>): Pair<Rule, List<List<Int>>> {
        val rules = mutableMapOf<Int, Set<Int>>()
        var idx = 0
        while (idx < input.size) {
            val line = input[idx]
            if (!line.contains("|")) {
                break
            }
            val (l, r) = line.split("|").map(String::toInt)
            rules.merge(r, setOf(l)) { a, b -> a.union(b) }
            idx++
        }
        idx++
        val orders = mutableListOf<List<Int>>()
        while (idx < input.size) {
            val line = input[idx]
            orders.add(line.split(",").map(String::toInt))
            idx++
        }

        return rules to orders
    }

    private fun middleNumber(input: List<Int>): Int {
        return input[input.size / 2]
    }

    private fun respectsOrder(rules: Rule, input: List<Int>): Boolean {
        val visited = mutableSetOf<Int>()
        val contained = input.toSet()
        for (i in input) {
            val mustVisit = rules.getOrDefault(i, emptySet())
            val availableToVisit = contained.intersect(mustVisit)
            if (availableToVisit.isNotEmpty() && availableToVisit.intersect(visited) != availableToVisit) {
                return false
            }
            visited += i
        }
        return true
    }

    private fun fixOrder(rules: Rule, input: List<Int>): List<Int> {
        val visited = mutableSetOf<Int>()
        val contained = input.toSet()
        val result = input.toMutableList()
        for ((idx, i) in input.withIndex()) {
            val mustVisit = rules.getOrDefault(i, emptySet())
            val availableToVisit = contained.intersect(mustVisit)
            if (availableToVisit.isNotEmpty()) {
                val toMove = availableToVisit - visited
                if (toMove.isNotEmpty()) {
                    for (mv in toMove) {
                        result.remove(mv)
                        result.add(idx, mv)
                    }
                    return fixOrder(rules, result)
                }
            }
            visited += i
        }
        return result
    }


    fun solve1(): String {
        return orders.filter { respectsOrder(rules, it) }.sumOf(::middleNumber).toString()
    }

    fun solve2(): String {
        return orders.filter { !respectsOrder(rules, it) }.map { fixOrder(rules, it) }.sumOf(::middleNumber).toString()
    }

}
