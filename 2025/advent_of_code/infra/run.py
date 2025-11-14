
__all__ = ["run_tests"]

import time
from collections.abc import Callable
from pathlib import Path
from typing import Tuple

AocFunction = Callable[[str], str | int]

class AocTestRunner:

    def __init__(self, part: int, func: AocFunction):
        self.part = part
        self.func = func
        self.expected_value = getattr(func, "__expected_result__", 0)

    def run(self, input: str):

        start_time = time.time()
        res = self.func(input)
        end_time = time.time()
        print(f"Part {self.part} took: {end_time - start_time:.2f}s")
        if res == self.expected_value:
            print(f"✓ Got: {res}. Correct")
        else:
            print(f"❌ Got: {res}. Expected {self.expected_value}")



def _read_test_file(day: int) -> str:
    test_file = Path(__file__).parent / ".." / ".."

def _import_funcs(day: int) -> Tuple[AocTestRunner, AocTestRunner]:
    pass


def run_tests(day: int):
   input_test = _read_test_file(day)

   part1, part2 = _import_funcs(day)

   part1.run(input_test)
   part2.run(input_test)
