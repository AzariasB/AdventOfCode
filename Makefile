run:
	elm make src/Day24.elm  --output=main.js
	cat inputs/day24.txt | node --stack-size=4096 ./cli.js input
