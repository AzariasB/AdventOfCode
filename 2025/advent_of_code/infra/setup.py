import os
import re
from pathlib import Path

__all__ = ["setup_day"]

import html_to_markdown
import requests

SCAFFOLD = """

from advent_of_code.infra import should_be

@should_be(0)
def part1(data: str) -> int:
    return 0

@should_be(0)
def part2(data: str) -> int:
    return 0

"""

YEAR = 2025
MAIN_REG = re.compile(r"<main>([\w\W]+)</main>")

def _scaffold(day: int):
    path = Path(__file__).parent / ".." / "days" / f"day{day:02}.py"
    if path.exists():
        print("code file already exists. Skipping file creation")
        return

    path.write_text(SCAFFOLD)
    print(f"Finished creating {path}")

def _download_instructions(day: int):
    url = f"https://adventofcode.com/{YEAR}/day/{day}"

    html_page = requests.get(url).text

    if not (match := MAIN_REG.search(html_page)):
        print(f"Failed to extract instructions from {url}.")
        return

    content = match.group(1)
    converted = html_to_markdown.convert_to_markdown(content)

    path = Path(__file__).parent / ".." / ".." / "puzzles" / f"day{day:02}.md"
    path.write_text(converted)
    print("Finished downloading instructions")


def _download_input(day: int):
    path = Path(__file__).parent / ".." / ".." / "tests" / f"day{day:02}.txt"

    if path.exists():
        print("puzzle input already exists, skipping")


    if not (cookie := os.environ.get("ADVENT_OF_CODE_SESSION")):
        print("Cannot download input without cookies")
        return

    url = f"https://adventofcode.com/{YEAR}/day/{day}/input"
    puzzle_input = requests.get(url, cookies={"session": cookie}).text

    path.write_text(puzzle_input)
    print("Finished downloading puzzle input")


def setup_day(day: int):
    _scaffold(day)
    _download_instructions(day)
    _download_input(day)