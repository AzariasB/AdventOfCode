import gleam/result
import gleam/string
import simplifile

pub fn read(from filepath: String) -> String {
  let assert Ok(content) =
    simplifile.read(filepath)
    |> result.map(string.trim_end)
  content
}

pub fn read_lines(from filepath: String) -> List(String) {
  let assert Ok(content) = simplifile.read(filepath)

  content
  |> string.trim_end
  |> string.split("\n")
}
