export function as_lines(raw_input: string): string[] {
  return raw_input.split("\n");
}

export function as_numbers_lists(raw_input: string): number[][] {
  return raw_input.split("\n").map((line) => line.split(" ").map(Number));
}
