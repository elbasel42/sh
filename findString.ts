import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "child_process";
import inquirer from "inquirer";
import { $ } from "bun";

// Read the query string from the terminal
const query = process.argv[2];

const getAllFiles = (
  dirPath: string,
  arrayOfFiles: string[] = []
): string[] => {
  const files = fs.readdirSync(dirPath);

  files.forEach((file) => {
    const fullPath = path.join(dirPath, file);
    if (fs.statSync(fullPath).isDirectory()) {
      return (arrayOfFiles = getAllFiles(fullPath, arrayOfFiles));
    }
    arrayOfFiles.push(fullPath);
  });
  return arrayOfFiles;
};

const cwd = process.cwd();
const allFiles = getAllFiles(cwd);

type MatchedFile = {
  path: string;
  lineNum: number;
  charNum: number;
};

const matchedFiles: MatchedFile[] = [];

// Loop over files and search for the string, extracting file path, line number, and character number
allFiles.forEach((file) => {
  const data = fs.readFileSync(file, "utf-8");
  const lines = data.split("\n");
  lines.forEach((line, lineNum) => {
    const charNum = line.indexOf(query);
    if (charNum > -1) {
      matchedFiles.push({
        path: file,
        lineNum: lineNum + 1, // make sure lineNum is 1-indexed
        charNum: charNum + 1, // make sure charNum is 1-indexed
      });
    }
  });
});

// Create file links with the highlight range (line and character)
const fileLinks = matchedFiles.map((file) => {
  return `${file.path}:${file.lineNum}`; // Only pass lineNum to highlight
});

// Use fzf to allow selecting a file and preview it with 'bat' highlighting the line and character
// const fzf = spawnSync('fzf', {
//   input: fileLinks.join('\n'),
//   stdio: 'pipe',
//   encoding: 'utf-8',
//   shell: true,
//   env: {
//     ...process.env,
//     FZF_DEFAULT_OPTS: '--preview="bat --color=always --highlight-line {1} --line-range {1}:{1} {0}"', // Highlight specific line
//   },
// });

// console.log(fzf.stdout);

console.log({ fileLinks });

// do the above but use $ from bun to run commands
// for await (const line of $`ls -l`.lines()) {
//     console.log(line);
//   }
// const runFzf = async () => {
//     const fzfCommand = 'fzf';
//     const fzfInput = fileLinks.join('\n');
//     const fzfEnv = {
//         FZF_DEFAULT_OPTS:
//             '--preview="bat --color=always --highlight-line {1} --line-range {1}:{1} {0}"', // Highlight specific line
//     };

//     // const fzf = await $`${fzfCommand}`.env(fzfEnv).stdin(fzfInput).pipeText();
//     // console.log(fzf.stdout);
// };

// runFzf();
