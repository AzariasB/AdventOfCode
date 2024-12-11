package utils

data class Point(val x: Int, val y: Int) {

    companion object {
        val NORTH = Point(0, -1)
        val SOUTH = Point(0, 1)
        val EAST = Point(1, 0)
        val WEST = Point(-1, 0)
    }

    fun right() = this + EAST
    fun left() = this + WEST
    fun down() = this + SOUTH
    fun up() = this + NORTH

    operator fun plus(that: Point) = Point(x + that.x, y + that.y)
    operator fun minus(that: Point) = Point(x - that.x, y - that.y)

    fun neighbors(): Set<Point> = setOf(right(), left(), down(), up())
}