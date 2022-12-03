.PHONY: run wbuild wfmt test

run:
	elm make src/Day3.elm --output=main.js
	cat inputs/day3.txt | node ./cli.js input
