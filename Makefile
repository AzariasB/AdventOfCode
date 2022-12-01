.PHONY: run wbuild wfmt test

run:
	elm make src/Day1.elm --output=main.js
	cat inputs/day1.txt | node ./cli.js input
