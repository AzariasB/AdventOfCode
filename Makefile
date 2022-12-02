.PHONY: run wbuild wfmt test

run:
	elm make src/Day2.elm --output=main.js
	cat inputs/day2.txt | node ./cli.js input
