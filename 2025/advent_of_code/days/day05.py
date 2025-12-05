from advent_of_code.infra import should_be


class Matrix1D:

    def __init__(self, input: str):
        self.ranges: list[range] = []
        for f in input.splitlines():
            fr, to = f.split('-')
            self.add_range(range(int(fr), int(to) + 1))

    def in_range(self, value: int) -> bool:
        return any(value in rn for rn in self.ranges)

    def add_range(self, r2: range) -> None:
        if not self.ranges:
            return self.ranges.append(r2)

        for i, r in enumerate(self.ranges):
            if r2.start >= r.start and r2.stop <= r.stop:
                # Nothing to do here, the range already exist internally
                return None
            elif r.start >= r2.start and r.stop <= r2.stop:
                # The new range is bigger than what we stored, pop our range and add the bigger one
                self.ranges.pop(i)
                return self.add_range(r2)
            elif r.start <= r2.start <= r.stop:
                # We need to extend our range
                self.ranges.pop(i)
                return self.add_range(range(r.start, max(r2.stop, r.stop)))
            elif r2.start <= r.start <= r2.stop:
                # Extend the range as well
                self.ranges.pop(i)
                return self.add_range(range(r2.start, max(r2.stop, r.stop)))

        # Found no special case, new range in our system
        return self.ranges.append(r2)

    def total_size(self):
        return sum(len(rn) for rn in self.ranges)


@should_be(888)
def part1(data: str) -> int:
    fresh, fruits = data.split('\n\n', 1)
    mltrng = Matrix1D(fresh)
    return len([f for f in fruits.splitlines() if mltrng.in_range(int(f))])


@should_be(344378119285354)
def part2(data: str) -> int:
    fresh, _ = data.split('\n\n', 1)
    mltrng = Matrix1D(fresh)
    return mltrng.total_size()
