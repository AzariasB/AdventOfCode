.PHONY: run wbuild wfmt test

run:
	elm make src/Day8.elm --output=main.js
	cat inputs/day8.txt | node ./cli.js input
