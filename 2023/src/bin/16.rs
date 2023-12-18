use std::collections::HashSet;

use itertools::Itertools;

use advent_of_code::parsers::lines;

advent_of_code::solution!(16);

type Point = (i32, i32);

#[derive(Hash, Eq, PartialEq, Copy, Clone)]
enum Direction {
    Right,
    Left,
    Up,
    Down,
}

#[derive(Hash, Eq, PartialEq, Copy, Clone)]
struct State {
    position: Point,
    direction: Direction,
}

impl State {
    fn next(&self) -> State {
        let (x, y) = self.position;
        State {
            direction: self.direction,
            position: match self.direction {
                Direction::Right => (x + 1, y),
                Direction::Left => (x - 1, y),
                Direction::Up => (x, y - 1),
                Direction::Down => (x, y + 1),
            },
        }
    }

    fn with_direction(&self, direction: Direction) -> State {
        State {
            direction,
            position: self.position,
        }
    }

    fn is_horizontal(&self) -> bool {
        self.direction == Direction::Left || self.direction == Direction::Right
    }

    fn slash_mirror(&self) -> Direction {
        match self.direction {
            Direction::Right => Direction::Up,
            Direction::Left => Direction::Down,
            Direction::Up => Direction::Right,
            Direction::Down => Direction::Left,
        }
    }

    fn backslash_mirror(&self) -> Direction {
        match self.direction {
            Direction::Right => Direction::Down,
            Direction::Left => Direction::Up,
            Direction::Up => Direction::Left,
            Direction::Down => Direction::Right,
        }
    }
}

struct Map {
    tiles: Vec<Vec<char>>,
    width: usize,
    height: usize,
}

impl Map {
    fn new(input: &str) -> Map {
        let tiles: Vec<Vec<char>> = lines(input).map(|v| v.chars().collect()).collect();
        Map {
            width: tiles[0].len(),
            height: tiles.len(),
            tiles,
        }
    }

    fn at(&self, &(x, y): &Point) -> Option<char> {
        if !self.is_valid(&(x, y)) {
            None
        } else {
            Some(self.tiles[y as usize][x as usize])
        }
    }

    fn is_valid(&self, &(x, y): &Point) -> bool {
        x >= 0 && x < (self.width as i32) && y >= 0 && y < (self.height as i32)
    }

    fn energized_count(&self, state: State, memo: &mut HashSet<State>) {
        if memo.contains(&state) {
            return;
        }

        if let Some(c) = self.at(&state.position) {
            memo.insert(state);
            match c {
                '.' => self.energized_count(state.next(), memo),
                '|' => {
                    if state.is_horizontal() {
                        let up = state.with_direction(Direction::Up);
                        let down = state.with_direction(Direction::Down);
                        self.energized_count(up.next(), memo);
                        self.energized_count(down.next(), memo);
                    } else {
                        self.energized_count(state.next(), memo)
                    }
                }
                '-' => {
                    if state.is_horizontal() {
                        self.energized_count(state.next(), memo)
                    } else {
                        let left = state.with_direction(Direction::Left);
                        let right = state.with_direction(Direction::Right);
                        self.energized_count(left.next(), memo);
                        self.energized_count(right.next(), memo);
                    }
                }
                '/' => {
                    let nw_dir = state.slash_mirror();
                    let nw_state = state.with_direction(nw_dir);
                    self.energized_count(nw_state.next(), memo);
                }
                '\\' => {
                    let nw_dir = state.backslash_mirror();
                    let nw_state = state.with_direction(nw_dir);
                    self.energized_count(nw_state.next(), memo);
                }
                _ => unreachable!("Unknown tile"),
            }
        }
    }
}

fn unique_points(memo: &HashSet<State>) -> usize {
    memo.iter().map(|s| s.position).unique().count()
}

pub fn part_one(input: &str) -> Option<usize> {
    let map = Map::new(input);
    let mut memo = HashSet::new();
    let start = State {
        position: (0, 0),
        direction: Direction::Right,
    };
    map.energized_count(start, &mut memo);
    Some(unique_points(&memo))
}

pub fn part_two(input: &str) -> Option<usize> {
    let tmp = Map::new(input);
    let width = tmp.width;
    let height = tmp.height;
    let left_right = (0..height)
        .flat_map(|v| {
            let left = State {
                position: (0, v as i32),
                direction: Direction::Right,
            };
            let right = State {
                position: (width as i32 - 1, v as i32),
                direction: Direction::Left,
            };
            let map1 = Map::new(input);
            let map2 = Map::new(input);
            vec![
                std::thread::spawn(move || {
                    let mut memo = HashSet::new();
                    map1.energized_count(left, &mut memo);
                    unique_points(&memo)
                }),
                std::thread::spawn(move || {
                    let mut memo = HashSet::new();
                    map2.energized_count(right, &mut memo);
                    unique_points(&memo)
                }),
            ]
        })
        .chain((0..width).flat_map(|v| {
            let top = State {
                position: (v as i32, 0),
                direction: Direction::Down,
            };
            let bottom = State {
                position: (v as i32, (height as i32) - 1),
                direction: Direction::Up,
            };
            let map1 = Map::new(input);
            let map2 = Map::new(input);
            vec![
                std::thread::spawn(move || {
                    let mut memo = HashSet::new();
                    map1.energized_count(top, &mut memo);
                    unique_points(&memo)
                }),
                std::thread::spawn(move || {
                    let mut memo = HashSet::new();
                    map2.energized_count(bottom, &mut memo);
                    unique_points(&memo)
                }),
            ]
        }))
        .map(|v| v.join().unwrap())
        .max()
        .unwrap();

    Some(left_right)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, None);
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, None);
    }
}
