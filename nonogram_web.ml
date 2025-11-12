let () =
  Dream.run (fun _ ->
    Dream.html {|
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nonograms Puzzle Game</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            background: white;
            border-radius: 20px;
            padding: 50px;
            max-width: 600px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            text-align: center;
        }
        
        h1 {
            color: #667eea;
            font-size: 3em;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .subtitle {
            color: #666;
            font-size: 1.2em;
            margin-bottom: 30px;
        }
        
        .description {
            color: #555;
            line-height: 1.6;
            margin-bottom: 40px;
            text-align: left;
        }
        
        .button-group {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        
        .btn {
            padding: 15px 30px;
            font-size: 1.1em;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: block;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            font-weight: bold;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: #f0f0f0;
            color: #667eea;
            font-weight: 600;
        }
        
        .btn-secondary:hover {
            background: #e0e0e0;
            transform: translateY(-2px);
        }
        
        .puzzle-icon {
            font-size: 4em;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="puzzle-icon">🧩</div>
        <h1>Nonograms</h1>
        <p class="subtitle">Picture Logic Puzzles</p>
        
        <div class="description">
            <p><strong>How to play:</strong> Use the number clues on the sides to fill in the grid and reveal a hidden picture! Each number tells you how many consecutive squares to fill in that row or column.</p>
        </div>
        
        <div class="button-group">
            <button class="btn btn-primary" onclick="alert('Game starting soon!')">
                 Start New Game
            </button>
            <button class="btn btn-secondary" onclick="alert('Choose difficulty: Easy, Medium, or Hard')">
                 Select Difficulty
            </button>
            <button class="btn btn-secondary" onclick="alert('Instructions: Fill squares based on number clues to reveal pictures!')">
                 How to Play
            </button>
        </div>
    </div>
</body>
</html>
|})