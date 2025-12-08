import dataclasses
from dataclasses import field

from advent_of_code.infra import should_be


class Circuit:

    def __init__(self, root: JunctionBox):
        root.circuit = self
        self.junctions = set()
        self.junctions.add(root)

    def add_junction(self, junction: JunctionBox):
        self.junctions.add(junction)
        junction.circuit = self

    def merge(self, other: Circuit) -> Circuit:
        if other == self:
            return self

        for n in other.junctions:
            self.add_junction(n)

        other.junctions = set()
        return self


@dataclasses.dataclass
class JunctionBox:
    x: int
    y: int
    z: int
    circuit: Circuit = field(init=False)

    def __post_init__(self):
        self.circuit = Circuit(self)

    def __hash__(self):
        return hash((self.x, self.y, self.z, self.circuit))

    def __eq__(self, other: JunctionBox):
        return self.x == other.x and self.y == other.y and self.z == other.z and self.circuit == other.circuit

    def distance2_from(self, other: JunctionBox) -> int:
        return (self.x - other.x) ** 2 + (self.y - other.y) ** 2 + (self.z - other.z) ** 2


@should_be(42315)
def part1(data: str) -> int:
    coordinates = data.splitlines()
    juncs: list[JunctionBox] = []
    for line in coordinates:
        x, y, z = [int(v) for v in line.split(',')]
        juncs.append(JunctionBox(x, y, z))

    pairs: list[tuple[JunctionBox, JunctionBox, int]] = []
    for x, j1 in enumerate(juncs):
        for j2 in juncs[x + 1:]:
            pairs.append((j1, j2, j1.distance2_from(j2)))

    ordered = sorted(pairs, key=lambda p: p[2])
    valid_circuits: set[Circuit] = set()
    for (a, b, _) in ordered[:1000]:
        valid_circuits.add(a.circuit.merge(b.circuit))

    a, b, c = [len(b.junctions) for b in sorted(valid_circuits, reverse=True, key=lambda c: len(c.junctions))[:3]]
    return a * b * c


@should_be(8079278220)
def part2(data: str) -> int:
    coordinates = data.splitlines()
    juncs: list[JunctionBox] = []
    for line in coordinates:
        x, y, z = [int(v) for v in line.split(',')]
        juncs.append(JunctionBox(x, y, z))

    pairs: list[tuple[JunctionBox, JunctionBox, int]] = []
    for x, j1 in enumerate(juncs):
        for j2 in juncs[x + 1:]:
            pairs.append((j1, j2, j1.distance2_from(j2)))

    ordered = sorted(pairs, key=lambda p: p[2])
    total_junctions = len(juncs)
    for a, b, _ in ordered:
        if len(a.circuit.merge(b.circuit).junctions) == total_junctions:
            return a.x * b.x

    return 0
