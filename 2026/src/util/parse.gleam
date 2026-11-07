import gleam/int

pub fn int(str: String) -> Int {
  let assert Ok(n) = int.parse(str) as { "Invalid int:" <> str }
  n
}
