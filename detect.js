const fs = require('fs');
const path = require('path');

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(function (file) {
        file = dir + '/' + file;
        const stat = fs.statSync(file);
        if (stat && stat.isDirectory()) {
            results = results.concat(walk(file));
        } else {
            if (file.endsWith('.tsx')) {
                results.push(file);
            }
        }
    });
    return results;
}

const files = walk('./src').concat(['./App.tsx']);

files.forEach(file => {
    const content = fs.readFileSync(file, 'utf8');
    const lines = content.split('\n');
    lines.forEach((line, index) => {
        // Very basic heuristic: line has text outside of tags
        // This is tricky without a true AST parser, but let's try to look for typical mistakes.
        // For example, `{condition && "string"}` or `> text <` where neither is <Text>

        if (line.match(/>[\w\s]+</) && !line.includes('<Text') && !line.includes('</Text')) {
            // Ignore if it's a comment
            if (!line.includes('//') && !line.includes('/*')) {
                console.log(`Potential issue in ${file}:${index + 1}: ${line.trim()}`);
            }
        }

        // Also check for `{boolean && "string"}` inside View
        if (line.match(/&&\s*['"]/)) {
            console.log(`Potential string literal condition in ${file}:${index + 1}: ${line.trim()}`);
        }
    });
});
