var Elm = require('./main').Elm;
var ElmModule = Elm[Object.keys(Elm)[0]];

var app = ElmModule.init();

var label = process.argv[2];

process.stdin.on(
  'data',
  data => {
    var inputLines = data.toString().split('\n');
    app.ports.startPart1.send(inputLines);
    app.ports.startPart2.send(inputLines);
  }
);

app.ports.output.subscribe(str => console.log(`\n${label} -- ${str}`));
