
__all__ = ["run_tests"]

import importlib.util
import time
from collections.abc import Callable
from typing import Tuple

from advent_of_code.infra import test_file_path, code_file_path

AocFunction = Callable[[str], str | int]

class AocTestRunner:

    def __init__(self, part: int, func: AocFunction):
        self.part = part
        self.func = func
        self.expected_value = getattr(func, "__expected_result__", 0)

    def run(self, puzzle_input: str):

        start_time = time.perf_counter()
        res = self.func(puzzle_input)
        end_time = time.perf_counter()
        msg = f"Part {self.part}: {res}."
        if res == self.expected_value:
            msg +=  " Correct."
        else:
            msg += f" Expected {self.expected_value}."

        msg += f" Time: {end_time - start_time:.2f}s"
        print(msg)




def _read_test_file(day: int) -> str:
    test_file = test_file_path(day)
    return test_file.read_text("utf-8")

def _import_funcs(day: int) -> Tuple[AocTestRunner, AocTestRunner]:
    code_path = code_file_path(day)
    module_name = f"{day:02}"

    spec = importlib.util.spec_from_file_location(module_name, code_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return (
        AocTestRunner(1, module.part1),
        AocTestRunner(2, module.part2)
    )


def run_tests(day: int):
   input_test = _read_test_file(day)

   part1, part2 = _import_funcs(day)

   part1.run(input_test)
   part2.run(input_test)
