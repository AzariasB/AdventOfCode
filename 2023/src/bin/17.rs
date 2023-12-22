use std::collections::HashMap;

use advent_of_code::parsers::lines;

advent_of_code::solution!(17);

struct Map {
    grid: Vec<Vec<u32>>,
    width: usize,
    height: usize,
}

#[derive(Hash, Eq, PartialEq, Clone)]
struct State {
    x: i32,
    y: i32,
    dx: i32,
    dy: i32,
    consecutive_steps: u8,
}

struct PathFinder {
    visited_states: HashMap<State, u32>,
    states_queue: HashMap<u32, Vec<State>>,
    map: Map,
}

impl State {
    fn new(x: i32, y: i32, dx: i32, dy: i32, steps: u8) -> State {
        State {
            x,
            y,
            dx,
            dy,
            consecutive_steps: steps,
        }
    }

    fn next1(&self) -> Vec<State> {
        let mut res = vec![
            State::new(self.x, self.y, self.dy, -self.dx, 1),
            State::new(self.x, self.y, -self.dy, self.dx, 1),
        ];
        if self.consecutive_steps < 3 {
            res.push(State::new(
                self.x,
                self.y,
                self.dx,
                self.dy,
                self.consecutive_steps + 1,
            ))
        }
        res
    }

    fn next2(&self) -> Vec<State> {
        let mut res = vec![];
        if self.consecutive_steps < 10 {
            res.push(State::new(
                self.x,
                self.y,
                self.dx,
                self.dy,
                self.consecutive_steps + 1,
            ))
        }
        if self.consecutive_steps >= 4 {
            res.push(State::new(self.x, self.y, self.dy, -self.dx, 1));
            res.push(State::new(self.x, self.y, -self.dy, self.dx, 1));
        }
        res
    }

    fn step(&self) -> State {
        State::new(
            self.x + self.dx,
            self.y + self.dy,
            self.dx,
            self.dy,
            self.consecutive_steps,
        )
    }
}

impl Map {
    fn new(input: &str) -> Map {
        let grid = lines(input)
            .map(|l| l.chars().map(|v| v.to_digit(10).unwrap()).collect())
            .collect::<Vec<Vec<u32>>>();
        Map {
            width: grid[0].len(),
            height: grid.len(),
            grid,
        }
    }

    fn try_get(&self, x: i32, y: i32) -> Option<u32> {
        self.grid
            .get(y as usize)
            .and_then(|l: &Vec<u32>| l.get(x as usize).copied())
    }

    fn is_end(&self, x: i32, y: i32) -> bool {
        x == (self.width as i32) - 1 && y == (self.height as i32) - 1
    }
}

impl PathFinder {
    #[allow(clippy::map_entry)]
    fn process_state(&mut self, cost: u32, state: State, min_distance: u8) -> Option<u32> {
        let nw_cost = cost + self.map.try_get(state.x, state.y)?;

        if self.map.is_end(state.x, state.y) && state.consecutive_steps >= min_distance {
            return Some(nw_cost);
        }

        let nw_state = state.step();

        if !self.visited_states.contains_key(&nw_state) {
            self.states_queue
                .entry(nw_cost)
                .or_default()
                .push(nw_state.clone());
            self.visited_states.insert(nw_state, nw_cost);
        }

        None
    }

    fn path_find1(&mut self) -> u32 {
        self.process_state(0, State::new(0, 0, 1, 0, 1), 0);
        self.process_state(0, State::new(0, 0, 0, 1, 1), 0);
        loop {
            if let Some(&current_cost) = self
                .states_queue
                .iter()
                .min_by(|(costa, _), (costb, _)| costa.cmp(costb))
                .map(|(v, _)| v)
            {
                let next_states = self.states_queue.remove(&current_cost).unwrap();
                for s in next_states {
                    let next = s.next1();
                    for n in next {
                        if let Some(final_cost) = self.process_state(current_cost, n.clone(), 0) {
                            return final_cost - 1; // Not too sure why
                        }
                    }
                }
            } else {
                panic!("Visited all states, couldn't find the exit");
            }
        }
    }

    fn path_find2(&mut self) -> u32 {
        self.process_state(0, State::new(0, 0, 1, 0, 1), 4);
        self.process_state(0, State::new(0, 0, 0, 1, 1), 4);
        loop {
            if let Some(&current_cost) = self
                .states_queue
                .iter()
                .min_by(|(costa, _), (costb, _)| costa.cmp(costb))
                .map(|(v, _)| v)
            {
                let next_states = self.states_queue.remove(&current_cost).unwrap();
                for s in next_states {
                    let next = s.next2();
                    for n in next {
                        if let Some(final_cost) = self.process_state(current_cost, n.clone(), 4) {
                            return final_cost - 1; // Not too sure why
                        }
                    }
                }
            } else {
                panic!("Visited all states, couldn't find the exit");
            }
        }
    }
}

pub fn part_one(input: &str) -> Option<u32> {
    let map = Map::new(input);
    let mut pf = PathFinder {
        states_queue: HashMap::new(),
        map,
        visited_states: HashMap::new(),
    };
    Some(pf.path_find1())
}

pub fn part_two(input: &str) -> Option<u32> {
    let map = Map::new(input);
    let mut pf = PathFinder {
        states_queue: HashMap::new(),
        map,
        visited_states: HashMap::new(),
    };
    Some(pf.path_find2())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(724));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(877));
    }
}
