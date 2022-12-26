run:
	elm make src/Day17.elm  --output=main.js
	cat inputs/day17.txt | node --stack-size=4096 ./cli.js input
