# Nonogram-Puzzle-Game
Nonogram Puzzle Game application with a command-line interface where a player will be able to generate puzzles of any selected grid size (5x5 to 15x15), interactively solve the puzzles, or use our automated Nonogram solver that will use constraint propagation and backtracking that automatically solves any generated puzzle.

Setup:

``` clone the repository ```

``` dune build ```

``` opam install . --deps-only --working-dir ```



Dream Testing:
dune exec --root . ./nonogram_web.exe


TODOS:
- Solver, UI (reena)
- Puzzle, Game (paul)
- Generator, Validator (winston)
- Write simple and complex tests for all important feature that you implement (everyone)
- End to end invariant tests (brandon)