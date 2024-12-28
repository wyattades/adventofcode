import { findLast, findLastIndex } from "lodash-es";

export function level_1(raw_input: string): number {
  const list = raw_input
    .trim()
    .split("")
    .map((r) => Number.parseInt(r));

  const files: (number | null)[] = [];
  for (let i = 0; i < list.length; i++) {
    const num = list[i]!;
    if (num === 0) continue;
    if (i % 2 === 0) {
      const fileId = i / 2;
      for (let j = 0; j < num; j++) files.push(fileId);
    } else {
      for (let j = 0; j < num; j++) files.push(null);
    }
  }

  let moveIndex = files.length - 1;
  let emptyIndex = files.findIndex((f) => f === null);
  while (true) {
    const val = files[moveIndex]!;

    files[emptyIndex] = val;
    files[moveIndex] = null;

    do {
      emptyIndex++;
    } while (files[emptyIndex] !== null);

    do {
      moveIndex--;
    } while (files[moveIndex] === null);

    if (moveIndex <= emptyIndex) break;
  }

  let checksum = 0;
  for (let pos = 0; pos < files.length; pos++) {
    const fileId = files[pos]!;
    if (fileId === null) break;
    checksum += fileId * pos;
  }

  return checksum;
}

// export function level_2(raw_input: string): number {
//   const list = raw_input
//     .trim()
//     .split("")
//     .map((r) => Number.parseInt(r));

//   const files: (number | null)[] = [];
//   for (let i = 0; i < list.length; i++) {
//     const num = list[i];
//     if (num === 0) continue;
//     if (i % 2 === 0) {
//       const fileId = i / 2;
//       for (let j = 0; j < num; j++) files.push(fileId);
//     } else {
//       for (let j = 0; j < num; j++) files.push(null);
//     }
//   }

//   let moveIndex = files.length - 1;
//   let emptyIndex = files.findIndex((f) => f === null);
//   while (true) {
//     const val = files[moveIndex];

//     files[emptyIndex] = val;
//     files[moveIndex] = null;

//     do {
//       emptyIndex++;
//     } while (files[emptyIndex] !== null);

//     do {
//       moveIndex--;
//     } while (files[moveIndex] === null);

//     if (moveIndex <= emptyIndex) break;
//   }

//   let checksum = 0;
//   for (let pos = 0; pos < files.length; pos++) {
//     const fileId = files[pos];
//     if (fileId === null) break;
//     checksum += fileId * pos;
//   }

//   return checksum;
// }

type File = {
  pos: number;
  // index: number;
  len: number;
  id: number | null; // null if empty space
  processed: boolean;
};

export function level_2(raw_input: string): number {
  const list = raw_input
    .trim()
    .split("")
    .map((r) => Number.parseInt(r));

  const files: File[] = [];
  let pos = 0;
  let index = 0;
  for (let i = 0; i < list.length; i++) {
    const num = list[i]!;
    if (num === 0) continue;
    if (i % 2 === 0) {
      const fileId = i / 2;
      files.push({
        pos,
        // index,
        len: num,
        id: fileId,
        processed: false,
      });
    } else {
      files.push({
        pos,
        // index,
        len: num,
        id: null,
        processed: false,
      });
    }
    pos += num;
    index++;
  }

  // let moveIndex = files.length - 1;
  // let emptyPos = files.find((f) => f.id === null)!.pos;
  while (true) {
    const moveIndex = findLastIndex(
      files,
      (f) => f.id !== null && !f.processed,
    );
    if (moveIndex === -1) break;
    const moveFile = files[moveIndex]!;

    moveFile.processed = true;

    // find the first empty space in the beginning that can fit the file
    const emptyIndex = files.findIndex(
      (f, i) => i < moveIndex && f.id === null && f.len >= moveFile!.len,
    );
    if (emptyIndex === -1) continue; // skip moving if no empty space found
    const emptySlot = files[emptyIndex]!;

    // move the file to the empty space:

    // - remove the file
    files.splice(moveIndex, 1);
    // - remove the empty space
    // - insert the file
    // - insert any remaining empty space
    const remainingEmptyLen = emptySlot.len - moveFile.len;
    files.splice(
      emptyIndex,
      1,
      moveFile,
      ...(remainingEmptyLen > 0
        ? [
            {
              pos: emptySlot.pos + moveFile.len,
              len: remainingEmptyLen,
              id: null,
              processed: false,
            },
          ]
        : []),
    );
    // if (remainingEmptyLen > 0) {
    //   moveIndex++;
    // }
    moveFile.pos = emptySlot.pos;

    // mergeEmptySlots(files);

    // printOut(files);
  }

  let checksum = 0;
  for (let i = 0; i < files.length; i++) {
    const file = files[i]!;
    if (file.id === null) continue;
    for (let len = 0; len < file.len; len++) {
      checksum += (file.pos + len) * file.id;
    }
  }

  return checksum;
}

function mergeEmptySlots(files: File[]) {
  for (let i = 0; ; i++) {
    const file = files[i]!;
    const nextFile = files[i + 1];
    if (!nextFile) break;
    if (file.id === null && nextFile.id === null) {
      file.len += nextFile.len;
      files.splice(i + 1, 1);
    }
  }
}

function printOut(files: File[]) {
  let i = 0;
  for (const file of files) {
    process.stdout.write(`${file.id ?? "X"}x${file.len},`);
    i++;
    // if (i % 10 === 0) process.stdout.write("\n");
    if (i > 20) break;
  }
  process.stdout.write("\n");
}
