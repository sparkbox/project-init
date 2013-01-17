var
  path = require('path'),
  cleanCSS = require('../index'),
  bigcss = require('fs').readFileSync(path.join(__dirname, 'data', 'big.css'), 'utf8'),
  runs = ~~process.argv[2] || 10;

for(var i=0; i<runs; i++) {
  console.time('complete minification');
  cleanCSS.process(bigcss, { debug: true });
  console.timeEnd('complete minification');
}