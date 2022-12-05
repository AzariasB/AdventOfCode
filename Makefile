.PHONY: run wbuild wfmt test

run:
	elm make src/Day4.elm --output=main.js
	cat inputs/day4.txt | node ./cli.js input
