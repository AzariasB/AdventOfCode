import math
import re
from typing import Generator

from advent_of_code.infra import should_be


def _gen_pairs(length: int, start=1) -> Generator[int, None, None]:
    if length <= 0:
        yield from []
        return

    if length == 1:
        yield from list(range(start, 10))
        return

    leftmost = _gen_pairs(1, start)
    rst = list(_gen_pairs(length - 1, 0))
    for l in leftmost:
        pos = l * 10 ** (length - 1)
        for r in rst:
            yield pos + r


def _find_invalid_ids(start: int, end: int) -> int:
    total = 0
    pos = start
    while pos <= end:
        ln = int(math.log10(pos)) + 1
        if ln % 2 == 0:
            duplicates = _gen_pairs(ln // 2)
            for d in duplicates:
                l = d * 10 ** (ln // 2)
                tot = l + d
                if tot > end:
                    break
                if tot >= start:
                    total += tot

            pos = 10 ** (ln + 2)
        else:
            pos = 10 ** ln

    return total


@should_be(21139440284)
def part1(data: str) -> int:
    ranges = []
    for ids in data.split(','):
        left, right = ids.split('-')
        ranges.append(_find_invalid_ids(int(left), int(right)))

    return sum(ranges)



INVALID_ID_REG = re.compile(r"^(\d+)\1+$")

def _is_invalid_id(value: int) -> bool:
    return INVALID_ID_REG.match(str(value)) is not None


@should_be(38731915928)
def part2(data: str) -> int:
    # Just brute force it
    total = 0
    for ids in data.split(','):
        left, right = ids.split('-')
        total += sum(test for test in range(int(left), int(right) +1) if _is_invalid_id(test))

    return total
