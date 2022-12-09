.PHONY: run wbuild wfmt test

run:
	elm make src/Day9.elm --output=main.js
	cat inputs/day9.txt | node ./cli.js input
