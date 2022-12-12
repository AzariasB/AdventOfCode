.PHONY: run wbuild wfmt test

run:
	elm make src/Day10.elm --output=main.js
	cat inputs/day10.txt | node ./cli.js input
