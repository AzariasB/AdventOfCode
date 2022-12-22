run:
	elm make src/Day21.elm  --output=main.js
	cat inputs/day21.txt | node --stack-size=4096 ./cli.js input
