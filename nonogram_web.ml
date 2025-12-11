open Core
open Nonogram

let list_to_js_string ~f ls =
  "[" ^ String.concat ~sep:"," (List.map ls ~f) ^ "]"

let js_of_int_list (lst : int list) : string =
  list_to_js_string ~f:Int.to_string lst

let js_of_clue_array (puzzle : Puzzle.t) ~is_row : string =
  let n = Puzzle.size puzzle in
  let get_clue i =
    let (Puzzle.RLE nums) =
      if is_row then Puzzle.row_clue puzzle i else Puzzle.col_clue puzzle i
    in
    js_of_int_list nums
  in
  let elems = List.init n ~f:get_clue in
  list_to_js_string ~f:(fun x -> x) elems

let js_of_solution (solution : Puzzle.t) : string =
  let n = Puzzle.size solution in
  let row_to_js y =
    let row = Puzzle.rows solution y in
    let ints =
      List.map row ~f:(function
        | Puzzle.Filled -> "1"
        | Puzzle.Empty -> "0"
        | Puzzle.Unknown -> "0")
    in
    list_to_js_string ~f:(fun x -> x) ints
  in
  let rows = List.init n ~f:row_to_js in
  list_to_js_string ~f:(fun x -> x) rows

(* home page *)

let landing_html : string =
  {|
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Nonograms</title>
    <style>
      body {
        font-family: sans-serif;
        background: #f5f5f5;
        margin: 0;
        padding: 2rem;
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: flex-start;
      }

      .container {
        background: #ffffff;
        padding: 2rem 3rem;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        max-width: 540px;
        width: 100%;
        text-align: center;
      }

      h1 {
        margin-top: 0;
        margin-bottom: 0.5rem;
      }

      .subtitle {
        margin-top: 0;
        margin-bottom: 1.5rem;
        color: #555;
      }

      .size-buttons {
        display: flex;
        justify-content: center;
        gap: 1rem;
        flex-wrap: wrap;
        margin-bottom: 2rem;
      }

      .size-buttons button {
        padding: 0.6rem 1.4rem;
        border-radius: 999px;
        border: 1px solid #ccc;
        background: #fff;
        cursor: pointer;
        font-size: 1rem;
        transition: background 0.15s ease, transform 0.05s ease,
                    box-shadow 0.15s ease;
      }

      .size-buttons button:hover {
        background: #f0f0f0;
      }

      .size-buttons button:active {
        transform: scale(0.97);
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
      }

      .status {
        margin-bottom: 0.75rem;
        color: #333;
        font-weight: 500;
      }

      .hidden {
        display: none;
      }

      .progress-container {
        width: 100%;
        height: 10px;
        background: #ddd;
        border-radius: 999px;
        overflow: hidden;
        margin-bottom: 0.5rem;
      }

      .progress-bar {
        height: 100%;
        width: 0%;
        background: #4caf50;
        transition: width 0.12s linear;
      }

      .hint {
        font-size: 0.9rem;
        color: #777;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <h1>Welcome to Nonograms</h1>
      <p class="subtitle">Choose a puzzle size to get started.</p>

      <div class="size-buttons">
        <button onclick="startGeneration(5)">5 x 5</button>
        <button onclick="startGeneration(10)">10 x 10</button>
        <button onclick="startGeneration(15)">15 x 15</button>
      </div>

      <div id="status" class="status hidden">
        Generating nonogram…
      </div>

      <div id="progress-container" class="progress-container hidden">
        <div id="progress-bar" class="progress-bar"></div>
      </div>

      <div id="hint" class="hint hidden">
        Currently, only 5×5 puzzles are implemented.
      </div>
    </div>

    <script>
      function startGeneration(size) {
        const status = document.getElementById('status');
        const container = document.getElementById('progress-container');
        const bar = document.getElementById('progress-bar');
        const hint = document.getElementById('hint');

        status.classList.remove('hidden');
        container.classList.remove('hidden');
        hint.classList.remove('hidden');

        if (size !== 5) {
          status.textContent = 'Only 5 x 5 puzzles are implemented right now.';
          bar.style.width = '0%';
          return;
        }

        status.textContent = 'Generating ' + size + ' x ' + size + ' nonogram…';

        let progress = 0;
        bar.style.width = '0%';

        if (window._progressInterval) {
          clearInterval(window._progressInterval);
        }

        window._progressInterval = setInterval(function () {
          progress += 8;
          if (progress >= 100) {
            progress = 100;
            clearInterval(window._progressInterval);
            status.textContent = 'Nonogram ready!';
            bar.style.width = progress + '%';
            // After a short delay, go to the game page.
            setTimeout(function () {
              window.location.href = '/game/5';
            }, 300);
          } else {
            bar.style.width = progress + '%';
          }
        }, 80);
      }
    </script>
  </body>
</html>
|}

(* game page with 5x5 grid and sidebar*)

let game_page_html (solution : Puzzle.t) (puzzle : Puzzle.t) : string =
  let size = Puzzle.size puzzle in
  let row_clues_js = js_of_clue_array puzzle ~is_row:true in
  let col_clues_js = js_of_clue_array puzzle ~is_row:false in
  let solution_js = js_of_solution solution in
  {|
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Nonogram 5x5</title>
    <style>
      body {
        font-family: sans-serif;
        background: #f5f5f5;
        margin: 0;
        padding: 1.5rem;
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: flex-start;
      }

      .app-shell {
        max-width: 980px;
        width: 100%;
      }

      .top-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1rem;
      }

      .home-btn {
        padding: 0.4rem 1rem;
        border-radius: 999px;
        border: 1px solid #ccc;
        background: #fff;
        cursor: pointer;
        font-size: 0.9rem;
        text-decoration: none;
        color: #333;
        transition: background 0.15s ease, transform 0.05s ease;
      }

      .home-btn:hover {
        background: #f0f0f0;
      }

      .home-btn:active {
        transform: scale(0.97);
      }

      .app {
        display: flex;
        gap: 1.5rem;
      }

      .main-panel {
        flex: 2;
        background: #ffffff;
        border-radius: 12px;
        padding: 1.5rem 2rem;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
      }

      .sidebar {
        flex: 1;
        background: #ffffff;
        border-radius: 12px;
        padding: 1.5rem;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        display: flex;
        flex-direction: column;
        gap: 1rem;
      }

      .game-title {
        margin-top: 0;
        margin-bottom: 0.25rem;
      }

      .game-subtitle {
        margin: 0;
        color: #666;
        margin-bottom: 1rem;
      }

      .toolbar {
        display: flex;
        gap: 0.5rem;
        margin-bottom: 1rem;
      }

      .toolbar button {
        padding: 0.4rem 0.9rem;
        border-radius: 999px;
        border: 1px solid #ccc;
        background: #fafafa;
        cursor: pointer;
        font-size: 0.9rem;
        transition: background 0.15s ease, transform 0.05s ease;
      }

      .toolbar button:hover {
        background: #f0f0f0;
      }

      .toolbar button:active {
        transform: scale(0.97);
      }

      .board-wrapper {
        display: inline-block;
        padding: 0.75rem;
        border-radius: 12px;
        background: #f9f9f9;
        border: 1px solid #e0e0e0;
      }

      table.board {
        border-collapse: collapse;
        table-layout: fixed;
      }

      table.board th,
      table.board td {
        padding: 0;
        margin: 0;
        text-align: center;
      }

      .corner {
        width: 40px;
        height: 40px;
      }

      .col-clue-cell {
        width: 28px;
        height: 40px;
        font-size: 0.7rem;
        color: #555;
        white-space: pre-line;
        vertical-align: bottom;
      }

      .row-clue-cell {
        width: 40px;
        font-size: 0.7rem;
        color: #555;
        text-align: right;
        padding-right: 4px;
        white-space: pre;
      }

      .grid-cell {
        width: 28px;
        height: 28px;
      }

      .cell {
        width: 28px;
        height: 28px;
        border-radius: 4px;
        border: 1px solid #ccc;
        background: #ffffff;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
        user-select: none;
        transition: background 0.12s ease, transform 0.05s ease, box-shadow 0.12s ease;
      }

      .cell:hover {
        box-shadow: 0 0 0 2px rgba(76, 175, 80, 0.2);
      }

      .cell.filled {
        background: #4caf50;
        color: white;
      }

      .cell.empty {
        background: #f5f5f5;
        color: #999;
      }

      .logger-title {
        font-weight: 600;
        margin: 0;
      }

      .timer {
        font-size: 1rem;
        font-weight: 600;
        padding: 0.5rem 0.75rem;
        border-radius: 999px;
        background: #f5f5f5;
        display: inline-block;
      }

      .log-panel {
        flex: 1;
        border-radius: 8px;
        border: 1px solid #e0e0e0;
        padding: 0.5rem;
        background: #fafafa;
        overflow-y: auto;
        font-size: 0.85rem;
      }

      .log-entry {
        margin: 0.15rem 0;
      }

      .log-entry span {
        color: #888;
        font-size: 0.75rem;
      }

      .tag {
        display: inline-block;
        padding: 0.1rem 0.45rem;
        border-radius: 999px;
        font-size: 0.7rem;
        margin-right: 0.25rem;
      }

      .tag-info {
        background: #e3f2fd;
        color: #1565c0;
      }

      .tag-success {
        background: #e8f5e9;
        color: #2e7d32;
      }

      .tag-warn {
        background: #fff8e1;
        color: #f57c00;
      }
    </style>
  </head>
  <body>
    <div class="app-shell">
      <div class="top-bar">
        <h1>Nonogram 5x5</h1>
        <a href="/" class="home-btn">← Back to home</a>
      </div>

      <div class="app">
        <div class="main-panel">
          <p class="game-subtitle">Fill the grid to match the clues. Click to toggle: blank → filled → X.</p>

          <div class="toolbar">
            <button id="btn-hint">Hint</button>
            <button id="btn-autosolve">Autosolve</button>
            <button id="btn-check">Check</button>
            <button id="btn-restart">Restart</button>
          </div>

          <div class="board-wrapper">
            <table class="board">
              <thead>
                <tr id="col-clues-row">
                  <th class="corner"></th>
                  <!-- column clues injected by JS -->
                </tr>
              </thead>
              <tbody id="board-body">
                <!-- row clues + cells injected by JS -->
              </tbody>
            </table>
          </div>
        </div>

        <div class="sidebar">
          <div class="timer" id="timer">Time: 0s</div>
          <div>
            <p class="logger-title">Activity log</p>
            <div class="log-panel" id="log-panel"></div>
          </div>
        </div>
      </div>
    </div>

    <script>
      const SIZE = |} ^ Int.to_string size ^ {|;
      const ROW_CLUES = |} ^ row_clues_js ^ {|;
      const COL_CLUES = |} ^ col_clues_js ^ {|;
      const SOLUTION = |} ^ solution_js ^ {|;
      // SOLUTION[y][x] = 1 for filled, 0 for empty

      // 0 = unknown, 1 = filled, 2 = empty
      let gridState = Array.from({ length: SIZE }, () =>
        Array.from({ length: SIZE }, () => 0)
      );

      let solved = false;
      let elapsed = 0;
      let timerInterval = null;
      let hintsUsed = 0;

      function log(message, kind = "info") {
        const panel = document.getElementById("log-panel");
        const div = document.createElement("div");
        div.className = "log-entry";

        const tagSpan = document.createElement("span");
        tagSpan.className = "tag " + (
          kind === "success" ? "tag-success" :
          kind === "warn" ? "tag-warn" : "tag-info"
        );
        tagSpan.textContent =
          kind === "success" ? "✓" :
          kind === "warn" ? "!" : "i";

        const text = document.createElement("span");
        text.style.marginLeft = "0.25rem";
        text.textContent = " " + message;

        div.appendChild(tagSpan);
        div.appendChild(text);

        panel.appendChild(div);
        panel.scrollTop = panel.scrollHeight;
      }

      function startTimer() {
        const timer = document.getElementById("timer");
        if (timerInterval) {
          clearInterval(timerInterval);
        }
        elapsed = 0;
        timer.textContent = "Time: 0s";
        timerInterval = setInterval(() => {
          if (!solved) {
            elapsed += 1;
            timer.textContent = "Time: " + elapsed + "s";
          }
        }, 1000);
      }

      function stopTimer() {
        if (timerInterval) {
          clearInterval(timerInterval);
          timerInterval = null;
        }
      }

      function renderCluesAndGrid() {
        const colRow = document.getElementById("col-clues-row");
        // Clear existing THs except the first (corner)
        while (colRow.children.length > 1) {
          colRow.removeChild(colRow.lastChild);
        }
        for (let x = 0; x < SIZE; x++) {
          const th = document.createElement("th");
          th.className = "col-clue-cell";
          const nums = COL_CLUES[x];
          th.textContent = nums.length ? nums.join("\\n") : "0";
          colRow.appendChild(th);
        }

        const body = document.getElementById("board-body");
        body.innerHTML = "";

        for (let y = 0; y < SIZE; y++) {
          const tr = document.createElement("tr");

          const clueTd = document.createElement("td");
          clueTd.className = "row-clue-cell";
          const nums = ROW_CLUES[y];
          clueTd.textContent = nums.length ? nums.join(" ") : "0";
          tr.appendChild(clueTd);

          for (let x = 0; x < SIZE; x++) {
            const td = document.createElement("td");
            td.className = "grid-cell";

            const cell = document.createElement("div");
            cell.className = "cell";
            cell.dataset.x = x;
            cell.dataset.y = y;
            cell.addEventListener("click", onCellClick);
            updateCellVisual(cell, 0);

            td.appendChild(cell);
            tr.appendChild(td);
          }

          body.appendChild(tr);
        }
      }

      function updateCellVisual(cell, state) {
        cell.classList.remove("filled", "empty");
        cell.textContent = "";
        if (state === 1) {
          cell.classList.add("filled");
        } else if (state === 2) {
          cell.classList.add("empty");
          cell.textContent = "✕";
        }
      }

      function onCellClick(e) {
        if (solved) return;
        const cell = e.currentTarget;
        const x = parseInt(cell.dataset.x, 10);
        const y = parseInt(cell.dataset.y, 10);

        const current = gridState[y][x];
        const next = (current + 1) % 3; // 0 -> 1 -> 2 -> 0
        gridState[y][x] = next;
        updateCellVisual(cell, next);
      }

      function resetGrid() {
        gridState = Array.from({ length: SIZE }, () =>
          Array.from({ length: SIZE }, () => 0)
        );
        const cells = document.querySelectorAll(".cell");
        cells.forEach(cell => updateCellVisual(cell, 0));
        solved = false;
        hintsUsed = 0;
        startTimer();
        log("Puzzle restarted.", "info");
      }

      function isSolvedCorrectly() {
        for (let y = 0; y < SIZE; y++) {
          for (let x = 0; x < SIZE; x++) {
            const target = SOLUTION[y][x]; // 1 = filled, 0 = empty
            const state = gridState[y][x];
            if (state === 0) return false;
            if (target === 1 && state !== 1) return false;
            if (target === 0 && state === 1) return false;
          }
        }
        return true;
      }

      function onCheck() {
        if (isSolvedCorrectly()) {
          solved = true;
          stopTimer();
          log("Puzzle solved correctly in " + elapsed + "s with " + hintsUsed + " hint(s).", "success");
        } else {
          log("Check failed: puzzle is incorrect or incomplete.", "warn");
        }
      }

      function giveHint() {
        if (solved) return;
        const candidates = [];
        for (let y = 0; y < SIZE; y++) {
          for (let x = 0; x < SIZE; x++) {
            const target = SOLUTION[y][x];
            const state = gridState[y][x];
            const shouldBe = target === 1 ? 1 : 2; // treat empty as "X"
            if (state !== shouldBe) {
              candidates.push({ x, y, state: shouldBe });
            }
          }
        }
        if (candidates.length === 0) {
          log("No hint available: puzzle already matches solution.", "info");
          return;
        }
        const choice = candidates[Math.floor(Math.random() * candidates.length)];
        gridState[choice.y][choice.x] = choice.state;
        const sel = document.querySelector(
          `.cell[data-x="${choice.x}"][data-y="${choice.y}"]`
        );
        if (sel) updateCellVisual(sel, choice.state);

        hintsUsed += 1;
        log("Hint used at (" + (choice.x + 1) + ", " + (choice.y + 1) + ").", "info");
      }

      function autosolve() {
        for (let y = 0; y < SIZE; y++) {
          for (let x = 0; x < SIZE; x++) {
            const target = SOLUTION[y][x];
            gridState[y][x] = target === 1 ? 1 : 2;
          }
        }
        const cells = document.querySelectorAll(".cell");
        cells.forEach(cell => {
          const x = parseInt(cell.dataset.x, 10);
          const y = parseInt(cell.dataset.y, 10);
          updateCellVisual(cell, gridState[y][x]);
        });
        solved = true;
        stopTimer();
        log("Autosolve completed.", "success");
      }

      function init() {
        renderCluesAndGrid();
        startTimer();
        log("5x5 nonogram is ready to play.", "info");

        document.getElementById("btn-check").addEventListener("click", onCheck);
        document.getElementById("btn-restart").addEventListener("click", resetGrid);
        document.getElementById("btn-hint").addEventListener("click", giveHint);
        document.getElementById("btn-autosolve").addEventListener("click", autosolve);
      }

      window.addEventListener("DOMContentLoaded", init);
    </script>
  </body>
</html>
|}

let () =
  Dream.run
    (Dream.logger
     @@ Dream.router [
       (* home page *)
       Dream.get "/" (fun _req ->
         Dream.html landing_html);

       (* 5x5 game page w generator and solve *)
       Dream.get "/game/5" (fun _req ->
         match Generator.generate { Generator.rows = 5; cols = 5 } with
         | Generator.Failure msg ->
             Dream.html
               ("<h1>Failed to generate puzzle</h1><p>"
                ^ Dream.html_escape msg ^ "</p>")
         | Generator.Success (solution, puzzle) ->
             Dream.html (game_page_html solution puzzle));
     ])