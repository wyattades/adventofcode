use std::collections::HashMap;

// create a 2d array of characters from the input
fn parse_input(raw_input: &str) -> Vec<Vec<char>> {
    raw_input
        .lines()
        .map(|line| line.chars().collect())
        .collect()
}

fn print_grid(grid: &Vec<Vec<char>>) {
    for line in grid {
        println!("{:?}", line.iter().collect::<String>());
    }
}

pub fn level_1(raw_input: &str) -> i32 {
    let grid = parse_input(raw_input);

    let width = grid[0].len();
    let height = grid.len();

    // count the positions of each unique character i.e. a hashmap with char keys and (x,y)[] values (array of positions)
    let mut positions = HashMap::new();
    for (y, row) in grid.iter().enumerate() {
        for (x, &ch) in row.iter().enumerate() {
            if ch == '.' {
                continue;
            }
            positions.entry(ch).or_insert(vec![]).push((x, y));
        }
    }

    // println!("{:?}", positions);
    // print_grid(&grid);

    // create a new 2d array of booleans
    let mut results = vec![vec![false; width]; height];

    let width = width as i32;
    let height = height as i32;

    // iterate over the positions hashmap
    for (_ch, positions) in positions {
        for (i, (x1, y1)) in positions.iter().enumerate() {
            for (j, (x2, y2)) in positions.iter().enumerate() {
                if i == j {
                    continue;
                }

                // compute the distance between the two positions
                // NOTE: these are all `usize` but it seems to work
                let dx = (*x2 as i32) - (*x1 as i32);
                let dy = (*y2 as i32) - (*y1 as i32);

                let ax = *x1 as i32 - dx;
                let ay = *y1 as i32 - dy;
                let bx = *x2 as i32 + dx;
                let by = *y2 as i32 + dy;

                if ax >= 0 && ax < width && ay >= 0 && ay < height {
                    results[ay as usize][ax as usize] = true;
                }

                if bx >= 0 && bx < width && by >= 0 && by < height {
                    results[by as usize][bx as usize] = true;
                }
            }
        }
    }

    // count the number of true values in the results array
    let mut answer: i32 = 0;
    for row in results {
        for v in row {
            if v {
                answer += 1;
            }
        }
    }
    answer
}

pub fn level_2(raw_input: &str) -> i32 {
    let grid = parse_input(raw_input);

    let width = grid[0].len();
    let height = grid.len();

    // count the positions of each unique character i.e. a hashmap with char keys and (x,y)[] values (array of positions)
    let mut positions = HashMap::new();
    for (y, row) in grid.iter().enumerate() {
        for (x, &ch) in row.iter().enumerate() {
            if ch == '.' {
                continue;
            }
            positions.entry(ch).or_insert(vec![]).push((x, y));
        }
    }

    // println!("{:?}", positions);
    // print_grid(&grid);

    // create a new 2d array of booleans
    let mut results = vec![vec![false; width]; height];

    let width = width as i32;
    let height = height as i32;

    // iterate over the positions hashmap
    for (_ch, positions) in positions {
        for (i, (x1, y1)) in positions.iter().enumerate() {
            for (j, (x2, y2)) in positions.iter().enumerate() {
                if i == j {
                    continue;
                }

                // compute the distance between the two positions
                // NOTE: these are all `usize` but it seems to work
                let dx = (*x2 as i32) - (*x1 as i32);
                let dy = (*y2 as i32) - (*y1 as i32);

                let mut ax = *x1 as i32;
                let mut ay = *y1 as i32;
                let mut bx = *x2 as i32;
                let mut by = *y2 as i32;

                while ax >= 0 && ax < width && ay >= 0 && ay < height {
                    results[ay as usize][ax as usize] = true;
                    ax -= dx;
                    ay -= dy;
                }

                while bx >= 0 && bx < width && by >= 0 && by < height {
                    results[by as usize][bx as usize] = true;
                    bx += dx;
                    by += dy;
                }
            }
        }
    }

    // count the number of true values in the results array
    let mut answer: i32 = 0;
    for row in results {
        for v in row {
            if v {
                answer += 1;
            }
        }
    }
    answer
}
