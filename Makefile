.PHONY: run wbuild wfmt test

run:
	elm make src/Day12.elm --output=main.js
	cat inputs/day12.txt | node --stack-size=4096 ./cli.js input
