use advent_of_code::parsers::lines;
use itertools::Itertools;
use num::Integer;
use std::collections::{HashMap, VecDeque};
advent_of_code::solution!(8);

type Tree = HashMap<String, (String, String)>;

fn parse_graph(input: VecDeque<&str>) -> Tree {
    let mut res = Tree::new();
    for ln in input {
        let (name, paths) = ln.split_once(" = ").unwrap();
        let (left, right) = paths.split_once(", ").unwrap();
        res.insert(
            name.to_string(),
            (left[1..].to_string(), right.to_string().replace(')', "")),
        );
    }
    res
}

fn apply_instruction(tree: &Tree, pos: &String, instruction: char) -> String {
    let (l, r) = tree.get(pos).unwrap();
    (if instruction == 'L' { l } else { r }).to_string()
}

pub fn part_one(input: &str) -> Option<u32> {
    let mut lns: VecDeque<&str> = lines(input).collect();
    let instrs = lns.pop_front().unwrap().chars().collect_vec();
    let tree = parse_graph(lns);
    let mut pos = "AAA".to_string();
    let mut moves = 1;
    for i in instrs.iter().cycle() {
        pos = apply_instruction(&tree, &pos, *i);
        if pos == "ZZZ" {
            return Some(moves);
        }
        moves += 1;
    }

    unreachable!();
}

pub fn part_two(input: &str) -> Option<u64> {
    let mut lns: VecDeque<&str> = lines(input).collect();
    let instr = lns.pop_front().unwrap().chars().collect_vec();
    let tree = parse_graph(lns);
    let cycles = tree
        .keys()
        .filter(|s| s.ends_with('A'))
        .map(|start| {
            let mut moves = 1u64;
            let mut pos = start.to_string();
            for i in instr.iter().cycle() {
                pos = apply_instruction(&tree, &pos, *i);
                if pos.ends_with('Z') {
                    return moves;
                }
                moves += 1;
            }
            unreachable!();
        })
        .collect_vec();
    Some(cycles.iter().fold(1, |a, b| a.lcm(b)))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(18113));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(12315788159977u64));
    }
}
