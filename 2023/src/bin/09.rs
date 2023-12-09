use advent_of_code::parsers::lines;
advent_of_code::solution!(9);

fn parse_line(line: &str) -> Vec<i64> {
    line.split_ascii_whitespace()
        .map(|v| v.parse().unwrap())
        .collect()
}

fn find_last(input: Vec<i64>) -> i64 {
    if input.iter().all(|&v| v == 0) {
        0
    } else {
        find_last(input.windows(2).map(|v| v[1] - v[0]).collect()) + input.last().unwrap()
    }
}

fn find_first(input: Vec<i64>) -> i64 {
    if input.iter().all(|&v| v == 0) {
        0
    } else {
        input.first().unwrap() - find_first(input.windows(2).map(|v| v[1] - v[0]).collect())
    }
}

pub fn part_one(input: &str) -> Option<i64> {
    Some(lines(input).map(parse_line).map(find_last).sum())
}

pub fn part_two(input: &str) -> Option<i64> {
    Some(lines(input).map(parse_line).map(find_first).sum())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(1901217887));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(905));
    }
}
