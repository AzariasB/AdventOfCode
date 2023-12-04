use advent_of_code::parsers::lines;
use itertools::Itertools;
use std::cmp::min;
use std::collections::HashSet;
advent_of_code::solution!(4);

struct Card {
    winnings: HashSet<u32>,
    owned: HashSet<u32>,
}

impl Card {
    fn parse(input: &str) -> Option<Card> {
        let (_, data) = input.split_once(':')?;
        let (wins, mines) = data.split_once('|')?;
        Some(Card {
            winnings: wins
                .split_ascii_whitespace()
                .map(|v| v.parse().unwrap())
                .collect(),
            owned: mines
                .split_ascii_whitespace()
                .map(|v| v.parse().unwrap())
                .collect(),
        })
    }

    fn winners(&self) -> HashSet<&u32> {
        self.winnings.intersection(&self.owned).collect()
    }
}

// 964337598464 too high
pub fn part_one(input: &str) -> Option<u32> {
    Some(
        lines(input)
            .map(Card::parse)
            .map(|c| {
                let card = c.expect("Invalid card found");
                let det = card.winners();
                if det.is_empty() {
                    0
                } else {
                    (2_u32).pow((det.len() - 1) as u32)
                }
            })
            .sum(),
    )
}

// 1032 too low
pub fn part_two(input: &str) -> Option<u32> {
    let lns = lines(input).collect_vec();
    let mut mult = vec![1_u32; lns.len()];

    lines(input)
        .map(Card::parse)
        .enumerate()
        .for_each(|(i, c)| {
            let card = c.expect("Invalid card found");
            let winners_count = card.winners().len();
            for j in i + 1..min(i + 1 + winners_count, mult.len()) {
                mult[j] += mult[i];
            }
        });
    Some(mult.iter().sum())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(18619));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(8063216));
    }
}
