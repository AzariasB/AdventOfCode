use advent_of_code::parsers::lines;
use itertools::Itertools;
use num::abs;
advent_of_code::solution!(11);

type Point = (usize, usize);

struct Galaxy {
    stars: Vec<Point>,
    x_expand: Vec<u32>,
    y_expand: Vec<u32>,
}

fn carthesian(&(x1, y1): &Point, &(x2, y2): &Point, x_expand: &[u32], y_expand: &[u32]) -> u32 {
    let x_diff = abs(x_expand[x2] as i32 - x_expand[x1] as i32);
    let y_diff = abs(y_expand[y2] as i32 - y_expand[y1] as i32);
    (abs(y1 as i32 - y2 as i32) + abs(x1 as i32 - x2 as i32) + x_diff + y_diff) as u32
}

fn expand(input: &str, distance: u32) -> (Vec<u32>, Vec<u32>) {
    let lns = lines(input).map(|v| v.chars().collect_vec()).collect_vec();
    let height = lns.len();
    let width = lns[0].len();
    let real_dist = distance.saturating_sub(1);

    let y_expands = lns
        .iter()
        .scan(0, |acc, v| {
            if v.iter().all(|&c| c == '.') {
                *acc += real_dist;
            }
            Some(*acc)
        })
        .collect();
    let x_expands = (0..width)
        .scan(0, |acc, x| {
            if (0..height).all(|y| lns[y][x] == '.') {
                *acc += real_dist;
            }
            Some(*acc)
        })
        .collect();
    (x_expands, y_expands)
}

impl Galaxy {
    fn new(input: &str, void_size: u32) -> Galaxy {
        let (x, y) = expand(input, void_size);
        Galaxy {
            stars: lines(input)
                .enumerate()
                .flat_map(|(y, l)| {
                    l.chars().enumerate().filter_map(
                        move |(x, c)| {
                            if c == '#' {
                                Some((x, y))
                            } else {
                                None
                            }
                        },
                    )
                })
                .collect(),
            x_expand: x,
            y_expand: y,
        }
    }

    fn total_distance(&self) -> u64 {
        (0..self.stars.len() - 1)
            .map(|p1| {
                (p1 + 1..self.stars.len())
                    .map(|p2| {
                        carthesian(
                            &self.stars[p1],
                            &self.stars[p2],
                            &self.x_expand,
                            &self.y_expand,
                        ) as u64
                    })
                    .sum::<u64>()
            })
            .sum::<u64>()
    }
}

pub fn part_one(input: &str) -> Option<u64> {
    let glx = Galaxy::new(input, 2);
    Some(glx.total_distance())
}

pub fn part_two(input: &str) -> Option<u64> {
    let glx = Galaxy::new(input, 1000000);
    Some(glx.total_distance())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(9965032));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(550358864332));
    }
}
