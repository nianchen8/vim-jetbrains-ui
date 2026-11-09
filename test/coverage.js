#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(process.argv[2]);
const profileDir = path.resolve(process.argv[3]);
const targets = [
  'autoload/jb.vim',
  'autoload/jb/ui.vim',
  'colors/jb.vim',
  'plugin/jb_ui.vim',
];

const functionsByFile = new Map();
for (const relative of targets) {
  const source = fs.readFileSync(path.join(repoRoot, relative), 'utf8');
  const functions = [];
  let current = null;
  source.split('\n').forEach((line, index) => {
    const match = line.match(/^\s*function!?\s+([A-Za-z0-9_#:]+)\(/);
    if (match) {
      current = {
        name: match[1].replace(/^s:/, ''),
        bodyLines: [],
      };
      functions.push(current);
    } else if (current && /^\s*endfunction\b/.test(line)) {
      current = null;
    } else if (current) {
      if (!/^\s*(?:"|$|\\)/.test(line)) {
        current.bodyLines.push(index + 1);
      }
    }
  });
  functionsByFile.set(relative, functions);
}

const scriptLines = new Map();
const functionHits = new Map();

for (const entry of fs.readdirSync(profileDir).sort()) {
  if (!entry.endsWith('.log')) continue;
  const lines = fs.readFileSync(path.join(profileDir, entry), 'utf8').split('\n');
  let section = null;

  for (const line of lines) {
    const script = line.match(/^SCRIPT\s+(.+)$/);
    if (script) {
      section = { type: 'script', path: script[1] };
      continue;
    }

    const fn = line.match(/^FUNCTION\s+(.+)$/);
    if (fn) {
      const name = fn[1];
      section = { type: 'function', name };
      continue;
    }

    if (line.startsWith('FUNCTIONS SORTED')) {
      section = null;
      continue;
    }

    if (!section) continue;
    const timed = line.match(/^\s*(\d+)\s+\d+\.\d+.*?\s+(.+)$/);
    if (!timed) continue;

    if (section.type === 'script') {
      const file = path.relative(repoRoot, section.path);
      if (!targets.includes(file)) continue;
      if (!scriptLines.has(file)) scriptLines.set(file, new Map());
      const map = scriptLines.get(file);
      map.set(timed[2], Math.max(map.get(timed[2]) || 0, Number(timed[1])));
    } else {
      if (Number(timed[1]) > 0) {
        if (!functionHits.has(section.name)) functionHits.set(section.name, new Set());
        functionHits.get(section.name).add(timed[2]);
      }
    }
  }
}

let totalCovered = 0;
let totalLines = 0;
let totalFunctions = 0;
let coveredFunctions = 0;

for (const file of targets) {
  const topLevel = scriptLines.get(file) || new Map();
  const topLevelCovered = [...topLevel.values()].filter((count) => count > 0).length;
  let covered = topLevelCovered;
  let total = topLevelCovered;
  let coveredNames = 0;
  const functions = functionsByFile.get(file);

  for (const entry of functions) {
    total += entry.bodyLines.length;
    const matchingCalls = [...functionHits.keys()].filter((called) => {
      return called
        .replace(/\(\)$/, '')
        .replace(/^<SNR>\d+_/, '') === entry.name;
    });
    if (matchingCalls.length > 0) {
      coveredNames += 1;
      const coveredLines = new Set();
      for (const matchingCall of matchingCalls) {
        for (const line of functionHits.get(matchingCall)) {
          coveredLines.add(line);
        }
      }
      covered += coveredLines.size;
    }
  }

  totalCovered += covered;
  totalLines += total;

  totalFunctions += functions.length;
  coveredFunctions += coveredNames;

  const percentage = total === 0 ? 100 : (covered / total) * 100;
  console.log(`${file}: ${covered}/${total} profiled lines (${percentage.toFixed(1)}%), ${coveredNames}/${functions.length} functions`);
}

const linePercentage = totalLines === 0 ? 100 : (totalCovered / totalLines) * 100;
console.log(`TOTAL: ${totalCovered}/${totalLines} profiled lines (${linePercentage.toFixed(1)}%), ${coveredFunctions}/${totalFunctions} functions`);

const lineGate = 95;
if (linePercentage < lineGate || coveredFunctions !== totalFunctions) {
  console.error(`Coverage gate failed: require ${lineGate.toFixed(1)}% lines and 100% functions.`);
  process.exitCode = 1;
} else {
  console.log(`Coverage gate passed: >= ${lineGate.toFixed(1)}% lines and 100% functions.`);
}
