type state = int

type transition = {
  from_state : state;
  symbol : string;
  to_state : state;
}

type t = {
  states : state list;
  alphabet : string list;
  initial : state;
  finals : state list;
  transitions : transition list;
}

let fireball = {
  states = [0; 1; 2; 3];
  alphabet = ["Down"; "Right"; "Punch"];
  initial = 0;
  finals = [3];
  transitions = [
    { from_state = 0; symbol = "Down"; to_state = 1 };
    { from_state = 1; symbol = "Right"; to_state = 2 };
    { from_state = 2; symbol = "Punch"; to_state = 3 };
  ];
}

let next_state automaton current_state key =
  (* List.find_opt returns an option so the result is Some transition *)
  let result = List.find_opt (fun x -> x.from_state = current_state && x.symbol = key) automaton.transitions in
  match result with
  | None -> None
  | Some transition -> Some transition.to_state

let is_final automaton state =
  List.mem state automaton.finals


(* We want to do something for each of the
    moves in our list so we start by matching the moves,
    if empty then final verification, else we try to go next_state
    because next_state returns an option, we try to match the return
    if None we call recursive with initial state and rest of the moves (tail) - combo failed, 
    if Some state - we call recursive with state returned (so the next state) and tail*)
let recognize automaton moves =
  let rec aux current_state moves =
    match moves with
    | [] -> is_final automaton current_state
    | head :: tail ->
      match next_state automaton current_state head with
      | None -> false
      | Some state -> aux state tail
  in
  aux automaton.initial moves 

let step automaton current_state key =
  let result = next_state automaton current_state key in
  match result with
  | Some state -> state
  | None -> 
      match next_state automaton automaton.initial key with
      | None -> automaton.initial
      | Some state -> state