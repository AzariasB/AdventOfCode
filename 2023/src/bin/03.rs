use advent_of_code::parsers::lines;
use itertools::Itertools;
use regex::Regex;
advent_of_code::solution!(3);

pub fn part_one(input: &str) -> Option<u32> {
    let lns = lines(input).collect_vec();
    let reg = Regex::new(r"\d+").unwrap();
    let ln_len = lns[0].len();
    let mut sum: u32 = 0;

    for (i, &l) in lns.iter().enumerate() {
        reg.find_iter(l).for_each(|s| {
            let left = s.start().saturating_sub(1);
            let right = s.end();
            let reg = format!(r"^.{{{},{}}}[^\d.\s]", left, right);
            let test = Regex::new(reg.as_str()).unwrap();
            if s.start() > 0 && l.chars().nth(left).unwrap() != '.'
                || right < ln_len && l.chars().nth(right).unwrap() != '.'
                || i > 0 && test.is_match(lns[i - 1])
                || i < ln_len - 1 && test.is_match(lns[i + 1])
            {
                let num = s.as_str().parse::<u32>().expect("Invalid number");
                sum += num;
            }
        })
    }

    Some(sum)
}

fn left_str(input: &str, pos: usize) -> Option<u32> {
    input[0..pos]
        .chars()
        .rev()
        .take_while(|c| c.is_ascii_digit())
        .collect_vec()
        .iter()
        .rev()
        .collect::<String>()
        .parse::<u32>()
        .ok()
}

fn right_str(input: &str, pos: usize) -> Option<u32> {
    input[(pos + 1)..]
        .chars()
        .take_while(|c| c.is_ascii_digit())
        .collect::<String>()
        .parse::<u32>()
        .ok()
}

fn top_str(input: &str, pos: usize) -> Vec<u32> {
    let middle = input.chars().nth(pos).unwrap();
    if middle.is_ascii_digit() {
        let left = input[0..pos]
            .chars()
            .rev()
            .take_while(|c| c.is_ascii_digit())
            .collect_vec()
            .iter()
            .rev()
            .collect::<String>();
        let right = input[(pos + 1)..]
            .chars()
            .take_while(|c| c.is_ascii_digit())
            .collect::<String>();
        let total = format!("{}{}{}", left, middle, right);
        vec![total.parse().unwrap()]
    } else {
        let mut res = vec![];
        if pos > 0 && input.chars().nth(pos - 1).unwrap().is_ascii_digit() {
            let reg = format!(
                r"^.{{{},{}}}?(\d+)",
                pos.saturating_sub(3),
                pos.saturating_sub(1)
            );
            let test = Regex::new(reg.as_str()).unwrap();
            res.push(
                test.captures(input)
                    .iter()
                    .map(|c| c.get(1).unwrap().as_str().parse().unwrap())
                    .next()
                    .unwrap(),
            );
        }
        if pos < input.len() - 1 && input.chars().nth(pos + 1).unwrap().is_ascii_digit() {
            res.push(
                input[(pos + 1)..]
                    .chars()
                    .take_while(|c| c.is_ascii_digit())
                    .collect::<String>()
                    .parse()
                    .unwrap(),
            )
        }
        res
    }
}

pub fn part_two(input: &str) -> Option<u32> {
    let lns = lines(input).collect_vec();
    let mut prod = 0;
    for (i, l) in lns.iter().enumerate() {
        for (p, c) in l.chars().enumerate() {
            if c == '*' {
                let mut side = [left_str(l, p), right_str(l, p)]
                    .iter()
                    .filter_map(|&v| v)
                    .collect_vec();
                if i > 0 {
                    side.append(&mut top_str(lns[i - 1], p));
                }
                if i < lns.len() - 1 {
                    side.append(&mut top_str(lns[i + 1], p))
                }
                if side.len() == 2 {
                    prod += side.iter().product::<u32>();
                }
            }
        }
    }
    Some(prod)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(553825));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(93994191));
    }
}
