.PHONY: run wbuild wfmt test

run:
	elm make src/Day14.elm --output=main.js
	cat inputs/day14.txt | node --stack-size=4096 ./cli.js input
