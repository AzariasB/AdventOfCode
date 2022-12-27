run:
	elm make src/Day25.elm  --output=main.js
	cat inputs/day25.txt | node --stack-size=4096 ./cli.js input
