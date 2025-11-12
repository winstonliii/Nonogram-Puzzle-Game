# Project Design Proposal - Nonogram Puzzle Game 
Paul Wisner, Winston Li, Reena Assassa

# 1. Project Overview 
We plan to develop a functional OCaml Nonogram Puzzle Game application based on the rules of https://www.puzzle-nonograms.com/ with a user interface.  A player will be able to generate puzzles of any selected grid size (5x5 to 15x15), interactively solve the puzzles, or use our automated Nonogram solver that will use constraint propagation and backtracking that automatically solve any generated puzzle.  
After the player has selected puzzle dimensions, our program will generate a valid Nonogram puzzle with a unique solution displayed on the UI.  The player will be able to choose actions (hint, auto solve, check, and quit) from a toolbar above the puzzle. They will be able to click to fill a cell and click twice or right click to mark a cell as empty. There will be an log section to the right of the puzzle displaying player commands and outcomes as well as an end of game messages including solve time.  Generation will create a random filled grid as a potential solution, derive the corresponding row and column clues, and test that the puzzle has exactly one solution using the solver.  If more than one solution is found, a new grid is generated and tested again.  The solver will apply constraint propagation to fill in cells that can be logically determined, and use backtracking to test remaining possibilities until the puzzle is fully solved.

# 2. Mock Use Prototype
Figma Link to Mock Use Prototype https://www.figma.com/design/mrb72ZRo0aLhGcSyi5echS/Nonograms?node-id=1-669&t=f3mX5Aeujvc5vSLs-1 

Landing page: Select nonogram size, Generate new nonogram puzzle
Nonogram page: Nonogram game with Hint (cell, column, row), Auto Solve, Check, and Restart
Leaderboard page: (Nice to have/stretch goal)

# 3. Libraries
We will use the following libraries for this project:
Stdlib
OUnit2
Stdio
Cmdliner
Dream

4. module type declarations
/src
types.mli (shared types and printers)
grid.mli (immutable board representation and accessors)
clue.mli (clue legality, placements, and intersections)
puzzle.mli
core puzzle data structure with grid, cells, and clues
solver.mli 
constraint propagation and backtracking solver
generator.mli 
puzzle generation with unique solution verification
validator.mli 
solution validation and error checking
game.mli 
game state management and user actions
ui.mli - User interface rendering and event handling
timer.mli

## 5. Implementation Plan
UI Framework and user tools:
- Implement UI built using Dream.
- Create a static grid layout that renders a square matrix for sizes 5x5, 10x10, and 15x15.
- Represent each cell as an interactive button with three states:
  - Blank (default)
  - Filled (black)
  - Marked as empty ("X")
- single-click (fill) and double-click/right-click (mark empty).

Clue Rendering and Board Context:
- Display row and column clues around the grid.
- Ensure clues update dynamically based on puzzle generation.

Toolbar and Action Buttons:
- Implement the top-bar containing core actions:
  - **Solve** (triggers full solver)
  - **Reset** (clears grid to initial state)
  - **Check** (validates current progress)
  - **Hint** (single-row, column, or cell hint)
- Connect UI events to internal function calls in the game and solver modules.
- Create a right-hand “log panel” to display:
  - Player actions
  - Solver results
  - Error messages
  - Completion messages (including solve time)

Stretch UI Features (if time permits):
- Leaderboard interface
- Improved animations or visual feedback for fills, contradictions, and hints

Line Solver (Deterministic Row/Column Deduction):
- Implement line solver, which processes one row or column at a time.
- Precompute all possible legal block placements based on:
  - Row/column length `L`
  - Clue list for that row/column
- Filter placements by removing ones inconsistent with currently known cells from the grid.
- Intersect all surviving placements to determine:
  - Cells that must be black (present in all placements)
  - Cells that must be white (absent in all placements)

Constraint Propagation:
- Implement repeated propagation:
  - Apply the line solver across all rows and columns
  - Stop when no further cells can be deduced
- Test that propagation is efficient

Full Backtracking Solver with Heuristics:
- Build the complete solver that uses:
  - The line solver for deterministic reductions
  - Strategic guessing + backtracking for ambiguous states
- For each unknown cell:
  - Choose a guess (black or white)
  - Apply propagation under that assumption
  - Detect contradictions and backtrack when necessary
- Optimize search to handle 15x15 puzzles within reasonable time.
- Provide an interface for the UI to call:
  - Solve entire grid
  - Provide step-by-step hints
  - Verify puzzle uniqueness (for generator)

Puzzle Validator:
- Implement the module that checks whether a completed grid satisfies all clues.
  - Verification for the solver
  - Validation for the “Check” button in the UI
- Contradictions, unfinished cells, or row/column mismatches display error messages.

Puzzle Generator:
- Implement the random puzzle generator:
  - Create a random filled solution grid.
  - Derive row and column clues from the solution.
  - Use the solver to verify:
    - The puzzle is solvable
    - The puzzle has exactly one unique solution
- If the puzzle has multiple solutions, regenerate a new random grid and repeat.
- Provide generated puzzles to UI and maintain a consistent interface.


Potential Stretch Goals:
- Puzzle generation from a black-and-white image:
  - Convert image into a pixel grid
  - Extract clues from image blocks
  - Ensure uniqueness is preserved
Leaderboard + Timer Backend (Stretch)**
- Maintain timing results from UI 
- Store and retrieve user records for a high score list
- Provide message formatting and integration hooks for final UI screen



