use std::collections::{HashMap, HashSet, VecDeque};

use itertools::Itertools;

use advent_of_code::parsers::lines;

use crate::BlockType::{Forest, Path, Slope};

advent_of_code::solution!(23);


#[derive(Copy, Clone, Hash, Eq, PartialEq, Debug)]
struct State {
    x: i32,
    y: i32,
    dx: i32,
    dy: i32,
}

impl State {
    fn new(x: i32, y: i32, dx: i32, dy: i32) -> State {
        State { x, y, dx, dy }
    }

    fn next(&self) -> Vec<State> {
        vec![
            State::new(self.x, self.y, -self.dy, self.dx),
            State::new(self.x, self.y, self.dy, -self.dx),
            State::new(self.x, self.y, self.dx, self.dy),
        ]
    }

    fn step(&self) -> State {
        State::new(self.x + self.dx, self.y + self.dy, self.dx, self.dy)
    }

    fn hash(&self) -> (i32, i32) {
        (self.x, self.y)
    }
}

#[derive(Copy, Clone)]
enum BlockType {
    Forest,
    Slope((i32, i32)),
    Path,
}

impl BlockType {
    fn new(c: char) -> BlockType {
        match c {
            '#' => Forest,
            '.' => Path,
            '>' => Slope((1, 0)),
            '<' => Slope((-1, 0)),
            '^' => Slope((0, -1)),
            'v' => Slope((0, 1)),
            _ => unreachable!("Unknown block type {}", c)
        }
    }

    fn is_walkable(&self) -> bool {
        match self {
            Forest => false,
            Slope(_) => true,
            Path => true
        }
    }
}

struct Map {
    grid: Vec<Vec<BlockType>>,
    width: usize,
    height: usize,
}

struct Node {
    id: u32,
    length: usize,
    connections: Vec<u32>,
    is_terminal: bool,
}

impl Map {
    fn new(input: &str) -> Map {
        let grid = lines(input).map(|l| {
            l.chars().map(BlockType::new).collect()
        }).collect::<Vec<Vec<BlockType>>>();
        Map {
            width: grid[0].len(),
            height: grid.len(),
            grid,
        }
    }

    fn is_end(&self, x: i32, y: i32) -> bool {
        x == (self.width as i32) - 2 && y == (self.height as i32) - 1
    }

    fn try_get_block(&self, state: &State) -> Option<BlockType> {
        self.grid.get(state.y as usize).and_then(|v: &Vec<BlockType>| v.get(state.x as usize).copied())
    }

    fn to_node(&self, x: i32, y:i32) -> Node {

    }

    fn to_graph(&self) -> Vec<Node> {
        let mut queue = VecDeque::from([(State::new(1, 0, 0, 1), HashSet::new())]);
        let mut valid_paths: Vec<u32> = vec![];

        while let Some((pos, mut history)) = queue.pop_front() {
            if history.contains(&pos.hash()) {
                continue;
            }

            if self.is_end(pos.x, pos.y) {
                valid_paths.push(history.len() as u32);
                continue;
            }

            history.insert(pos.hash());
            let nxt = pos.next();
            for s in nxt {
                let s = s.step();
                if let Some(bt) = self.try_get_block(&s) {
                    match bt {
                        Forest => {}
                        Slope((dx, dy)) => {
                            if (dx != 0 && dx != -s.dx) || (dy != 0 && dy != -s.dy) {
                                let forced_state = State::new(s.x, s.y, dx, dy);
                                let mut local_history = history.clone();
                                local_history.insert(forced_state.hash());
                                queue.push_back((forced_state.step(), local_history))
                            }
                        }
                        Path => queue.push_back((s, history.clone()))
                    }
                }
            }
        }

        vec![]
    }

    fn longest_path2(&self, state: State, mut history: HashSet<(i32, i32)>) -> u32 {
        0
    }

    fn longest_path1(&self) -> u32 {
        let mut queue = VecDeque::from([(State::new(1, 0, 0, 1), HashSet::new())]);
        let mut valid_paths: Vec<u32> = vec![];

        while let Some((pos, mut history)) = queue.pop_front() {
            if history.contains(&pos.hash()) {
                continue;
            }

            if self.is_end(pos.x, pos.y) {
                valid_paths.push(history.len() as u32);
                continue;
            }

            history.insert(pos.hash());
            let nxt = pos.next();
            for s in nxt {
                let s = s.step();
                if let Some(bt) = self.try_get_block(&s) {
                    match bt {
                        Forest => {}
                        Slope((dx, dy)) => {
                            if (dx != 0 && dx != -s.dx) || (dy != 0 && dy != -s.dy) {
                                let forced_state = State::new(s.x, s.y, dx, dy);
                                let mut local_history = history.clone();
                                local_history.insert(forced_state.hash());
                                queue.push_back((forced_state.step(), local_history))
                            }
                        }
                        Path => queue.push_back((s, history.clone()))
                    }
                }
            }
        }

        *valid_paths.iter().max().unwrap()
    }
}

pub fn part_one(input: &str) -> Option<u32> {
    Some(Map::new(input).longest_path1())
}

pub fn part_two(input: &str) -> Option<u32> {
    Some(Map::new(input).longest_path2())
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
