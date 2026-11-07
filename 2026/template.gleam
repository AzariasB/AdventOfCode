import gleam/int
import gleam/list
import gleam/result
import util/file
import util/parse

const file: String = "input/dayXX.txt"

pub fn main() {
  echo "Part 1: " <> { part_1(file) |> int.to_string() }
  // echo "Part 2: " <> { part_2(file) |> int.to_string() }
}

pub fn part_1(file: String) -> Int {
  0
}

pub fn part_2(file: String) -> Int {
  0
}
