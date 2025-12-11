open Core
open Nonogram

let current_game : Game.t option ref = ref None

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
  List.init n ~f:get_clue |> list_to_js_string ~f:Fn.id

let js_of_solution (solution : Puzzle.t) : string =
  let n = Puzzle.size solution in
  let row_to_js y =
    let row = Puzzle.rows solution y in
    let ints =
      List.map row ~f:(function
        | Puzzle.Filled -> 1
        | Puzzle.Empty -> 0
        | Puzzle.Unknown -> 0)
    in
    list_to_js_string ~f:Int.to_string ints
  in
  List.init n ~f:row_to_js |> list_to_js_string ~f:Fn.id

let landing_html : string =
  {|
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Nonograms</title>
    <style>
      body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background: linear-gradient(135deg, #a8e6cf 0%, #dcedc1 100%);
        margin: 0;
        padding: 2rem;
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
      }

      .container {
        background: #e0e3e7;
        padding: 3rem 3.5rem;
        border-radius: 20px;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        max-width: 560px;
        width: 100%;
        text-align: center;
      }

      h1 {
        margin-top: 0;
        margin-bottom: 0.5rem;
        font-size: 2.5rem;
        background: linear-gradient(135deg, #56ab2f 0%, #a8e6cf 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
      }

      .subtitle {
        margin-top: 0;
        margin-bottom: 2.5rem;
        color: #666;
        font-size: 1.1rem;
      }

      .puzzle-icon {
        font-size: 4rem;
        margin-bottom: 1rem;
      }

      .size-buttons {
        display: flex;
        justify-content: center;
        gap: 1rem;
        flex-wrap: wrap;
        margin-bottom: 2rem;
      }

      .size-buttons button {
        padding: 1rem 2rem;
        border-radius: 12px;
        border: none;
        background: linear-gradient(135deg, #56ab2f 0%, #a8e6cf 100%);
        color: white;
        cursor: pointer;
        font-size: 1.1rem;
        font-weight: 600;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        box-shadow: 0 4px 15px rgba(86, 171, 47, 0.4);
      }

      .size-buttons button:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(86, 171, 47, 0.6);
      }

      .size-buttons button:active {
        transform: translateY(0);
      }

      .status {
        margin-bottom: 1rem;
        color: #333;
        font-weight: 500;
        font-size: 1.05rem;
      }

      .hidden {
        display: none;
      }

      .progress-container {
        width: 100%;
        height: 12px;
        background: #e9ecef;
        border-radius: 999px;
        overflow: hidden;
        margin-bottom: 1rem;
      }

      .progress-bar {
        height: 100%;
        width: 0%;
        background: linear-gradient(90deg, #56ab2f 0%, #a8e6cf 100%);
        transition: width 0.12s linear;
      }

      .hint {
        font-size: 0.95rem;
        color: #888;
        padding: 1rem;
        background: #f8f9fa;
        border-radius: 8px;
        border-left: 4px solid #ffc107;
      }

      @keyframes fadeIn {
        from {
          opacity: 0;
          transform: translateY(10px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }

      .container {
        animation: fadeIn 0.5s ease;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="puzzle-icon"></div>
      <h1>Welcome to Nonograms Game!</h1>
      <p class="subtitle">Choose a puzzle size to get started</p>

      <div class="size-buttons">
        <button onclick="startGeneration(5)">5 × 5</button>
        <button onclick="startGeneration(10)">10 × 10</button>
        <button onclick="startGeneration(15)">15 × 15</button>
      </div>

      <div id="status" class="status hidden">
        Generating nonogram…
      </div>

      <div id="progress-container" class="progress-container hidden">
        <div id="progress-bar" class="progress-bar"></div>
      </div>

      <div id="hint" class="hint hidden">
        Generating Nonogram
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

        status.textContent = 'Generating ' + size + ' × ' + size + ' nonogram…';

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
            setTimeout(function () {
              window.location.href = '/game/' + size;
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
    <title>Nonogram |} ^ Int.to_string size ^ {|x|} ^ Int.to_string size ^ {|</title>
    <style>
      body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background: linear-gradient(135deg, #a8e6cf 0%, #dcedc1 100%);
        margin: 0;
        padding: 1.5rem;
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: flex-start;
      }

      .app-shell {
        max-width: 1100px;
        width: 100%;
      }

      .top-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1.5rem;
      }

      .top-bar h1 {
        color: white;
        margin: 0;
        font-size: 2rem;
        text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
      }

      .home-btn {
        padding: 0.6rem 1.4rem;
        border-radius: 12px;
        border: none;
        background: rgba(255, 255, 255, 0.95);
        cursor: pointer;
        font-size: 0.95rem;
        font-weight: 600;
        text-decoration: none;
        color: #56ab2f;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
      }

      .home-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
      }

      .home-btn:active {
        transform: translateY(0);
      }

      .app {
        display: flex;
        gap: 1.5rem;
      }

      .main-panel {
        flex: 2;
        background: #e0e3e7;
        border-radius: 16px;
        padding: 2rem 2.5rem;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
      }

      .sidebar {
        flex: 1;
        background: #e0e3e7;
        border-radius: 16px;
        padding: 1.5rem;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
        display: flex;
        flex-direction: column;
        gap: 1rem;
      }

      .game-subtitle {
        margin: 0;
        color: #666;
        margin-bottom: 1.5rem;
        font-size: 1rem;
      }

      .toolbar {
        display: flex;
        gap: 0.6rem;
        margin-bottom: 1.5rem;
        flex-wrap: wrap;
      }

      .toolbar button {
        padding: 0.55rem 1.1rem;
        border-radius: 10px;
        border: none;
        background: linear-gradient(135deg, #56ab2f 0%, #a8e6cf 100%);
        color: white;
        cursor: pointer;
        font-size: 0.9rem;
        font-weight: 600;
        transition: transform 0.15s ease, box-shadow 0.15s ease;
        box-shadow: 0 2px 8px rgba(86, 171, 47, 0.3);
      }

      .toolbar button:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(86, 171, 47, 0.5);
      }

      .toolbar button:active {
        transform: translateY(0);
      }

      .board-wrapper {
        display: inline-block;
        padding: 1rem;
        border-radius: 16px;
        background: linear-gradient(135deg, #cfd6de 0%, #c1c9d0 100%);
        border: 2px solid #dee2e6;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
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
        width: 32px;
        height: 40px;
        font-size: 0.75rem;
        color: #495057;
        font-weight: 600;
        white-space: pre-line;
        vertical-align: bottom;
      }

      .row-clue-cell {
        width: 40px;
        font-size: 0.75rem;
        color: #495057;
        font-weight: 600;
        text-align: right;
        padding-right: 6px;
        white-space: pre;
      }

      .grid-cell {
        width: 32px;
        height: 32px;
      }

      .cell {
        width: 32px;
        height: 32px;
        border-radius: 6px;
        border: 2px solid #adb5bd;
        background: #e0e3e7;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.1rem;
        user-select: none;
        transition: all 0.15s ease;
      }

      .cell:hover {
        box-shadow: 0 0 0 3px rgba(86, 171, 47, 0.3);
        transform: scale(1.05);
      }

      .cell.filled {
        background: linear-gradient(135deg, #56ab2f 0%, #a8e6cf 100%);
        border-color: #4a9128;
        color: white;
        box-shadow: 0 2px 8px rgba(86, 171, 47, 0.4);
      }

      .cell.empty {
        background: #cfd6de;
        border-color: #ced4da;
        color: #6c757d;
      }

      .logger-title {
        font-weight: 600;
        margin: 0;
        color: #495057;
      }

      .timer {
        font-size: 1.1rem;
        font-weight: 600;
        padding: 0.7rem 1rem;
        border-radius: 12px;
        background: linear-gradient(135deg, #cfd6de 0%, #c1c9d0 100%);
        display: inline-block;
        color: #495057;
        border: 2px solid #dee2e6;
      }

      .log-panel {
        flex: 1;
        border-radius: 10px;
        border: 2px solid #e9ecef;
        padding: 0.75rem;
        background: #cfd6de;
        overflow-y: auto;
        font-size: 0.85rem;
        max-height: 400px;
      }

      .log-entry {
        margin: 0.25rem 0;
        padding: 0.4rem;
        border-radius: 6px;
        background: #e0e3e7;
      }

      .log-entry span {
        color: #6c757d;
        font-size: 0.8rem;
      }

      .tag {
        display: inline-block;
        padding: 0.15rem 0.5rem;
        border-radius: 6px;
        font-size: 0.7rem;
        font-weight: 600;
        margin-right: 0.35rem;
      }

      .tag-info {
        background: #cfe2ff;
        color: #084298;
      }

      .tag-success {
        background: #d1e7dd;
        color: #0a3622;
      }

      .tag-warn {
        background: #fff3cd;
        color: #997404;
      }

      .hidden {
        display: none;
      }

      .win-screen {
        text-align: center;
        margin-top: 2rem;
        padding: 2rem;
        background: linear-gradient(135deg, #d4fc79 0%, #96e6a1 100%);
        border-radius: 16px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
      }

      .win-screen h2 {
        margin: 0 0 1rem 0;
        color: #155724;
        font-size: 2rem;
      }

      .win-screen p {
        margin: 0.5rem 0;
        color: #155724;
        font-size: 1.2rem;
      }

      @keyframes celebrate {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.05); }
      }

      .win-screen {
        animation: celebrate 0.5s ease;
      }
    </style>
  </head>
  <body>
    <div class="app-shell">
      <div class="top-bar">
        <h1> Nonogram |} ^ Int.to_string size ^ {|×|} ^ Int.to_string size ^ {|</h1>
        <a href="/" class="home-btn">← Back to home</a>
      </div>

      <div class="app">
        <div class="main-panel">
          <p class="game-subtitle">Fill the grid to match the clues. Click to toggle: blank → filled → X.</p>

          <div class="toolbar">
            <button id="btn-hint"> Hint</button>
            <button id="btn-autosolve"> Autosolve</button>
            <button id="btn-check">✓ Check</button>
            <button id="btn-restart">↻ Restart</button>
            <button id="btn-new">Generate New Puzzle</button>
          </div>

          <div class="board-wrapper">
            <table class="board">
              <thead>
                <tr id="col-clues-row">
                  <th class="corner"></th>
                </tr>
              </thead>
              <tbody id="board-body">
              </tbody>
            </table>
          </div>
          <div id="win-screen" class="win-screen hidden">
            <h2> Congratulations!</h2>
            <p>You completed the nonogram in <span id="win-time"></span>!</p>
          </div>
        </div>

        <div class="sidebar">
          <div class="timer" id="timer">Timer 00:00</div>
          <div>
            <p class="logger-title">Activity Log</p>
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
      const GAME_PATH = "/game/" + SIZE;

      let gridState = Array.from({ length: SIZE }, () =>
        Array.from({ length: SIZE }, () => 0)
      );

      let solved = false;
      let elapsed = 0;
      let timerInterval = null;
      let hintsUsed = 0;

      function formatTime(total) {
        const minutes = Math.floor(total / 60);
        const seconds = total % 60;
        const m = minutes.toString().padStart(2, "0");
        const s = seconds.toString().padStart(2, "0");
        return m + ":" + s;
      }

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
        timer.textContent = "⏱️ " + formatTime(0);
        timerInterval = setInterval(() => {
          if (!solved) {
            elapsed += 1;
            timer.textContent = "⏱️ " + formatTime(elapsed);
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
        while (colRow.children.length > 1) {
          colRow.removeChild(colRow.lastChild);
        }
        for (let x = 0; x < SIZE; x++) {
          const th = document.createElement("th");
          th.className = "col-clue-cell";
          const nums = COL_CLUES[x];
          th.textContent = nums.length ? nums.join("\n") : "0";
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

      function showWin() {
        const winScreen = document.getElementById("win-screen");
        const winTime = document.getElementById("win-time");
        if (winScreen && winTime) {
          winTime.textContent = formatTime(elapsed);
          winScreen.classList.remove("hidden");
        }
      }

      function onCellClick(e) {
        if (solved) return;
        const cell = e.currentTarget;
        const x = parseInt(cell.dataset.x, 10);
        const y = parseInt(cell.dataset.y, 10);

        const current = gridState[y][x];
        const next = (current + 1) % 3;
        gridState[y][x] = next;
        updateCellVisual(cell, next);

        fetch("/api/update", {
          method: "POST",
          headers: {
            "Content-Type": "text/plain",
          },
          body: y + " " + x + " " + next,
        })
          .then((res) => res.json())
          .then((data) => {
            if (data.status === "won") {
              solved = true;
              stopTimer();
              log(
                "Puzzle solved in " + formatTime(elapsed) + " with " + hintsUsed + " hint(s)!",
                "success"
              );
              showWin();
            }
          })
          .catch((err) => {
            console.error("update error", err);
          });
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
        const winScreen = document.getElementById("win-screen");
        if (winScreen) {
          winScreen.classList.add("hidden");
        }
        log("Puzzle restarted.", "info");
      }

      function isSolvedCorrectly() {
        for (let y = 0; y < SIZE; y++) {
          for (let x = 0; x < SIZE; x++) {
            const target = SOLUTION[y][x];
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
          log(
            "Puzzle solved correctly in " + formatTime(elapsed) + " with " + hintsUsed + " hint(s)! 🎉",
            "success"
          );
          showWin();
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
            const shouldBe = target === 1 ? 1 : 2;
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
        showWin();
      }

      function newPuzzle() {
        window.location.href = GAME_PATH;
      }

      function init() {
        renderCluesAndGrid();
        startTimer();
        log(SIZE + "×" + SIZE + " nonogram is ready to play.", "info");

        document.getElementById("btn-check").addEventListener("click", onCheck);
        document.getElementById("btn-restart").addEventListener("click", resetGrid);
        document.getElementById("btn-hint").addEventListener("click", giveHint);
        document.getElementById("btn-autosolve").addEventListener("click", autosolve);
        document.getElementById("btn-new").addEventListener("click", newPuzzle);
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
       Dream.get "/" (fun _req ->
         Dream.html landing_html);

       (* Parameterized game route for 5, 10, 15 *)
       Dream.get "/game/:size" (fun req ->
         let size_str = Dream.param req "size" in
         match Int.of_string_opt size_str with
         | None ->
             Dream.html "<h1>Invalid size</h1>"
         | Some n ->
             if not (List.mem [ 5; 10; 15 ] n ~equal:Int.equal) then
               Dream.html "<h1>Unsupported size (use 5, 10, or 15)</h1>"
             else
               (match Generator.generate { Generator.rows = n; cols = n } with
                | Generator.Failure msg ->
                    Dream.html
                      ("<h1>Failed to generate puzzle</h1><p>"
                       ^ Dream.html_escape msg ^ "</p>")
                | Generator.Success (solution, puzzle) ->
                    let game = Game.create_with_solution puzzle solution in
                    current_game := Some game;
                    Dream.html (game_page_html solution puzzle)));

       Dream.post "/api/update" (fun req ->
         let open Lwt.Syntax in
         let* body = Dream.body req in
         let parts = String.split (String.strip body) ~on:' ' in
         let y_opt, x_opt, state_opt =
           match parts with
           | [ y_str; x_str; state_str ] ->
               Int.of_string_opt y_str, Int.of_string_opt x_str, Some state_str
           | _ ->
               None, None, None
         in
         match y_opt, x_opt, state_opt with
         | Some y, Some x, Some state_str ->
             let new_state =
               match state_str with
               | "0" -> Puzzle.Unknown
               | "1" -> Puzzle.Filled
               | "2" -> Puzzle.Empty
               | _ -> Puzzle.Unknown
             in
             (match !current_game with
              | None ->
                  Dream.json {|{"status":"no_game"}|}
              | Some g ->
                  let pos = Position.{ x; y } in
                  let action = Game.UpdateCell { pos; new_state } in
                  match Game.process_action g action with
                  | Game.Success g' ->
                      current_game := Some g';
                      Dream.json {|{"status":"ok"}|}
                  | Game.GameWon _ ->
                      current_game := Some g;
                      Dream.json {|{"status":"won"}|}
                  | Game.Error _ ->
                      Dream.json {|{"status":"error"}|}
                  | Game.HintProvided _ ->
                      Dream.json {|{"status":"hint"}"|})
         | _ ->
             Dream.json {|{"status":"bad_request"}"|});
     ])
