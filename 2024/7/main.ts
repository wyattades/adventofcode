function parseInt(str: string) {
  const num = Number.parseInt(str, 10);
  if (Number.isNaN(num)) {
    throw new Error(`Invalid number: ${str}`);
  }
  return num;
}

export function level_1(raw_input: string): number {
  let answer = 0;

  const opsTypes: ((a: number, b: number) => number)[] = [
    (a, b) => a * b,
    (a, b) => a + b,
  ];
  const opTypeCount = opsTypes.length;

  for (const line of raw_input.split("\n")) {
    const [testStr, ...partStrs] = line.split(" ");
    const test = parseInt(testStr.replace(":", ""));
    const parts = partStrs.map(parseInt);

    const partCount = parts.length;
    const opCount = partCount - 1;

    // if opsTypes = [0,1]
    // opCount=1: 0,1
    // opCount=2: 00,01,10,11
    // opCount=3: 000,001,010,011,100,101,110,111

    // if opsTypes = [0,1,2]
    // opCount=1: 0,1,2
    // opCount=2: 00,01,02,10,11,12,20,21,22
    // opCount=3: 000,001,002,010,011,012,020,021,022,100,101,102,110,111,112,120,121,122,200,201,202,210,211,212,220,221,222

    // count the number of combinations of ops of length opCount
    const opCombosCount = Math.pow(opTypeCount, opCount);

    // generate all combinations of ops of length opCount
    for (let comboIdx = 0; comboIdx < opCombosCount; comboIdx++) {
      let testResult = parts[0];
      for (let opIdx = 0; opIdx < opCount; opIdx++) {
        // since it's binary we can use bitwise operations to get the opType
        const opType = (comboIdx >> opIdx) & 1;
        const opFn = opsTypes[opType];
        testResult = opFn(testResult, parts[opIdx + 1]);
      }
      if (testResult === test) {
        answer += test;
        break;
      }
    }
  }

  return answer;
}

function* getCombos(opTypeCount: number, opCount: number) {
  if (opCount === 0) {
    yield [];
  } else if (opCount === 1) {
    for (let i = 0; i < opTypeCount; i++) {
      yield [i];
    }
  } else if (opCount === 2) {
    for (let i = 0; i < opTypeCount; i++) {
      for (let j = 0; j < opTypeCount; j++) {
        yield [i, j];
      }
    }
  } else if (opCount === 3) {
    for (let i = 0; i < opTypeCount; i++) {
      for (let j = 0; j < opTypeCount; j++) {
        for (let k = 0; k < opTypeCount; k++) {
          yield [i, j, k];
        }
      }
    }
  } else {
    // For each possible first number, get all combinations of the remaining numbers
    for (let i = 0; i < opTypeCount; i++) {
      for (const subCombo of getCombos(opTypeCount, opCount - 1)) {
        yield [i, ...subCombo];
      }
    }
  }
}

export function level_2(raw_input: string): number {
  let answer = 0;

  const opsTypes: ((a: number, b: number) => number)[] = [
    (a, b) => a * b,
    (a, b) => a + b,
    (a, b) => parseInt(a.toString() + b.toString()),
  ];
  const opTypeCount = opsTypes.length;

  for (const line of raw_input.split("\n")) {
    if (line === "") continue;
    const [testStr, ...partStrs] = line.split(" ");
    const test = parseInt(testStr.replace(":", ""));
    const parts = partStrs.map(parseInt);

    const partCount = parts.length;
    const opCount = partCount - 1;

    // generate all combinations of ops of length opCount
    for (const combo of getCombos(opTypeCount, opCount)) {
      let testResult = parts[0];
      for (let opIdx = 0; opIdx < opCount; opIdx++) {
        const opType = combo[opIdx];
        const opFn = opsTypes[opType];
        testResult = opFn(testResult, parts[opIdx + 1]);
      }
      if (testResult === test) {
        answer += test;
        break;
      }
    }
  }

  return answer;
}
