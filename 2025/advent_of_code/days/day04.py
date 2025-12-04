from advent_of_code.infra import should_be


class Grid:
    def __init__(self, grid: str):
        self.paper_grid = [[-1 if c == '.' else 0 for c in list(line)] for line in grid.strip().split()]
        for y, line in enumerate(self.paper_grid):
            for x, v in enumerate(line):
                if v != -1:
                    self.safe_add(x - 1, y - 1)
                    self.safe_add(x, y - 1)
                    self.safe_add(x + 1, y - 1)
                    self.safe_add(x - 1, y)
                    self.safe_add(x + 1, y)
                    self.safe_add(x - 1, y + 1)
                    self.safe_add(x, y + 1)
                    self.safe_add(x + 1, y + 1)

    def safe_add(self, x: int, y: int, value: int = 1) -> bool:
        if x < 0 or y < 0 or y >= len(self.paper_grid) or x >= len(self.paper_grid[0]):
            return False

        cur_value = self.paper_grid[y][x]
        if cur_value < 0 or cur_value == 0 and value < 0:
            return False

        self.paper_grid[y][x] += value
        return True

    def accessible_papers(self) -> list[tuple[int, int]]:
        return [(x, y) for y, line in enumerate(self.paper_grid) for x, v in enumerate(line) if 0 <= v < 4]

    def remove_paper(self, pos: tuple[int, int]):
        x, y = pos
        self.paper_grid[y][x] = -1
        self.safe_add(x - 1, y - 1, -1)
        self.safe_add(x, y - 1, -1)
        self.safe_add(x + 1, y - 1, -1)
        self.safe_add(x - 1, y, -1)
        self.safe_add(x + 1, y, -1)
        self.safe_add(x - 1, y + 1, -1)
        self.safe_add(x, y + 1, -1)
        self.safe_add(x + 1, y + 1, -1)


@should_be(1411)
def part1(data: str) -> int:
    return len(Grid(data).accessible_papers())


@should_be(8557)
def part2(data: str) -> int:
    state = Grid(data)
    removed = 0
    while removable := state.accessible_papers():
        removed += len(removable)
        for r in removable:
            state.remove_paper(r)

    return removed
