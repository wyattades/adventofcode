use std::error::Error;

fn parse_input(raw_input: &str) -> Vec<String> {
    raw_input.lines().map(String::from).collect()
}

pub fn level_1(raw_input: &str) -> Result<u32, Box<dyn Error>> {
    let _lines = parse_input(raw_input);

    let answer = 0;

    println!("answer: {}", answer);

    Err("Failed to calculate answer!".into())
}

pub fn level_2(raw_input: &str) -> Result<u32, Box<dyn Error>> {
    let _lines = parse_input(raw_input);

    let answer = 0;

    println!("answer: {}", answer);

    Err("Failed to calculate answer!".into())
}
