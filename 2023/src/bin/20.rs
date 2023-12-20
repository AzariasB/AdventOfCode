use itertools::Itertools;
use num::integer::lcm;
use std::collections::{HashMap, HashSet, VecDeque};

use advent_of_code::parsers::lines;

advent_of_code::solution!(20);

#[derive(Clone, Copy)]
enum Pulse {
    High,
    Low,
}

impl Pulse {
    fn is_high(&self) -> bool {
        match self {
            Pulse::High => true,
            Pulse::Low => false,
        }
    }
}

#[derive(Clone, Copy)]
enum FlipFlopState {
    On,
    Off,
}

#[derive(Clone)]
enum ModuleKind {
    Broadcast,
    FlipFlop(FlipFlopState),
    Conjunction(HashMap<String, Pulse>),
}

#[derive(Clone)]
struct Module {
    name: String,
    kind: ModuleKind,
}

impl Module {
    fn new(input: &str) -> Module {
        if input == "broadcaster" {
            Module {
                name: input.to_string(),
                kind: ModuleKind::Broadcast,
            }
        } else if let Some(stripped) = input.strip_prefix('%') {
            Module {
                name: stripped.to_string(),
                kind: ModuleKind::FlipFlop(FlipFlopState::Off),
            }
        } else if let Some(stripped) = input.strip_prefix('&') {
            Module {
                name: stripped.to_string(),
                kind: ModuleKind::Conjunction(HashMap::new()),
            }
        } else {
            unreachable!("Unknown module type {}", input);
        }
    }

    fn handle_pulse(&mut self, origin: &String, pulse: Pulse) -> Option<Pulse> {
        match self.kind {
            ModuleKind::Broadcast => Some(pulse),
            ModuleKind::FlipFlop(current_state) => match (current_state, pulse) {
                (_, Pulse::High) => None,
                (FlipFlopState::Off, Pulse::Low) => {
                    self.kind = ModuleKind::FlipFlop(FlipFlopState::On);
                    Some(Pulse::High)
                }
                (FlipFlopState::On, Pulse::Low) => {
                    self.kind = ModuleKind::FlipFlop(FlipFlopState::Off);
                    Some(Pulse::Low)
                }
            },
            ModuleKind::Conjunction(ref mut memory) => {
                memory.insert(origin.to_string(), pulse);
                Some(if memory.values().all(|v| v.is_high()) {
                    Pulse::Low
                } else {
                    Pulse::High
                })
            }
        }
    }

    fn is_conjunction(&self) -> bool {
        match self.kind {
            ModuleKind::Broadcast => false,
            ModuleKind::FlipFlop(_) => false,
            ModuleKind::Conjunction(_) => true,
        }
    }

    fn is_enabled_conjunction(&self) -> bool {
        match &self.kind {
            ModuleKind::Broadcast => false,
            ModuleKind::FlipFlop(_) => false,
            ModuleKind::Conjunction(mem) => mem.values().all(|v| v.is_high()),
        }
    }

    fn add_input(&mut self, input: String) -> bool {
        match self.kind {
            ModuleKind::Broadcast => false,
            ModuleKind::FlipFlop(_) => false,
            ModuleKind::Conjunction(ref mut memory) => {
                memory.insert(input, Pulse::Low);
                true
            }
        }
    }
}

#[derive(Clone)]
struct Connection {
    module: Module,
    connected_to: Vec<String>,
}

impl Connection {
    fn new(input: &str) -> Connection {
        let (module, dests) = input.split_once(" -> ").unwrap();
        Connection {
            module: Module::new(module),
            connected_to: dests.split(", ").map(|v| v.to_string()).collect(),
        }
    }

    fn handle_pulse(&mut self, origin: &String, pulse: Pulse) -> Option<Pulse> {
        self.module.handle_pulse(origin, pulse)
    }
}

struct Action {
    pulse: Pulse,
    destination: String,
    origin: String,
}

fn simulate_push(mut system: HashMap<String, Connection>, rounds: u32) -> u64 {
    let mut low_pulses = 0;
    let mut high_pulses = 0;
    for _ in 0..rounds {
        let mut actions = VecDeque::from([Action {
            pulse: Pulse::Low,
            destination: "broadcaster".to_string(),
            origin: "elf".to_string(),
        }]);
        while let Some(act) = actions.pop_front() {
            if act.pulse.is_high() {
                high_pulses += 1;
            } else {
                low_pulses += 1;
            }

            if let Some(target) = system.get_mut(&act.destination) {
                if let Some(nxt) = target.handle_pulse(&act.origin, act.pulse) {
                    let mut nxt: VecDeque<Action> = target
                        .connected_to
                        .iter()
                        .map(|t| Action {
                            destination: t.to_string(),
                            pulse: nxt,
                            origin: target.module.name.to_string(),
                        })
                        .collect();
                    actions.append(&mut nxt);
                }
            }
        }
    }
    low_pulses * high_pulses
}

fn update_conjunctions(system: &mut HashMap<String, Connection>) {
    let conjunctions = system
        .values()
        .filter(|c| c.module.is_conjunction())
        .map(|c| c.module.name.to_string())
        .collect::<HashSet<String>>();
    let vals = system
        .values()
        .map(|c| (c.module.name.to_string(), c.connected_to.clone()))
        .collect_vec();
    for (module_name, connected_to) in vals {
        connected_to
            .iter()
            .filter(|&c| conjunctions.contains(c))
            .for_each(|c| {
                system
                    .get_mut(c)
                    .unwrap()
                    .module
                    .add_input(module_name.to_string());
            });
    }
}

fn cycles_count(mut system: HashMap<String, Connection>, observe: &str) -> u64 {
    let mut loops = 0;
    loop {
        let mut actions = VecDeque::from([Action {
            pulse: Pulse::Low,
            destination: "broadcaster".to_string(),
            origin: "elf".to_string(),
        }]);
        loops += 1;
        while let Some(act) = actions.pop_front() {
            if let Some(target) = system.get_mut(&act.destination) {
                if let Some(nxt) = target.handle_pulse(&act.origin, act.pulse) {
                    let mut nxt: VecDeque<Action> = target
                        .connected_to
                        .iter()
                        .map(|t| Action {
                            destination: t.to_string(),
                            pulse: nxt,
                            origin: target.module.name.to_string(),
                        })
                        .collect();
                    actions.append(&mut nxt);
                }
                let obj = &system.get(observe).unwrap().module;
                if obj.is_enabled_conjunction() {
                    return loops;
                }
            }
        }
    }
}

fn to_system(input: &str) -> HashMap<String, Connection> {
    let mut res = lines(input)
        .map(Connection::new)
        .map(|c| (c.module.name.to_string(), c))
        .collect::<HashMap<String, Connection>>();
    update_conjunctions(&mut res);
    res
}

pub fn part_one(input: &str) -> Option<u64> {
    let connections = to_system(input);
    Some(simulate_push(connections, 1000))
}

pub fn part_two(input: &str) -> Option<u64> {
    let connections = to_system(input);
    let tb = cycles_count(connections.clone(), "tb");
    let fl = cycles_count(connections.clone(), "fl");
    let kc = cycles_count(connections.clone(), "kc");
    let hd = cycles_count(connections, "hd");
    // Could probably all multiply them as they are all prime numbers
    Some(lcm(tb, lcm(fl, lcm(kc, hd))))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(731517480));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(244178746156661));
    }
}
