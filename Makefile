run:
	elm make src/Day23.elm  --output=main.js
	cat inputs/day23.txt | node --stack-size=4096 ./cli.js input
