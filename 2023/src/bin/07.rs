use crate::HandType::{
    FiveOfAKind, FourOfAKind, FullHouse, HighCard, OnePair, ThreeOfAKind, TwoPair,
};
use advent_of_code::parsers::lines;
use itertools::Itertools;
use std::cmp::Ordering;
advent_of_code::solution!(7);

#[derive(PartialOrd, Ord, PartialEq, Eq)]
enum HandType {
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind,
}

struct Hand {
    value: (u32, u32, u32, u32, u32),
    bet: u32,
    strength: HandType,
}

impl Hand {
    fn new(input: &str, jokers_enabled: bool) -> Hand {
        let (original, bet) = input.split_once(' ').unwrap();
        let hand = HandType::new(original, jokers_enabled);
        let bet = bet.parse::<u32>().unwrap();
        Hand {
            value: original
                .chars()
                .map(if jokers_enabled {
                    card_value_bis
                } else {
                    card_value
                })
                .collect_tuple()
                .unwrap(),
            strength: hand,
            bet,
        }
    }

    fn cmp(&self, other: &Hand) -> Ordering {
        if std::mem::discriminant(&self.strength) == std::mem::discriminant(&other.strength) {
            self.value.cmp(&other.value)
        } else {
            self.strength.cmp(&other.strength)
        }
    }
}

impl HandType {
    fn new(input: &str, jokers_enabled: bool) -> HandType {
        let values = input
            .chars()
            .map(card_value)
            .sorted() // necessary for the groupby to work
            .group_by(|&v| v)
            .into_iter()
            .map(|(k, v)| (k, v.collect_vec().len() as u32))
            .sorted_by(
                |(k1, v1), (k2, v2)| {
                    if v1 == v2 {
                        k2.cmp(k1)
                    } else {
                        v2.cmp(v1)
                    }
                },
            )
            .collect_vec();
        let jokers = input.chars().filter(|&v| v == 'J').count();
        match values.len() {
            1 => FiveOfAKind,
            2 => match values[0].1 {
                4 => {
                    if jokers_enabled && jokers > 0 {
                        FiveOfAKind
                    } else {
                        FourOfAKind
                    }
                }
                3 => {
                    if jokers_enabled && jokers > 0 {
                        FiveOfAKind
                    } else {
                        FullHouse
                    }
                }
                _ => unreachable!(),
            },
            3 => {
                let max = values[0].1;
                if max == 3 {
                    if jokers_enabled && jokers > 0 {
                        FourOfAKind
                    } else {
                        ThreeOfAKind
                    }
                } else if max == 2 {
                    if jokers_enabled {
                        if jokers == 2 {
                            FourOfAKind
                        } else if jokers == 1 {
                            FullHouse
                        } else {
                            TwoPair
                        }
                    } else {
                        TwoPair
                    }
                } else {
                    unreachable!();
                }
            }
            4 => {
                if jokers_enabled && jokers > 0 {
                    ThreeOfAKind
                } else {
                    OnePair
                }
            }
            _ => {
                if jokers_enabled && jokers > 0 {
                    OnePair
                } else {
                    HighCard
                }
            }
        }
    }
}

const ORDER: &str = "23456789TJQKA";

fn card_value(card: char) -> u32 {
    ORDER.find(|c| c == card).unwrap() as u32
}

const ORDER_BIS: &str = "J23456789TQKA";

fn card_value_bis(card: char) -> u32 {
    ORDER_BIS.find(|c| c == card).unwrap() as u32
}

pub fn part_one(input: &str) -> Option<u32> {
    Some(
        lines(input)
            .map(|ln| Hand::new(ln, false))
            .sorted_by(|a, b| a.cmp(b))
            .enumerate()
            .map(|(k, h)| (k as u32 + 1) * h.bet)
            .sum(),
    )
}

pub fn part_two(input: &str) -> Option<u32> {
    Some(
        lines(input)
            .map(|ln| Hand::new(ln, true))
            .sorted_by(|a, b| a.cmp(b))
            .enumerate()
            .map(|(k, h)| (k as u32 + 1) * h.bet)
            .sum(),
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(250951660));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(251481660));
    }
}
