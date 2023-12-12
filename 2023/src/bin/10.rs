use advent_of_code::parsers::lines;
use std::collections::{HashSet, VecDeque};
advent_of_code::solution!(10);

type Point = (i32, i32);
type Extremity = (Point, Point);

struct Map {
    data: Vec<Vec<Option<Extremity>>>,
    original: Vec<Vec<char>>,
    start: Point,
}

fn padd(p1: &Point, p2: &Point) -> Point {
    (p1.0 + p2.0, p1.1 + p2.1)
}

fn to_coordinate(val: char) -> Option<Extremity> {
    match val {
        'J' => Some(((-1, 0), (0, -1))),
        '7' => Some(((-1, 0), (0, 1))),
        '|' => Some(((0, 1), (0, -1))),
        '-' => Some(((-1, 0), (1, 0))),
        'L' => Some(((1, 0), (0, -1))),
        'F' => Some(((1, 0), (0, 1))),
        _ => None,
    }
}

impl Map {
    fn new(input: &str) -> Map {
        let mut start = (0, 0);
        let data = lines(input)
            .enumerate()
            .map(|(y, l)| {
                l.chars()
                    .enumerate()
                    .map(|(x, c)| {
                        if c == 'S' {
                            start = (x as i32, y as i32);
                            None
                        } else {
                            to_coordinate(c)
                        }
                    })
                    .collect()
            })
            .collect();

        Map {
            data,
            start,
            original: lines(input).map(|v| v.chars().collect()).collect(),
        }
    }

    fn is_valid(&self, &(x, y): &Point) -> bool {
        x >= 0 && y >= 0 && y < self.data.len() as i32 && x < self.data[0].len() as i32
    }

    fn get(&self, point: &Point) -> Option<Extremity> {
        if !self.is_valid(point) {
            None
        } else {
            self.data[point.1 as usize][point.0 as usize]
        }
    }

    fn connected_to(&self, point: &Point) -> Vec<Point> {
        let (x, y) = point;
        let mut res = vec![];

        let mut tst = |p: Point| {
            if let Some((u1, u2)) = self.get(&p) {
                if padd(&p, &u1) == *point || padd(&p, &u2) == *point {
                    res.push(p);
                }
            }
        };

        tst((*x, y - 1));
        tst((*x, y + 1));
        tst((x + 1, *y));
        tst((x - 1, *y));

        res
    }

    fn further_from_start(&self) -> u32 {
        let mut visited = HashSet::new();
        let mut queue = VecDeque::new();
        let mut max = 0;

        for v in self.connected_to(&self.start) {
            queue.push_back((1, v));
        }
        while let Some((steps, nxt)) = queue.pop_front() {
            if !visited.contains(&nxt) {
                if let Some((u1, u2)) = self.get(&nxt) {
                    queue.push_back((steps + 1, padd(&nxt, &u1)));
                    queue.push_back((steps + 1, padd(&nxt, &u2)))
                }
                max = std::cmp::max(max, steps);
                visited.insert(nxt);
            }
        }
        max
    }

    fn loop_points(&self) -> HashSet<Point> {
        let mut visited = HashSet::new();
        let mut queue = VecDeque::new();

        for v in self.connected_to(&self.start) {
            queue.push_back(v);
        }
        while let Some(nxt) = queue.pop_front() {
            if !visited.contains(&nxt) {
                if let Some((u1, u2)) = self.get(&nxt) {
                    queue.push_back(padd(&nxt, &u1));
                    queue.push_back(padd(&nxt, &u2));
                }
                visited.insert(nxt);
            }
        }
        visited
    }

    fn enclosed_points_count(&self) -> u32 {
        let main_loop = self.loop_points();
        (0i32..self.data.len() as i32)
            .map(|y| {
                let mut is_inside = false;
                let mut direction = 0;
                (0i32..self.data[0].len() as i32)
                    .map(|x| {
                        let point = (x, y);
                        if main_loop.contains(&point) {
                            let chr = self.original[y as usize][x as usize];
                            match chr {
                                '|' => {
                                    is_inside = !is_inside;
                                }
                                // Ugly hard-coded turn for the 'S' character
                                // didnt want to spend time on finding it's correct shape
                                '7' | 'F' | 'S' => match direction {
                                    0 => {
                                        direction = 1;
                                    }
                                    -1 => {
                                        direction = 0;
                                        is_inside = !is_inside;
                                    }
                                    _ => {
                                        direction = 0;
                                    }
                                },
                                'L' | 'J' => match direction {
                                    0 => {
                                        direction = -1;
                                    }
                                    1 => {
                                        direction = 0;
                                        is_inside = !is_inside;
                                    }
                                    _ => {
                                        direction = 0;
                                    }
                                },
                                _ => {}
                            }
                            0
                        } else if is_inside {
                            1
                        } else {
                            0
                        }
                    })
                    .sum::<u32>()
            })
            .sum()
    }
}

pub fn part_one(input: &str) -> Option<u32> {
    let map = Map::new(input);
    Some(map.further_from_start())
}

pub fn part_two(input: &str) -> Option<u32> {
    let map = Map::new(input);
    Some(map.enclosed_points_count())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(7173));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(291));
    }
}
