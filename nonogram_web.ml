let () =
  Dream.run (fun _ ->
    Dream.html {|
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
        max-width: 480px;
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
      </div>
    </div>

    <script>
      function startGeneration(size) {
        const status = document.getElementById('status');
        const container = document.getElementById('progress-container');
        const bar = document.getElementById('progress-bar');
        const hint = document.getElementById('hint');

        status.textContent = 'Generating ' + size + ' × ' + size + ' nonogram…';
        status.classList.remove('hidden');
        container.classList.remove('hidden');
        hint.classList.remove('hidden');

        let progress = 0;
        bar.style.width = '0%';

        // Clear any previous interval so clicking multiple buttons works nicely
        if (window._progressInterval) {
          clearInterval(window._progressInterval);
        }

        window._progressInterval = setInterval(function () {
          progress += 5;
          if (progress >= 100) {
            progress = 100;
            clearInterval(window._progressInterval);
            status.textContent = 'Nonogram generated! (placeholder)';
          }
          bar.style.width = progress + '%';
        }, 100);
      }
    </script>
  </body>
</html>
|})

