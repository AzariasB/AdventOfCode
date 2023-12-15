use itertools::Itertools;
advent_of_code::solution!(15);

fn hash(input: &str) -> u64 {
    input
        .chars()
        .fold(0u64, |acc, v| (acc + (v as u64)) * 17 % 256)
}

#[derive(Clone, Debug)]
struct Lens {
    label: String,
    value: u64,
}

type Box = Vec<Lens>;

type Room = Vec<Box>;

fn act(room: &mut Room, action: &str) {
    if action.ends_with('-') {
        let label = &action[0..(action.len() - 1)];
        let hsh = hash(label);
        let bx = &mut room[hsh as usize];
        if let Some((p, _)) = bx.iter().find_position(|bx| bx.label == label) {
            bx.remove(p);
        }
    } else {
        let (label, raw_num) = action.split_once('=').unwrap();
        let hsh = hash(label);
        let value = raw_num.parse().unwrap();
        let bx = &mut room[hsh as usize];
        if let Some(v) = bx.iter_mut().find(|bx| bx.label == label) {
            v.value = value;
        } else {
            bx.push(Lens {
                value,
                label: label.to_string(),
            })
        }
    }
}

fn room_value(room: &Room) -> u64 {
    room.iter()
        .enumerate()
        .map(|(box_idx, bx)| {
            bx.iter()
                .enumerate()
                .map(|(v, l)| (1 + box_idx as u64) * (1 + v as u64) * l.value)
                .sum::<u64>()
        })
        .sum()
}

pub fn part_one(input: &str) -> Option<u64> {
    Some(input.trim().split(',').map(hash).sum())
}

pub fn part_two(input: &str) -> Option<u64> {
    let mut room = vec![vec![]; 256];
    input.trim().split(',').for_each(|v| act(&mut room, v));
    Some(room_value(&room))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(508498));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(279116));
    }
}
