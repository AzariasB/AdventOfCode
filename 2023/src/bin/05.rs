use itertools::Itertools;
use std::collections::VecDeque;
advent_of_code::solution!(5);

struct Range {
    start: u64,
    replacement: u64,
    size: u64,
}

#[derive(Copy, Clone)]
struct SeedRange {
    from: u64,
    size: u64,
}

impl Range {
    pub fn in_range(&self, value: u64) -> bool {
        value >= self.start && value - self.start < self.size
    }

    pub fn shift(&self, value: u64) -> u64 {
        let diff = value - self.start;
        self.replacement + diff
    }

    pub fn divide(&self, slice: SeedRange) -> (Vec<SeedRange>, Option<SeedRange>) {
        let slice_end = slice.from + slice.size;
        let self_end = self.start + self.size;

        if slice.from < self.start {
            if slice_end > self_end {
                // Seed range outside on both sides of range
                let left = SeedRange {
                    from: slice.from,
                    size: self.start - slice.from,
                };
                let middle = SeedRange {
                    from: self.replacement,
                    size: self.size,
                };
                let right = SeedRange {
                    from: self_end + 1,
                    size: slice_end - self_end,
                };
                return (vec![left, right], Some(middle));
            }
            if slice_end < self.start {
                return (vec![slice], None);
            }
            // seed range half-contained in range
            return (
                vec![SeedRange {
                    from: slice.from,
                    size: self.start - slice.from,
                }],
                Some(SeedRange {
                    from: self.replacement,
                    size: self_end - self.start,
                }),
            );
        }

        if slice.from <= self_end {
            let diff = slice.from - self.start;
            if slice_end <= self_end {
                // seed range contained
                return (
                    vec![],
                    Some(SeedRange {
                        from: self.replacement + diff,
                        size: slice.size,
                    }),
                );
            }
            return (
                vec![SeedRange {
                    from: slice_end,
                    size: slice_end - self_end,
                }],
                Some(SeedRange {
                    from: self.replacement + diff,
                    size: self_end - slice.from,
                }),
            );
        }
        (vec![slice], None)
    }
}

fn parse_seeds(seeds: &str) -> Vec<u64> {
    seeds[7..]
        .split_ascii_whitespace()
        .map(|v| v.parse().unwrap())
        .collect_vec()
}

fn parse_map(lines: &mut VecDeque<&str>) -> Vec<Range> {
    lines.pop_front().unwrap();
    let mut res = vec![];
    loop {
        if lines.is_empty() {
            return res;
        }
        let next = lines.pop_front().unwrap();
        if next.trim().is_empty() {
            return res;
        }
        let (dest, start, count) = next
            .split_ascii_whitespace()
            .map(|v| v.parse::<u64>().unwrap())
            .collect_tuple()
            .unwrap();
        res.push(Range {
            start,
            replacement: dest,
            size: count,
        });
    }
}

fn seed_soil(seed: u64, process: &[Vec<Range>]) -> u64 {
    process.iter().fold(seed, |acc, vec| {
        if let Some(range) = vec.iter().find(|&val| val.in_range(acc)) {
            range.shift(acc)
        } else {
            acc
        }
    })
}

pub fn part_one(input: &str) -> Option<u64> {
    let mut data: VecDeque<&str> = input.lines().collect();
    let seeds = parse_seeds(data.pop_front().unwrap());
    data.pop_front().unwrap();
    let mut maps = vec![];
    while !data.is_empty() {
        maps.push(parse_map(&mut data));
    }

    Some(
        seeds
            .iter()
            .map(|&seed| seed_soil(seed, &maps))
            .min()
            .unwrap(),
    )
}

fn parse_seed_ranges(seeds: &str) -> Vec<SeedRange> {
    seeds[7..]
        .split_ascii_whitespace()
        .map(|v| v.parse::<u64>().unwrap())
        .tuples()
        .map(|(a, b)| SeedRange { from: a, size: b })
        .collect()
}

fn seed_range_soil(root: SeedRange, process: &[Vec<Range>]) -> u64 {
    let mut remaining_seeds = vec![root];
    let mut processed_seeds = vec![];

    for proc in process {
        for r in proc {
            let mut next_batch = vec![];
            for seed in remaining_seeds {
                let (mut rems, treated) = r.divide(seed);
                if let Some(rng) = treated {
                    processed_seeds.push(rng);
                }
                next_batch.append(&mut rems);
            }
            remaining_seeds = next_batch;
        }
        remaining_seeds.append(&mut processed_seeds);
    }
    remaining_seeds
        .iter()
        .min_by(|a, b| a.from.cmp(&b.from))
        .unwrap()
        .from
}

pub fn part_two(input: &str) -> Option<u64> {
    let mut data: VecDeque<&str> = input.lines().collect();
    let seeds = parse_seed_ranges(data.pop_front().unwrap());
    data.pop_front().unwrap();
    let mut maps = vec![];
    while !data.is_empty() {
        maps.push(parse_map(&mut data));
    }

    Some(
        seeds
            .iter()
            .map(|&seed| seed_range_soil(seed, &maps))
            .min()
            .unwrap(),
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(278755257));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(26829166));
    }
}
