#!/usr/bin/env -S uv run --script
import datetime
from typing import Annotated

import typer
from typer import Typer
from advent_of_code.infra import setup_day
from advent_of_code.infra import run_tests

app = Typer()

Day = Annotated[int, typer.Argument(default_factory=lambda: datetime.date.today().day)]

@app.command(short_help="Prepares the project to write the code and run the tests locally")
def scaffold(day: Day):
    setup_day(day)

@app.command(short_help="Run the tests for the given day, or current day if not given")
def run(day: Day):
    run_tests(day)

if __name__ == '__main__':
    app()
