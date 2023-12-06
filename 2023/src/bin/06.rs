use advent_of_code::parsers::lines;
use itertools::Itertools;
advent_of_code::solution!(6);

fn get_ints(input: &str) -> Vec<u32> {
    input
        .split_once(':')
        .unwrap()
        .1
        .trim()
        .split_ascii_whitespace()
        .map(|v| v.parse().unwrap())
        .collect()
}

fn better_than_best(b: f64, c: f64) -> u32 {
    let delta = b * b - 4f64 * c;
    let x1 = (-b + f64::sqrt(delta)) / -2f64;
    let x2 = (-b - f64::sqrt(delta)) / -2f64;
    (x2.ceil() - x1.ceil()) as u32
}

pub fn part_one(input: &str) -> Option<u32> {
    let (time, distance) = lines(input).collect_tuple().unwrap();
    let times = get_ints(time);
    let distances = get_ints(distance);
    Some(
        times
            .iter()
            .zip(distances)
            .map(|(&t, d)| better_than_best(t as f64, d as f64))
            .product(),
    )
}

fn get_spaced_int(input: &str) -> u64 {
    input
        .split_once(':')
        .unwrap()
        .1
        .replace(' ', "")
        .parse()
        .unwrap()
}

pub fn part_two(input: &str) -> Option<u32> {
    let (time, distance) = lines(input).collect_tuple().unwrap();
    let time = get_spaced_int(time);
    let distance = get_spaced_int(distance);

    Some(better_than_best(time as f64, distance as f64))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(3316275));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(27102791));
    }
}
