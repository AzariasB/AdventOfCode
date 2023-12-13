use advent_of_code::parsers::lines;
use std::collections::HashMap;
advent_of_code::solution!(12);

struct Onsen {
    flow: String,
    groups: Vec<u32>,
}

#[derive(Eq, PartialEq, Hash, Debug)]
struct OnSlice<'a> {
    flow: &'a str,
    groups: &'a [u32],
}

impl Onsen {
    fn new(input: &str, repetitions: usize) -> Onsen {
        let (a, b) = input.split_once(' ').unwrap();
        let final_flow = [a].repeat(repetitions).join("?");
        let final_groups = [b].repeat(repetitions).join(",");

        Onsen {
            flow: final_flow.chars().skip_while(|&v| v == '.').collect(),
            groups: final_groups
                .split(',')
                .map(|v| v.parse().unwrap())
                .collect(),
        }
    }

    fn to_slice(&self) -> OnSlice {
        OnSlice {
            flow: &self.flow,
            groups: &self.groups,
        }
    }

    fn arrangements(&self) -> u64 {
        let mut memo = HashMap::new();
        let start = self.to_slice();
        start.possible_solutions(&mut memo)
    }
}

fn start_fits(input: &str, size: usize) -> bool {
    if input.len() < size {
        return false;
    }
    if input.len() == size {
        input.chars().all(|c| c != '.')
    } else {
        input.chars().take(size).filter(|&v| v != '.').count() == size
            && input.chars().nth(size).unwrap() != '#'
    }
}

impl<'a> OnSlice<'a> {
    fn possible_solutions(&self, memo: &mut HashMap<OnSlice<'a>, u64>) -> u64 {
        if self.groups.is_empty() {
            return if self.flow.chars().all(|v| v != '#') {
                1
            } else {
                0
            };
        }

        if self.flow.is_empty() {
            return 0;
        }

        if let Some(&exists) = memo.get(self) {
            return exists;
        }

        let max_incr = self
            .flow
            .len()
            .saturating_sub(
                self.groups.iter().sum::<u32>() as usize + self.groups.len().saturating_sub(1),
            )
            .saturating_add(1);
        let current = self.groups[0] as usize;
        let mut res = 0;
        for i in 0..max_incr {
            let slice = &self.flow[i..];
            if start_fits(slice, current) {
                let sub_flow = if (i + current + 1) > self.flow.len() {
                    ""
                } else {
                    &self.flow[(i + current + 1)..]
                };

                let next = OnSlice {
                    groups: &self.groups[1..],
                    flow: sub_flow,
                };

                if let Some(val) = memo.get(&next) {
                    res += val
                } else {
                    let sub = next.possible_solutions(memo);
                    memo.insert(next, sub);
                    res += sub;
                }
            }

            if &slice[0..1] == "#" {
                break;
            }
        }

        res
    }
}

pub fn part_one(input: &str) -> Option<u64> {
    Some(lines(input).map(|l| Onsen::new(l, 1).arrangements()).sum())
}

// Too high
pub fn part_two(input: &str) -> Option<u64> {
    Some(lines(input).map(|l| Onsen::new(l, 5).arrangements()).sum())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(7118));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(7030194981795));
    }
}
