from typing import Any, Callable


def should_be(value: Any):
    def _wrapper(func: Callable[[str], Any]):
        func.__expected_result__ = value

        return func
    return _wrapper