use std::cmp;
use std::collections::{HashMap, HashSet, VecDeque};
use std::sync::atomic::{AtomicU32, Ordering};

use itertools::Itertools;

use advent_of_code::parsers::lines;

advent_of_code::solution!(22);

static ID_GENERATOR: AtomicU32 = AtomicU32::new(1);

struct Block {
    min_x: u32,
    min_y: u32,
    min_z: u32,
    max_x: u32,
    max_y: u32,
    max_z: u32,
    id: u32,
}

impl Block {
    fn new(input: &str) -> Block {
        let (from, to) = input.split_once('~').unwrap();
        let (min_x, min_y, min_z) = from
            .split(',')
            .map(|v| v.parse::<u32>().unwrap())
            .collect_tuple()
            .unwrap();
        let (max_x, max_y, max_z) = to
            .split(',')
            .map(|v| v.parse::<u32>().unwrap())
            .collect_tuple()
            .unwrap();
        Block {
            min_x,
            min_y,
            min_z,
            max_x,
            max_y,
            max_z,
            id: ID_GENERATOR.fetch_add(1, Ordering::Relaxed),
        }
    }

    fn height(&self) -> u32 {
        1 + (self.max_z - self.min_z)
    }
}

struct LocalHeight {
    value: u32,
    block_id: u32,
}

#[derive(Default)]
struct HeightMap {
    local_maximi: HashMap<(u32, u32), LocalHeight>,
}

impl HeightMap {
    fn insert_block(&mut self, block: &Block) -> HashSet<u32> {
        let (base, res) = self.find_local_height(block);
        self.set_local_height(block, base);
        res
    }

    fn find_local_height(&self, block: &Block) -> (u32, HashSet<u32>) {
        let mut max = 0u32;
        let mut blocks = HashSet::new();
        for y in block.min_y..=block.max_y {
            for x in block.min_x..=block.max_x {
                if let Some(found) = self.local_maximi.get(&(x, y)) {
                    match found.value.cmp(&max) {
                        cmp::Ordering::Equal => {
                            blocks.insert(found.block_id);
                        }
                        cmp::Ordering::Greater => {
                            max = found.value;
                            blocks = HashSet::from([found.block_id]);
                        }
                        _ => {}
                    }
                }
            }
        }

        (max, blocks)
    }

    fn set_local_height(&mut self, block: &Block, base: u32) {
        let value = base + block.height();
        let block_id = block.id;
        for y in block.min_y..=block.max_y {
            for x in block.min_x..=block.max_x {
                self.local_maximi
                    .insert((x, y), LocalHeight { value, block_id });
            }
        }
    }
}

fn destroyable_block_count(blocks: Vec<Block>) -> u32 {
    let total_blocks = blocks.len();
    let mut map = HeightMap::default();
    let mut undestroyables = HashSet::new();
    for b in blocks {
        let pillars = map.insert_block(&b);
        if pillars.len() == 1 {
            undestroyables = undestroyables.union(&pillars).copied().collect();
        }
    }
    (total_blocks - undestroyables.len()) as u32
}

fn dependent_blocks(
    successors: &HashMap<u32, HashSet<u32>>,
    predecessors: &HashMap<u32, HashSet<u32>>,
    memo: &mut HashMap<u32, u32>,
    block_id: u32,
) -> u32 {
    if let Some(&res) = memo.get(&block_id) {
        return res;
    }

    let mut fallen_blocks = HashSet::new();
    let mut queue = VecDeque::from([block_id]);
    while let Some(nxt) = queue.pop_front() {
        fallen_blocks.insert(nxt);
        if let Some(succ) = successors.get(&nxt) {
            for s in succ {
                let pred = predecessors.get(s).unwrap();
                if fallen_blocks.is_superset(pred) {
                    queue.push_back(*s);
                    fallen_blocks.insert(*s);
                }
            }
        }
    }
    let res = fallen_blocks.len() as u32 - 1;
    memo.insert(block_id, res);
    res
}

fn disintegration_block_count(blocks: Vec<Block>) -> u32 {
    let mut map = HeightMap::default();
    let mut successors = blocks
        .iter()
        .map(|b| (b.id, HashSet::new()))
        .collect::<HashMap<u32, HashSet<u32>>>();
    let mut predecessors = HashMap::new();

    for b in blocks.iter() {
        let pilars = map.insert_block(b);
        for p in pilars.iter() {
            successors.get_mut(p).unwrap().insert(b.id);
        }
        predecessors.insert(b.id, pilars);
    }

    let mut memo = HashMap::new();
    blocks
        .iter()
        .map(|b| dependent_blocks(&successors, &predecessors, &mut memo, b.id))
        .sum()
}

pub fn part_one(input: &str) -> Option<u32> {
    let blocks = lines(input)
        .map(Block::new)
        .sorted_by(|b, c| b.min_z.cmp(&c.min_z))
        .collect();
    Some(destroyable_block_count(blocks))
}

pub fn part_two(input: &str) -> Option<u32> {
    ID_GENERATOR.store(1, Ordering::Relaxed);
    let blocks = lines(input)
        .map(Block::new)
        .sorted_by(|b, c| b.min_z.cmp(&c.min_z))
        .collect();
    Some(disintegration_block_count(blocks))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(395));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(64714));
    }
}
