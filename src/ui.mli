(* The type of UI events from user interaction. *)
type event =
  | CellClick of Puzzle.position * click_type
  | ButtonClick of button_type
  | KeyPress of char
  | WindowClose

(* Type of mouse clicks on cells. *)
and click_type =
  | LeftClick
  | RightClick
  | DoubleClick

(* Type of UI buttons. *)
and button_type =
  | HintButton
  | SolveButton
  | CheckButton
  | RestartButton
  | QuitButton
  | NewGameButton

(* Type representing the UI state. *)
type ui_state = {
  game : Game.t;
  selected_cell : Puzzle.position option;
  hover_cell : Puzzle.position option;
  show_errors : bool;
  log_messages : string list;
}

(* Type of UI rendering elements. *)
type render_element =
  | Grid of grid_info
  | Toolbar of button_type list
  | ClueDisplay of clue_info
  | LogPanel of string list
  | WinScreen of win_info
