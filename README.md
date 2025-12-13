
# Nonogram-Puzzle-Game

This project is a web-based Nonogram puzzle game implemented in OCaml using functional programming principles. Players can generate and solve Nonogram puzzles of sizes 5×5, 10×10, and 15×15 through an interactive web interface. The system supports manual solving, automatic solving, solution checking, puzzle restarting, and activity logging.

At the core of the project is a reusable OCaml Nonogram library that implements puzzle representation, constraint-based solving, puzzle generation with guaranteed unique solutions, and solution validation. A Dream-based web frontend uses this library to provide an interactive gameplay experience.

# Features

The game allows users to generate Nonogram puzzles at multiple sizes and solve them interactively by filling cells or marking them empty. Row and column clues are displayed alongside the grid, and players can check whether their solution is correct, restart the puzzle, or let the solver automatically complete the puzzle. The interface also includes a timer and an activity log that records actions such as puzzle generation, hints, checks, and autosolve usage.

The solver uses deterministic constraint propagation combined with backtracking search. Each row and column is treated as a line with a run-length–encoded clue, and all valid placements consistent with the current grid state are generated. Forced cells are deduced by intersecting all valid placements, and these deductions are propagated across the grid until no further progress can be made. If unknown cells remain, the solver branches on a guess and recursively searches for solutions, stopping early once multiple solutions are detected.

The puzzle generator creates random solution grids, derives clues using run-length encoding, and verifies uniqueness by invoking the solver. Puzzles that are unsolvable or have multiple solutions are discarded and regenerated. The validator independently checks whether a completed puzzle matches all row and column clues and reports whether the solution is valid, incomplete, or invalid with detailed error information.

# Project structure

The project is divided into a core library and a web frontend. The library includes modules for grid abstraction, puzzle representation, solving, generation, validation, and game state management. The web frontend (nonogram_web.ml) depends on this library and provides all user interaction through a Dream-based server.

# Setup:
1. Clone the repository:
   ```
   git clone https://github.com/winstonliii/Nonogram-Puzzle-Game.git
   cd Nonogram-Puzzle-Game
   ```

2. Install dependencies:
   ```
   opam install . --deps-only --working-dir
   ```

3. Build the project:
   ```
   dune build
   ```
4. Run tests:
   ```
   dune test
   ```
5. Launch Dream Frontend:
   
    ```
    dune exec --root . ./nonogram_web.exe
    ```
6. Open in Browser:
   ```
   http://localhost:8080
   ```

# Dependencies

All OCaml dependencies are specified in the generated nonogram_web.opam file, including core, dream, lwt, and ounit2 for testing. There are no non-opam system level dependencies.

# Authors
Reena Assassa
Winston Li
Paul Wisner
