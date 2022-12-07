.PHONY: run wbuild wfmt test

run:
	elm make src/Day7.elm --output=main.js
	cat inputs/day7.txt | node ./cli.js input
