.PHONY: run wbuild wfmt test

run:
	elm make src/Day13.elm --output=main.js
	cat inputs/day13.txt | node --stack-size=4096 ./cli.js input
