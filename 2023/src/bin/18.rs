use std::iter::once;

use itertools::Itertools;
use num::abs;

use advent_of_code::parsers::lines;

advent_of_code::solution!(18);

type Point = (i64, i64);

#[derive(Hash, Eq, PartialEq)]
enum Direction {
    Left,
    Right,
    Down,
    Up,
}

impl Direction {
    fn new(input: char) -> Direction {
        match input {
            'U' => Direction::Up,
            'D' => Direction::Down,
            'L' => Direction::Left,
            'R' => Direction::Right,
            _ => unreachable!("Unknown direction"),
        }
    }

    fn apply_to(&self, &(x, y): &Point, coefficient: i64) -> Point {
        match self {
            Direction::Left => (x - coefficient, y),
            Direction::Right => (x + coefficient, y),
            Direction::Down => (x, y + coefficient),
            Direction::Up => (x, y - coefficient),
        }
    }
}

fn str_to_point(start: &Point, input: &str) -> Point {
    let direction = &input[0..1];
    let (count, _) = input[2..].split_once(' ').unwrap();
    let count = count.parse().unwrap();
    Direction::new(direction.chars().next().unwrap()).apply_to(start, count)
}

fn hex_to_point(start: &Point, input: &str) -> Point {
    let v = input.split(' ').nth(2).unwrap()[2..].replace(')', "");
    let exa = i64::from_str_radix(&v[0..v.len() - 1], 16).unwrap();
    let dir = v[v.len() - 1..v.len()].chars().next().unwrap();
    let dir = match dir {
        '0' => Direction::Right,
        '1' => Direction::Down,
        '2' => Direction::Left,
        '3' => Direction::Up,
        _ => unreachable!("Invalid direction digit"),
    };
    dir.apply_to(start, exa)
}

fn distance(&(x1, y1): &Point, &(x2, y2): &Point) -> i64 {
    abs(if x1 == x2 { y2 - y1 } else { x2 - x1 })
}

pub fn part_one(input: &str) -> Option<i64> {
    let start = (0, 0);
    let lines = once(start)
        .chain(lines(input).scan(start, |state, v| {
            let next = str_to_point(state, v);
            *state = next;
            Some(next)
        }))
        .collect_vec()
        .windows(2)
        .map(|w| {
            let (a, c) = w[0];
            let (d, b) = w[1];
            (c + b) * (a - d) + distance(&w[0], &w[1])
        })
        .sum::<i64>()
        / 2i64
        + 1;

    Some(lines)
}

pub fn part_two(input: &str) -> Option<i64> {
    let start = (0, 0);
    let lines = once(start)
        .chain(lines(input).scan(start, |state, v| {
            let next = hex_to_point(state, v);
            *state = next;
            Some(next)
        }))
        .collect_vec()
        .windows(2)
        .map(|w| {
            let (a, c) = w[0];
            let (d, b) = w[1];
            (c + b) * (a - d) + distance(&w[0], &w[1])
        })
        .sum::<i64>()
        / 2i64
        + 1;

    Some(lines)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(36679));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(88007104020978));
    }
}
