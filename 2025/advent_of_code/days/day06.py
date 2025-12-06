import re
from functools import reduce
from typing import Literal

from advent_of_code.infra import should_be

SEPARATOR_REG = re.compile(r"\s+")

def compute(op: Literal["+", "*"], *values: int):
    match op:
        case "+":
            return sum(values)
        case "*":
            return reduce(lambda a, b: a * b, values, 1)
        case _:
            raise Exception(f"Unknown operation '{op}'")



def tonums(s: str) -> list[int]:
    return [int(i) for i in SEPARATOR_REG.split(s.strip())]


@should_be(7229350537438)
def part1(data: str) -> int:
    lines = data.splitlines()
    ops = lines.pop()
    nums = [tonums(i) for i in lines]
    ops = SEPARATOR_REG.split(ops.strip())
    return sum(compute(op, *(n[x] for n in nums)) for x, op in enumerate(ops))


def safeget(s: str, pos: int) -> str:
    return s[pos] if pos < len(s) else ''

@should_be(11479269003550)
def part2(data: str) -> int:
    lines = data.splitlines()
    ops = lines.pop()
    pos = max(len(l) - 1 for l in lines)
    cur_nums = []
    total = 0
    while pos >= 0:
        cur_n = int(''.join([safeget(l, pos) for l in lines]))
        cur_nums.append(cur_n)
        op = safeget(ops, pos)
        if op in ('+', '*'):
            pos -= 1
            total += compute(op, *cur_nums)
            cur_nums = []
        pos -= 1

    return total
