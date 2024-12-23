package eu.azariasb.adventofocde.days.day23

class Day23(input: String) {
    private val lanParty = input.lines().map { line ->
        val (a, b) = line.split("-", limit = 2)
        a to b
    }

    private val connections by lazy {
        buildMap<String, Set<String>> {
            for ((a, b) in lanParty) {
                merge(a, setOf(b)) { x, y -> x + y }
                merge(b, setOf(a)) { x, y -> x + y }
            }
        }
    }

    fun solve1(): Any {
        val threePlayersLan = mutableSetOf<Set<String>>()
        for ((player, friends) in connections.filter { it.key.startsWith("t") }) {
            for ((f1, friendsOf1) in friends.filter { it != player }
                .map { friend -> friend to connections[friend]!! }) {
                for ((f2, friendsOf2) in friendsOf1.map { friend -> friend to connections[friend]!! }) {
                    if (player in friendsOf2) {
                        threePlayersLan += setOf(player, f1, f2)
                    }
                }
            }
        }

        return threePlayersLan.size
    }

    private data class Network(private val members: MutableSet<String>) {
        val size
            get() = members.size

        fun isConnectedToAllMembers(cons: Map<String, Set<String>>, player: String): Boolean {
            return members.all { player in cons[it]!! }
        }

        operator fun contains(member: String): Boolean {
            return member in members
        }


        fun addMember(member: String) {
            members += member
        }

        override fun toString(): String {
            return members.sorted().joinToString(",")
        }
    }

    fun solve2() = buildList<Network> {
        for ((player, friends) in connections) {
            for (f in friends) {
                var cons = 0
                for (n in this) {
                    if (n.isConnectedToAllMembers(connections, player)) {
                        n.addMember(player)
                        cons++
                    }
                    if (n.isConnectedToAllMembers(connections, f)) {
                        n.addMember(f)
                        cons++
                    }
                }
                if (cons != 2) {
                    this += Network(mutableSetOf(player, f))
                }
            }
        }
    }.maxBy { it.size }.toString()
}