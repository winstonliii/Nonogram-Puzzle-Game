# Nonogram-Puzzle-Game
Nonogram Puzzle Game application with a command-line interface where a player will be able to generate puzzles of any selected grid size (5x5 to 15x15), interactively solve the puzzles, or use our automated Nonogram solver that will use constraint propagation and backtracking that automatically solves any generated puzzle.

Reena checkpoint progress: Implemented the nonogram solver with deterministic line solving with backtracking. The line solver generates all valid placements for a row/column given its clue and then filters out inconsistent placements based on the current grid and intersects them to find out which cells that must be filled or empty. On top of that added the solve function whichrepeatedly propagates these constraints and then performs backtracking guesses on the unknown cells which aids in detecting contradictions and then the unique solution check. On the frontend, we now have a two page web UI with a home page with buttons to generate a 5×5, 10×10, 15×15 nonogram and a loading bar, and a dedicated game page that renders a generated 5×5 puzzle. The game page shows a Nonogram grid with row/column clues, plus a toolbar with hint, autosolve, check, and restart buttons and a sidebar that tracks elapsed time and logs actions (puzzle generated, hint used, autosolve, correct/incorrect checks). Currently only the 5×5 size is fully playable and the alignment of the clues does not display properly on the top when there are multi-number clues. Additionally the hint button is moreless a placeholder as we wanted the hint to be given to a selected cell rather than a random hint in the grid.

Winston checkpoint progress update:
This sprint I mainly focused on implementing the puzzle generator and validator modules and their
respective unit tests.

Implemented the puzzle generator which creates random Nonogram puzzles with guaranteed unique solutions. The generator works by first creating a random solution matrix for the specified grid size, then automatically deriving row and column clues from the solution using RLE. To ensure proper puzzle creation, the generator integrates with the solver module to verify that each generated puzzle has exactly one solution. If a puzzle has no solution or multiple solutions, the generator automatically retries with a new random grid, attempting up to a max of 100 times (possibly changed later as we see how efficient this is with larger puzzle sizes like 15x15) before reporting failure. Upon successful generation, it returns both the complete solution puzzle and a blank puzzle with clues ready for user to play with. Also implemented the validator module which handles complete solution validation against row and column clues. The validator returns one of the results: Valid when all cells are filled and match the clues, Incomplete when the grid still has unknown cells but no contradictions exist, or Invalid with a list of specific errors when clues are violated. The module also provides error reporting through RowError and ColError variants that identify exactly which rows or columns fail validation. Additionally, the clue_of_cells function derives clues from any sequence of cell states, which is shared with the generator module to ensure consistent clue encoding throughout the application.



What is working:
- Puzzle Data Structure: Immutable puzzle representation with PosMap, cell states (Empty/Filled/Unknown), position-based access
- Solver Algorithm: Line solver with constraint propagation, backtracking search, unique/multiple solution detection
- Puzzle Generator: Random puzzle generation for 5x5 with uniqueness verification
- Validator Complete: Validation of puzzles against clues with detailed error reporting
- Game State Management: FillCell, MarkEmpty, ClearCell, RestartPuzzle, CheckSolution (completion check working)
- Web UI: Interactive grid, clue display, timer, action logging, hint/autosolve/check/restart buttons
- Unit Tests: Coverage for Puzzle, Game, Generator, Validator, and Solver modules

What is not working:
- 10x10 and 15x15 in UI is currently disabled: While our backend should fully supports these sizes, our web UI is currently limited to 5x5 only as we continue to develop our UI. 
- GetHint in Game module currently is a placeholder: since we are working on frontend features that allow detection of what cell the mouse is currently on and the ability for single cell select, row/col select feature, and drag select. While this is not one of our core features in the game, we hope to accomplish these obejctives in the final submission.
- Score calculation: Still in progress. Always returns score = 0 as we want to integrate timer and hint usage into the game score calculation as well. This is also not one of our core features in the game, we hope to accomplish these obejctives in the final submission. 

Setup:

1. ``` clone the repository ```

2. ``` dune build ```

3. ``` opam install . --deps-only --working-dir ```



Launch Dream Frontend:

``` dune exec --root . ./nonogram_web.exe ```


TODOS:
- Push rest of functions and change remove math.poly
- Write simple and complex tests for all important feature that you implement (everyone)
- End to end invariant tests (brandon)




Final Demo and Submission:
- Edge Cases ()

