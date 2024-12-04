# Advent of code 2024

Advent of code using kotlin.

## Project structure
```
.
├── build.gradle.kts
├── buildSrc // Task configuration
├── puzzles // The markdown representation of the problems
└── src // Where the code of the project is
```



## Setup day by day

```shell
export ADVENT_OF_CODE_SESSION=<session cookie>
./gradlew scaffold
```

If you want to download the task for a particular day
```shell
./gradlew scaffold -Pday=<day>
```