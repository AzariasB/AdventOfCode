from advent_of_code.infra import should_be


def rotations(value: str) -> int:
    direction = -1 if value[0] == "L" else 1
    count = int(value[1:])
    return direction * count


@should_be(1026)
def part1(data: str) -> int:
    val = 50

    return sum(int((val := (rotations(instr) + val) % 100) == 0) for instr in data.strip().splitlines())


@should_be(5923)
def part2(data: str) -> int:
    dial = 50
    clicks = 0

    for instr in data.strip().splitlines():
        rots = rotations(instr)
        if rots < 0 and dial == 0:
            clicks -= 1
        cl, dial = divmod(dial + rots, 100)
        clicks += abs(cl) + int(rots < 0 and dial == 0)

    return clicks
