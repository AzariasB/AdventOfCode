run:
	elm make src/Day20.elm  --output=main.js
	cat inputs/day20.txt | node --stack-size=4096 ./cli.js input
