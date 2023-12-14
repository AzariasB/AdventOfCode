use advent_of_code::parsers::lines;
use itertools::Itertools;
use std::collections::HashMap;
advent_of_code::solution!(14);

type Platform = Vec<Vec<char>>;

type History = Vec<u128>;

fn to_platform(input: &str) -> Platform {
    lines(input).map(|l| l.chars().collect()).collect()
}

fn to_history(platform: &Platform) -> History {
    platform
        .iter()
        .map(|r| {
            r.iter().enumerate().fold(
                0u128,
                |acc, (x, &c)| if c == 'O' { acc | (1 << x) } else { acc },
            )
        })
        .collect()
}

fn tilt_x_axis(platform: &Platform, rev: bool) -> Platform {
    let mut res = vec![vec!['.'; platform[0].len()]; platform.len()];
    let mut bottom = vec![];
    let lowest = if rev { platform.len() - 1 } else { 0 };
    let next = if rev {
        |v: usize| v.saturating_sub(1)
    } else {
        |v: usize| v + 1
    };
    let iter = if rev {
        platform.iter().enumerate().rev().collect_vec()
    } else {
        platform.iter().enumerate().collect_vec()
    };

    for (y, row) in iter {
        bottom = if y == lowest {
            row.iter()
                .enumerate()
                .map(|(x, &c)| {
                    if c == '.' {
                        lowest
                    } else {
                        res[lowest][x] = c;
                        next(lowest)
                    }
                })
                .collect()
        } else {
            row.iter()
                .enumerate()
                .map(|(x, &v)| match v {
                    '#' => {
                        res[y][x] = '#';
                        next(y)
                    }
                    'O' => {
                        res[bottom[x]][x] = 'O';
                        next(bottom[x])
                    }
                    _ => bottom[x],
                })
                .collect()
        }
    }
    res
}

fn tilt_y_axis(platform: &Platform, rev: bool) -> Platform {
    let lowest = if rev { platform[0].len() - 1 } else { 0 };
    let next = if rev {
        |v: usize| v.saturating_sub(1)
    } else {
        |v: usize| v + 1
    };

    platform
        .iter()
        .map(|v| {
            let mut res = vec!['.'; v.len()];
            let iter = if rev {
                v.iter().enumerate().rev().collect_vec()
            } else {
                v.iter().enumerate().collect_vec()
            };

            iter.iter().fold(lowest, |bottom, (x, c)| match c {
                '#' => {
                    res[*x] = '#';
                    next(*x)
                }
                'O' => {
                    res[bottom] = 'O';
                    next(bottom)
                }
                _ => bottom,
            });
            res
        })
        .collect()
}

fn platform_score(platform: &Platform) -> u64 {
    let height = platform.len();
    platform
        .iter()
        .enumerate()
        .flat_map(|(y, row)| {
            row.iter()
                .map(move |&c| if c == 'O' { (height - y) as u64 } else { 0 })
        })
        .sum::<u64>()
}

fn cycle(platform: &Platform) -> Platform {
    tilt_y_axis(
        &tilt_x_axis(&tilt_y_axis(&tilt_x_axis(platform, false), false), true),
        true,
    )
}

fn state_after(platform: &Platform, cycles: u64) -> Platform {
    let mut memo = HashMap::from([(to_history(platform), 0u64)]);
    let mut current = platform.clone();
    for i in 0..cycles {
        current = cycle(&current);
        let h = to_history(&current);
        if let Some(&val) = memo.get(&h) {
            let cycle_size = i - val;
            let rest = cycles - i;
            let final_steps = rest % cycle_size;
            for _ in 0..final_steps {
                current = cycle(&current);
            }
            return current;
        } else {
            memo.insert(h, i);
        }
    }
    current
}

pub fn part_one(input: &str) -> Option<u64> {
    Some(platform_score(&tilt_x_axis(&to_platform(input), false)))
}

pub fn part_two(input: &str) -> Option<u64> {
    Some(platform_score(&state_after(
        &to_platform(input),
        1000000000 - 1,
    )))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(113525));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(101292));
    }
}
