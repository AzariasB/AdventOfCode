use std::cmp::Ordering;
use std::cmp::Ordering::{Equal, Greater, Less};
use std::collections::HashMap;

use itertools::Itertools;

advent_of_code::solution!(19);

struct MachinePart {
    x: u32,
    m: u32,
    a: u32,
    s: u32,
}

#[derive(Default, Copy, Clone)]
struct RangedPart {
    x: (u64, u64),
    m: (u64, u64),
    a: (u64, u64),
    s: (u64, u64),
}

const MAX_VALUE: u64 = 4000;

type Range = (u64, u64);

fn diff(&(from, to): &Range) -> u64 {
    1 + (to - from)
}

impl RangedPart {
    fn new() -> RangedPart {
        RangedPart {
            x: (1, MAX_VALUE),
            m: (1, MAX_VALUE),
            a: (1, MAX_VALUE),
            s: (1, MAX_VALUE),
        }
    }

    fn raw_value(&self) -> u64 {
        diff(&self.x) * diff(&self.m) * diff(&self.a) * diff(&self.s)
    }

    fn updated_field(&self, field: char, nw_value: Range) -> RangedPart {
        let mut res = *self;
        match field {
            'x' => res.x = nw_value,
            'm' => res.m = nw_value,
            'a' => res.a = nw_value,
            's' => res.s = nw_value,
            _ => unreachable!("Unknown field name {}", field),
        }
        res
    }
}

impl MachinePart {
    fn new(input: &str) -> MachinePart {
        let (x, m, a, s) = input[1..input.len() - 1]
            .split(',')
            .map(|v| v.split_once('=').unwrap().1.parse::<u32>().unwrap())
            .collect_tuple()
            .unwrap();
        MachinePart { x, m, a, s }
    }

    fn raw_value(&self) -> u32 {
        self.x + self.m + self.a + self.s
    }
}

struct Rating {
    field: char,
    must_be: Ordering,
    than: u32,
    then_go: String,
}

struct TransferredRange {
    transferred: RangedPart,
    to: String,
    rejected: RangedPart,
}

enum SplitRange {
    Accepted(RangedPart),
    Refused(RangedPart),
    Transferred(TransferredRange),
}

impl Rating {
    fn new(input: &str) -> Rating {
        if let Some((check, dest)) = input.split_once(':') {
            if let Some((v, gt)) = check.split_once('>') {
                let gt = gt.parse::<u32>().unwrap();
                let field = v.chars().next().unwrap();
                Rating {
                    field,
                    must_be: Greater,
                    than: gt,
                    then_go: dest.to_string(),
                }
            } else {
                let (v, lt) = check.split_once('<').unwrap();
                let lt = lt.parse::<u32>().unwrap();
                let field = v.chars().next().unwrap();
                Rating {
                    field,
                    must_be: Less,
                    than: lt,
                    then_go: dest.to_string(),
                }
            }
        } else {
            Rating {
                field: '\0',
                must_be: Equal,
                than: 0,
                then_go: input.to_string(),
            }
        }
    }

    fn field_value(&self, part: &MachinePart) -> u32 {
        match self.field {
            'x' => part.x,
            'm' => part.m,
            's' => part.s,
            'a' => part.a,
            _ => unreachable!("Unknown field"),
        }
    }

    fn range_value(&self, ranged_part: &RangedPart) -> Range {
        match self.field {
            'x' => ranged_part.x,
            'm' => ranged_part.m,
            's' => ranged_part.s,
            'a' => ranged_part.a,
            _ => unreachable!("Unknown field"),
        }
    }

    fn split_range(&self, range: RangedPart) -> SplitRange {
        match self.must_be {
            Less => {
                let (min, max) = self.range_value(&range);
                if max < self.than.into() {
                    SplitRange::Transferred(TransferredRange {
                        transferred: range,
                        rejected: RangedPart::default(),
                        to: self.then_go.to_string(),
                    })
                } else {
                    let transferred =
                        range.updated_field(self.field, (min, self.than.saturating_sub(1).into()));
                    let rejected = range.updated_field(self.field, (self.than.into(), max));
                    SplitRange::Transferred(TransferredRange {
                        transferred,
                        rejected,
                        to: self.then_go.to_string(),
                    })
                }
            }
            Equal => match self.then_go.as_str() {
                "A" => SplitRange::Accepted(range),
                "R" => SplitRange::Refused(range),
                val => SplitRange::Transferred(TransferredRange {
                    transferred: range,
                    rejected: RangedPart::default(),
                    to: val.to_string(),
                }),
            },
            Greater => {
                let (min, max) = self.range_value(&range);
                if min > self.than.into() {
                    SplitRange::Transferred(TransferredRange {
                        transferred: range,
                        rejected: RangedPart::default(),
                        to: self.then_go.to_string(),
                    })
                } else {
                    let rejected = range.updated_field(self.field, (min, self.than.into()));
                    let transferred =
                        range.updated_field(self.field, ((self.than + 1).into(), max));
                    SplitRange::Transferred(TransferredRange {
                        transferred,
                        rejected,
                        to: self.then_go.to_string(),
                    })
                }
            }
        }
    }

    fn matches(&self, part: &MachinePart) -> Option<String> {
        match self.must_be {
            Equal => Some(self.then_go.to_string()),
            Less => {
                let val = self.field_value(part);
                if val < self.than {
                    Some(self.then_go.to_string())
                } else {
                    None
                }
            }
            Greater => {
                let val = self.field_value(part);
                if val > self.than {
                    Some(self.then_go.to_string())
                } else {
                    None
                }
            }
        }
    }
}

type Workflow = Vec<Rating>;

fn parse_workflow(input: &str) -> (String, Workflow) {
    let (name, value) = input.split_once('{').unwrap();
    (
        name.to_string(),
        value.replace('}', "").split(',').map(Rating::new).collect(),
    )
}

fn is_accepted(
    workflows: &HashMap<String, Workflow>,
    part: &MachinePart,
    workflow_name: &String,
) -> bool {
    if let Some(work) = workflows.get(workflow_name) {
        let next = work.iter().find_map(|r| r.matches(part)).unwrap();
        match next.as_str() {
            "R" => false,
            "A" => true,
            _ => is_accepted(workflows, part, &next),
        }
    } else {
        unreachable!("Workflow with unknown name found");
    }
}

fn range_value(
    workflows: &HashMap<String, Workflow>,
    mut part: RangedPart,
    workflow_name: &String,
) -> u64 {
    if let Some(workflow) = workflows.get(workflow_name) {
        let mut total = 0;
        for rating in workflow {
            let res = rating.split_range(part);
            match res {
                SplitRange::Accepted(range) => return total + range.raw_value(),
                SplitRange::Refused(_) => return total,
                SplitRange::Transferred(data) => {
                    total += match data.to.as_str() {
                        "A" => data.transferred.raw_value(),
                        "R" => 0,
                        _ => range_value(workflows, data.transferred, &data.to),
                    };
                    part = data.rejected
                }
            }
        }
        total
    } else {
        unreachable!("Workflow with name {} not found", workflow_name);
    }
}

pub fn part_one(input: &str) -> Option<u32> {
    let workflows = input
        .lines()
        .take_while(|v| !v.is_empty())
        .map(parse_workflow)
        .collect::<HashMap<String, Workflow>>();
    Some(
        input
            .lines()
            .skip_while(|v| !v.is_empty())
            .skip(1)
            .map(MachinePart::new)
            .filter(|part| is_accepted(&workflows, part, &"in".to_string()))
            .map(|part| part.raw_value())
            .sum(),
    )
}

pub fn part_two(input: &str) -> Option<u64> {
    let workflows = input
        .lines()
        .take_while(|v| !v.is_empty())
        .map(parse_workflow)
        .collect::<HashMap<String, Workflow>>();
    Some(range_value(
        &workflows,
        RangedPart::new(),
        &"in".to_string(),
    ))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let result = part_one(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(362930));
    }

    #[test]
    fn test_part_two() {
        let result = part_two(&advent_of_code::template::read_file("inputs", DAY));
        assert_eq!(result, Some(116365820987729));
    }
}
