# Nonogram-Puzzle-Game
Nonogram Puzzle Game application with a command-line interface where a player will be able to generate puzzles of any selected grid size (5x5 to 15x15), interactively solve the puzzles, or use our automated Nonogram solver that will use constraint propagation and backtracking that automatically solves any generated puzzle.

Reena checkpoint progress: Implemented the nonogram solver with deterministic line solving with backtracking. The line solver generates all valid placements for a row/column given its clue and then filters out inconsistent placements based on the current grid and intersects them to find out which cells that must be filled or empty. On top of that added the solve function whichrepeatedly propagates these constraints and then performs backtracking guesses on the unknown cells which aids in detecting contradictions and then the unique solution check. On the frontend, we now have a two page web UI with a home page with buttons to generate a 5×5, 10×10, 15×15 nonogram and a loading bar, and a dedicated game page that renders a generated 5×5 puzzle. The game page shows a Nonogram grid with row/column clues, plus a toolbar with hint, autosolve, check, and restart buttons and a sidebar that tracks elapsed time and logs actions (puzzle generated, hint used, autosolve, correct/incorrect checks). Currently only the 5×5 size is fully playable and the alignment of the clues does not display properly on the top when there are multi-number clues. Additionally the hint button is moreless a placeholder as we wanted the hint to be given to a selected cell rather than a random hint in the grid.

Setup:

``` clone the repository ```

``` dune build ```

``` opam install . --deps-only --working-dir ```



Dream Testing:
dune exec --root . ./nonogram_web.exe


TODOS:
- Push rest of functions and change remove math.poly
- Write simple and complex tests for all important feature that you implement (everyone)
- End to end invariant tests (brandon)




Final Demo and Submission:
- Edge Cases ()

