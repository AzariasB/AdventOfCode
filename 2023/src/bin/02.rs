use advent_of_code::parsers::lines;
use std::cmp::max;
advent_of_code::solution!(2);

const MAX_REDS: u32 = 12;
const MAX_GREENS: u32 = 13;
const MAX_BLUES: u32 = 14;

#[derive(Default, Debug)]
struct GameSet {
    reds: u32,
    greens: u32,
    blue: u32,
}

impl GameSet {
    pub fn is_valid(&self) -> bool {
        self.reds <= MAX_REDS && self.greens <= MAX_GREENS && self.blue <= MAX_BLUES
    }

    pub fn maximize(&self, other: &GameSet) -> GameSet {
        GameSet {
            blue: max(self.blue, other.blue),
            reds: max(self.reds, other.reds),
            greens: max(self.greens, other.greens),
        }
    }
}

#[derive(Debug)]
struct Game {
    id: u32,
    sets: Vec<GameSet>,
}

impl Game {
    pub fn is_valid(&self) -> bool {
        self.sets.iter().all(GameSet::is_valid)
    }

    pub fn power(&self) -> u32 {
        let max_set = self
            .sets
            .iter()
            .fold(GameSet::default(), |prev, curr| prev.maximize(curr));
        max_set.reds * max_set.greens * max_set.blue
    }
}

fn parse_game_set(input: &str) -> Vec<GameSet> {
    input
        .split(';')
        .map(|s| {
            let mut set = GameSet::default();
            s.split(", ").for_each(|slice| {
                let (num, color) = slice
                    .trim()
                    .split_once(' ')
                    .unwrap_or_else(|| panic!("Failed to parse game set {}", slice));
                let count = num.parse::<u32>().expect("Unable to parse cube count");
                match color {
                    "red" => set.reds += count,
                    "blue" => set.blue += count,
                    "green" => set.greens += count,
                    _ => panic!("Unknown color {}", color),
                }
            });
            set
        })
        .collect()
}

fn parse_game(input: &str) -> Game {
    let mut splited = input.split(": ");
    let game_id = splited.next().expect("Game id not found");
    let game_sets = splited.next().expect("Game data not found");
    Game {
        id: game_id[5..]
            .parse::<u32>()
            .unwrap_or_else(|_| panic!("Invalid game id {}", game_id)),
        sets: parse_game_set(game_sets),
    }
}

pub fn part_one(input: &str) -> Option<u32> {
    Some(
        lines(input)
            .map(parse_game)
            .filter(Game::is_valid)
            .map(|g| g.id)
            .sum(),
    )
}

pub fn part_two(input: &str) -> Option<u32> {
    Some(lines(input).map(parse_game).map(|v| v.power()).sum())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(2512));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(67335));
    }
}
