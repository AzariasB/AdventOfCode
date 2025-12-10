from advent_of_code.infra import should_be
from pulp import LpProblem, LpVariable, lpSum, PULP_CBC_CMD
import pulp as lp


def state_to_int(state: str) -> int:
    return sum(1 << i if v == '#' else 0 for i, v in enumerate(state[1:-1]))


def button_to_int(button: list[int]) -> int:
    return sum(1 << i for i in button)


class Machine:

    def __init__(self, final_state: int, buttons: list[int], powers: tuple):
        self.final_state = final_state
        self.buttons = buttons
        self.power_target = powers

    @staticmethod
    def from_str(line: str) -> Machine:
        parts = line.split(' ')
        state = state_to_int(parts.pop(0))
        power = [int(v) for v in parts.pop(-1)[1:-1].split(',')]
        buttons = [
            button_to_int([int(b) for b in v[1:-1].split(',')])
            for v in parts
        ]
        return Machine(state, buttons, tuple(power))

    def fastest_init_sequence(self) -> int:
        states = [0]
        visited_states = set()
        button_press = 1
        while True:
            nw_states = []
            for s in states:
                if s in visited_states:
                    continue
                visited_states.add(s)
                for b in self.buttons:
                    nw_value = s ^ b
                    if nw_value == self.final_state:
                        return button_press
                    nw_states.append(nw_value)

            states = nw_states
            button_press += 1

    def fastest_joltage_sequence(self) -> int:
        model = LpProblem(name="joltage", sense=1)
        variables = [LpVariable(name=f"group_{i}", lowBound=0, cat=lp.LpInteger) for i in range(len(self.buttons))]
        model += lpSum(variables)
        for i, p in enumerate(self.power_target):
            selected_variables = [v for j, v in enumerate(variables) if (self.buttons[j] & (1 << i)) != 0]
            model += (lpSum(selected_variables) == p, f"Solve {i}")
        model.solve(PULP_CBC_CMD(msg=0))
        return sum(int(v.value()) for v in variables)


@should_be(447)
def part1(data: str) -> int:
    return sum(Machine.from_str(l).fastest_init_sequence() for l in data.splitlines())


@should_be(18960)
def part2(data: str) -> int:
    return sum(Machine.from_str(l).fastest_joltage_sequence() for l in data.splitlines())
