from advent_of_code.infra import should_be


def _parse_block(block: str) -> int:
    return sum(l.count('#') for l in block.splitlines()[1:])


@should_be(427)
def part1(data: str) -> int:
    *blocks, configs = data.split('\n\n')
    blocks = [_parse_block(b) for b in blocks]

    def config_works(c: str) -> bool:
        size, counts = c.split(': ')
        width, height = size.split('x')
        total_area = int(width) * int(height)
        required_area = sum(blocks[idx] * int(v) for idx, v in enumerate(counts.split(' ')))
        return required_area <= total_area

    return sum(1 for c in configs.splitlines() if config_works(c))


@should_be(0)
def part2(_: str) -> int:
    return 0
