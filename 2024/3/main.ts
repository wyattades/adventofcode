export function level_1(raw_input: string): number {
  let answer = 0;
  for (const match of raw_input.matchAll(/mul\((\d+),(\d+)\)/g)) {
    const [_, a, b] = match;
    answer += Number(a) * Number(b);
  }
  return answer;
}

export function level_2(raw_input: string): number {
  let answer = 0;
  let enabled = true;
  for (const match of raw_input.matchAll(
    /(mul|do|don't)\((?:(\d+),(\d+))?\)/g,
  )) {
    const [_, op, a, b] = match;
    if (op === "mul") {
      if (enabled) answer += Number(a) * Number(b);
    } else if (op === "do") {
      enabled = true;
    } else if (op === "don't") {
      enabled = false;
    }
  }
  return answer;
}
