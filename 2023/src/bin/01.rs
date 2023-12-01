use advent_of_code::parsers::lines;
advent_of_code::solution!(1);

fn to_digit(input: &str) -> Option<u32> {
    input.chars().find(|c| c.is_ascii_digit()).and_then(|f| {
        input
            .chars()
            .rev()
            .find(|c| c.is_ascii_digit())
            .and_then(|l| format!("{}{}", f, l).parse::<u32>().ok())
    })
}

pub fn part_one(input: &str) -> Option<u32> {
    Some(lines(input).map(|s| to_digit(s).unwrap()).sum())
}

/**
The right calibration values for string "eighthree" is 83 and for "sevenine" is 79.
 **/
fn normalize_digits(input: &str) -> String {
    [
        ("one", "o1e"),
        ("two", "t2o"),
        ("three", "t3e"),
        ("four", "f4r"),
        ("five", "f5e"),
        ("six", "s6x"),
        ("seven", "s7n"),
        ("eight", "e8t"),
        ("nine", "n9e"),
    ]
    .iter()
    .fold(input.to_string(), |acc, (b, a)| acc.replace(b, a))
}

pub fn part_two(input: &str) -> Option<u32> {
    Some(
        lines(input)
            .map(|s| to_digit(normalize_digits(s).as_str()).unwrap())
            .sum(),
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("examples", DAY));
        assert_eq!(result, None);
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("examples", DAY));
        assert_eq!(result, None);
    }
}
