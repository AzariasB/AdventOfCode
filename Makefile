.PHONY: run wbuild wfmt test

run:
	elm make src/Day6.elm --output=main.js
	cat inputs/day6.txt | node ./cli.js input
