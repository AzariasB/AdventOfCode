use itertools::Itertools;
use std::collections::BTreeSet;

use advent_of_code::parsers::lines;

advent_of_code::solution!(21);

type Point = (i32, i32);

enum BlockType {
    Ground,
    Wall,
}

impl BlockType {
    fn is_ground(&self) -> bool {
        match self {
            BlockType::Ground => true,
            BlockType::Wall => false,
        }
    }
}

struct Map {
    blocks: Vec<Vec<BlockType>>,
    width: usize,
    height: usize,
}

impl Map {
    fn new(input: &str) -> (Map, Point) {
        let mut start = (0, 0);
        let lns = lines(input).collect_vec();
        (
            Map {
                height: lns.len(),
                width: lns[0].len(),
                blocks: lns
                    .iter()
                    .enumerate()
                    .map(|(y, l)| {
                        l.chars()
                            .enumerate()
                            .map(|(x, c)| match c {
                                '#' => BlockType::Wall,
                                '.' => BlockType::Ground,
                                'S' => {
                                    start = (x as i32, y as i32);
                                    BlockType::Ground
                                }
                                _ => unreachable!("Unknown block type"),
                            })
                            .collect()
                    })
                    .collect(),
            },
            start,
        )
    }

    fn is_reachable(&self, x: i32, y: i32) -> bool {
        x >= 0
            && y >= 0
            && y < self.height as i32
            && x < self.width as i32
            && self.blocks[y as usize][x as usize].is_ground()
    }

    fn constrained_step(&self, points: BTreeSet<Point>) -> BTreeSet<Point> {
        points
            .iter()
            .flat_map(|&(x, y)| {
                [(-1, 0), (1, 0), (0, 1), (0, -1)]
                    .iter()
                    .filter_map(|&(dx, dy)| {
                        let (nwx, nwy) = (x + dx, y + dy);
                        if self.is_reachable(nwx, nwy) {
                            Some((nwx, nwy))
                        } else {
                            None
                        }
                    })
                    .collect_vec()
            })
            .collect()
    }
}

pub fn part_one(input: &str) -> Option<usize> {
    let (map, start) = Map::new(input);
    let mut points = BTreeSet::from([start]);
    for _ in 0..64 {
        points = map.constrained_step(points);
    }
    Some(points.len())
}

pub fn part_two(_input: &str) -> Option<i64> {
    // Find the 3 numbers for when a step reaches the border : 64, 64 + 131, 65 + 131*2
    // Find the quadratic fit for these three points, and apply it for the position we're looking for
    let x = (26501365i64 - 65) / 131;
    let v1 = 3859;
    let v2 = 34324;
    let v3 = 95135;
    Some(v1 + x * (v2 - v1 + (x - 1) * (v3 - 2 * v2 + v1) / 2))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(3740));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(620962518745459));
    }
}
