from advent_of_code.infra import should_be

def _best_voltage(line: str) -> int:
    nums = [int(c) for c in line]
    mx = max(*nums[0:-1])
    idx = nums.index(mx) + 1
    right = max(nums[idx:])
    return mx * 10 + right

@should_be(17383)
def part1(data: str) -> int:
    return sum(_best_voltage(line) for line in data.splitlines())

def _best_12_voltage(line: str) -> int:
    nums = [int(c) for c in line]
    res = 0
    for i in range(12):
        last = len(nums) - (11 - i)
        search = nums[0:last]
        mx = max(search)
        res = res * 10 + mx
        nums = nums[(search.index(mx) +1):]
    return res

@should_be(172601598658203)
def part2(data: str) -> int:
    return sum(_best_12_voltage(line) for line in data.splitlines())

