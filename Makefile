.PHONY: run wbuild wfmt test

run:
	elm make src/Day5.elm --output=main.js
	cat inputs/day5.txt | node ./cli.js input
