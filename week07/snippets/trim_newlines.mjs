import fs from 'fs/promises';

const filename = '/home/mjumbewu/Code/musa/musa-509/spring-2023/solutions/assignment02/data/septa_rail/stops copy.txt';
const f = await fs.open(filename, 'r+');

// Find the length of the file in bytes
const stats = await f.stat();

// Check whether the last byte is a newline (\n or \r)
let readPos = stats.size - 1;
let lastByte = await f.read(Buffer.alloc(1), 0, 1, readPos);
while ([10, 13].includes(lastByte.buffer[0])) {

  // If it is, trim it off
  console.log(`Trimming ${lastByte.buffer[0]} from end of file`);
  await f.truncate(readPos);

  // Go back one more byte and check again
  readPos--;
  lastByte = await f.read(Buffer.alloc(1), 0, 1, readPos);
}
