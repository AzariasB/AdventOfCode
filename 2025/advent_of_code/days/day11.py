from functools import cache

from advent_of_code.infra import should_be


def path_count(point: str, graph: dict[str, list[str]]) -> int:
    paths = graph.get(point, [])
    if not paths:
        return 1

    return sum(path_count(p, graph) for p in paths)

def to_graph(lines: str) -> dict[str, list[str]]:
    all_nodes = dict()
    for line in lines.splitlines():
        l, r = line.split(': ')
        if r == "out":
            all_nodes[l] = []
            continue
        targets = r.split(' ')
        all_nodes[l] = targets

    return all_nodes

@should_be(428)
def part1(data: str) -> int:
    return path_count("you", to_graph(data))


@should_be(331468292364745)
def part2(data: str) -> int:
    all_nodes = to_graph(data)

    @cache
    def conditional_path_count(point: str, is_critical: int) -> int:
        paths = all_nodes.get(point, [])
        is_critical |= int(point == "fft") | (int(point == "dac") << 1)
        return sum(conditional_path_count(p, is_critical) for p in paths) if paths else int(is_critical == 3)

    return conditional_path_count("svr", 0)
