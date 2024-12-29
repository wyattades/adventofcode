export function level_1(raw_input: string): number {
  const grid = raw_input.split("\n").map((line) => line.split(""));
  const width = grid[0]!.length;
  const height = grid.length;

  const findWord = "XMAS";
  const wordLength = findWord.length;

  const dirs = [
    [0, 1],
    [1, 0],
    [0, -1],
    [-1, 0],
    [1, 1],
    [1, -1],
    [-1, 1],
    [-1, -1],
  ] as const;

  let answer = 0;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const letter = grid[y]![x]!;
      if (letter === findWord[0]) {
        for (const [dx, dy] of dirs) {
          let found = true;
          for (let i = 1; i < wordLength; i++) {
            const ny = y + dy * i;
            const nx = x + dx * i;
            if (grid[ny]?.[nx] !== findWord[i]) {
              found = false;
              break;
            }
          }
          if (found) answer++;
        }
      }
    }
  }

  return answer;
}

export function level_2(raw_input: string): number {
  const grid = raw_input.split("\n").map((line) => line.split(""));
  const width = grid[0]!.length;
  const height = grid.length;

  const findX = "MAS";
  const middleLetter = findX[1];

  let answer = 0;
  for (let y = 1; y < height - 1; y++) {
    for (let x = 1; x < width - 1; x++) {
      const letter = grid[y]![x]!;
      if (letter === middleLetter) {
        const tl = grid[y - 1]![x - 1]!;
        const tr = grid[y - 1]![x + 1]!;
        const bl = grid[y + 1]![x - 1]!;
        const br = grid[y + 1]![x + 1]!;

        // validate the 4 corners
        if (
          ((tl === findX[0] && br === findX[2]) ||
            (tl === findX[2] && br === findX[0])) &&
          ((bl === findX[0] && tr === findX[2]) ||
            (bl === findX[2] && tr === findX[0]))
        )
          answer++;
      }
    }
  }

  return answer;
}
