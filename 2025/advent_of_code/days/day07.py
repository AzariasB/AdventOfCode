from functools import cache

from advent_of_code.infra import should_be


@should_be(1605)
def part1(data: str) -> int:
    splitters = data.splitlines()
    start_col = splitters.pop(0).index('S')
    cols: set[int] = {start_col}
    splits = 0

    while splitters:
        nw_cols = set()
        current = splitters.pop(0)
        for pos in cols:
            if current[pos] == '^':
                splits += 1
                nw_cols.add(pos - 1)
                nw_cols.add(pos + 1)
            else:
                nw_cols.add(pos)
        cols = nw_cols
    return splits


@should_be(29893386035180)
def part2(data: str) -> int:
    splitters = data.splitlines()
    @cache
    def possibilities(index: int, pos: int) -> int:
        if index >= len(splitters): return 1
        return possibilities(index + 1, pos) if splitters[index][pos] == '.' else possibilities(index + 1, pos - 1) + possibilities(index + 1, pos + 1)
    return possibilities(0, splitters.pop(0).index('S'))
