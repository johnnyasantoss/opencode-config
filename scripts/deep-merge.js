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

const main = JSON.parse(require('fs').readFileSync(process.argv[2], 'utf8'));
const patch = JSON.parse(require('fs').readFileSync(process.argv[3], 'utf8'));
const merged = deepMerge(main, patch);
console.log(JSON.stringify(merged, null, 2));
