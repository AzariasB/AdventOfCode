use itertools::Itertools;
use std::ops::Range;
advent_of_code::solution!(13);

fn is_mirror(input: &[char]) -> bool {
    let res = input.len() % 2 == 0
        && input.iter().collect::<String>() == input.iter().rev().collect::<String>();
    res
}

fn diffs(input: &[char]) -> u32 {
    if input.len() % 2 != 0 {
        return 10;
    }
    input
        .iter()
        .zip(input.iter().rev())
        .filter(|(a, b)| a != b)
        .count() as u32
        / 2
}

fn transpose<T>(v: &Vec<Vec<T>>) -> Vec<Vec<T>>
where
    T: Clone,
{
    assert!(!v.is_empty());
    (0..v[0].len())
        .map(|x| (0..v.len()).map(|y| v[y][x].clone()).collect())
        .collect()
}

fn try_mirror(group: &[Vec<char>]) -> Option<usize> {
    let end = group[0].len();

    for i in 0..(group[0].len() - 1) {
        if group.iter().all(|v| is_mirror(&v[i..])) {
            return Some(i + (end - i) / 2);
        }
        if group.iter().all(|v| is_mirror(&v[0..end - i])) {
            return Some((end - i) / 2);
        }
    }
    None
}

fn has_one_change(input: &Vec<Vec<char>>, index: Range<usize>) -> bool {
    let mut found = false;
    for it in input {
        let ds = diffs(&it[index.start..index.end]);
        if ds > 1 {
            return false;
        }
        if ds == 1 {
            if found {
                return false;
            }
            found = true;
        }
    }
    found
}

fn one_change_allowed(group: &Vec<Vec<char>>) -> Option<usize> {
    let end = group[0].len();

    for i in 0..(end - 1) {
        if has_one_change(group, i..end) {
            return Some(i + (end - i) / 2);
        }
        if has_one_change(group, 0..(end - i)) {
            return Some((end - i) / 2);
        }
    }
    None
}

fn cleanest(group: &Vec<Vec<char>>) -> usize {
    if let Some(v) = one_change_allowed(group) {
        return v;
    }
    let t = transpose(group);
    if let Some(v) = one_change_allowed(&t) {
        return v * 100;
    }

    let format = group
        .iter()
        .map(|v| v.iter().collect::<String>())
        .join("\n");

    unreachable!("Could not find a mirror for\n{}", format)
}

fn mirror_value(group: &Vec<Vec<char>>) -> usize {
    if let Some(v) = try_mirror(group) {
        return v;
    }

    let t = transpose(group);
    if let Some(v) = try_mirror(&t) {
        return v * 100;
    }

    let format = group
        .iter()
        .map(|v| v.iter().collect::<String>())
        .join("\n");

    unreachable!("Could not find a mirror for\n{}", format)
}

fn to_groups(input: &str) -> Vec<Vec<Vec<char>>> {
    let mut res = vec![];
    let mut acc = vec![];
    for l in input.lines() {
        if l.trim().is_empty() {
            res.push(acc);
            acc = vec![];
        } else {
            acc.push(l.chars().collect());
        }
    }
    if !acc.is_empty() {
        res.push(acc);
    }
    res
}

pub fn part_one(input: &str) -> Option<u32> {
    let groups = to_groups(input);
    Some(groups.iter().map(|v| mirror_value(v) as u32).sum())
}

pub fn part_two(input: &str) -> Option<u32> {
    let groups = to_groups(input);
    Some(groups.iter().map(|v| cleanest(v) as u32).sum())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(37381));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(28210));
    }
}
