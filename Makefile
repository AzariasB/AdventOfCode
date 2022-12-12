.PHONY: run wbuild wfmt test

run:
	elm make src/Day11.elm --optimize --output=main.js
	cat inputs/day11.txt | node --stack-size=4096 ./cli.js input
