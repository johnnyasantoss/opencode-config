const deepMerge = (target, source) => {
  const result = { ...target };
  for (const key of Object.keys(source)) {
    if (
      source[key] instanceof Object &&
      !Array.isArray(source[key]) &&
      key in target &&
      target[key] instanceof Object &&
      !Array.isArray(target[key])
    ) {
      result[key] = deepMerge(target[key], source[key]);
    } else {
      result[key] = source[key];
    }
  }
  return result;
};

// Robust JSONC parser: handles // comments, /* */ block comments, trailing commas
const stripJsonc = (text) => {
  let result = '';
  let inString = false;
  let escaped = false;

  for (let i = 0; i < text.length; i++) {
    const c = text[i];

    if (escaped) { result += c; escaped = false; continue; }
    if (c === '\\' && inString) { result += c; escaped = true; continue; }
    if (c === '"') { inString = !inString; result += c; continue; }

    if (!inString) {
      // Line comment
      if (c === '/' && text[i + 1] === '/') {
        const nl = text.indexOf('\n', i);
        i = nl === -1 ? text.length - 1 : nl - 1;
        continue;
      }
      // Block comment
      if (c === '/' && text[i + 1] === '*') {
        const end = text.indexOf('*/', i + 2);
        i = end === -1 ? text.length - 1 : end + 1;
        continue;
      }
    }

    result += c;
  }

  // Remove trailing commas
  return result.replace(/,(\s*[}\]])/g, '$1');
};

const readJsonc = (path) => JSON.parse(stripJsonc(require('fs').readFileSync(path, 'utf8')));

const main = readJsonc(process.argv[2]);
const patch = JSON.parse(require('fs').readFileSync(process.argv[3], 'utf8'));
const merged = deepMerge(main, patch);
console.log(JSON.stringify(merged, null, 2));
