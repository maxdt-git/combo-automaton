type transition = {
  before : int;
  symbol : string;
  after : int
}

type final = {
  state : int;
  move: string
}

type automaton = {
  transitions : transition list;
  finals : final list
}

type combo = {
  sequence : string list;
  name : string
}

let rec next_state transitions state symbol =
  match transitions with
  | [] -> None
  | head :: _ when head.symbol = symbol && head.before = state -> Some head.after
  | _ :: tail -> next_state tail state symbol

let find_moves finals state =
  List.map (fun f -> f.move) (List.filter (fun x -> x.state = state) finals)

let empty = {
  transitions = [];
  finals = [];
}

let new_state automaton =
  (List.fold_left (fun acc t -> max acc t.after) 0 automaton.transitions) + 1

let rec add_combo automaton state symbols move =
  match symbols with
  | [] -> { automaton with finals = { state = state; move = move } :: automaton.finals }
  | head :: tail ->
    match next_state automaton.transitions state head with
    | None ->
      let next = new_state automaton in
      let updated = { automaton with transitions = { before = state; symbol = head; after = next; } :: automaton.transitions } in
      add_combo updated next tail move
    | Some s -> add_combo automaton s tail move

let train combos =
  (List.fold_left (fun acc combo -> add_combo acc 0 combo.sequence combo.name) empty combos )

let step automaton state symbol =
  match next_state automaton.transitions state symbol with
  | Some next -> next
  | None ->
    match next_state automaton.transitions 0 symbol with
    | Some next -> next
    | None -> 0
