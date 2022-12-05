const Elm = require('./main').Elm;
const ElmModule = Elm[Object.keys(Elm)[0]];

const app = ElmModule.init();

const label = process.argv[2];

process.stdin.on(
  'data',
  data => {
    const inputLines = data.toString().split('\n');
    app.ports.startPart1.send(inputLines);
    app.ports.startPart2.send(inputLines);
  }
);

app.ports.output.subscribe(str => console.log(`\n${label} -- ${str}`));
