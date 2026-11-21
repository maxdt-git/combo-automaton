let inputs = ["q"; "w"; "a"]

let words = [
  [ "Down"; "Forward"; "Kick" ];
  [ "Down"; "Forward"; "Punch" ];
  [ "Down"; "Forward" ];
  [ "Punch" ];
]

let uppercut = {
  Automaton.transitions = [
    { Automaton.before = 0; symbol = "Down"; after = 1 };
    { Automaton.before = 1; symbol = "Forward"; after = 2 };
    { Automaton.before = 2; symbol = "Punch"; after = 3 };
  ];
  finals = [ { Automaton.state = 3; move = "Uppercut" } ];
}

let combos = [
  { Automaton.sequence = [ "Down"; "Forward"; "Punch" ]; name = "Uppercut" };
  { Automaton.sequence = [ "Down"; "Forward"; "Kick" ]; name = "Sweep" };
  { Automaton.sequence = [ "Block"; "Up" ]; name = "Jump Guard" };
  ]

(* let trained = Automaton.add_combo Automaton.empty 0 [ "Down"; "Forward"; "Punch" ] "Uppercut" *)
let trained = Automaton.train combos

let inputs_symbols = [ "Down"; "Forward"; "Punch"; "Block"; "Down"; "Forward"; "Kick" ]

let print_inputs keymap key =
  match Keymap.find_actions keymap key with
  | Some action -> print_endline (key ^ " : " ^ action)
  | None -> print_endline (key ^ " => ???")

let print_recognition automaton words =
  match Automaton.recognize automaton words with
  | Some move -> print_endline ("Move found : " ^ move)
  | None -> print_endline "Wrong combination, no move found"

let rec simulate automaton state symbols =
  match symbols with
  | [] -> ()
  | head :: tail ->
    let next = Automaton.step automaton state head in
    print_endline head;
    List.iter(fun m -> print_endline (m ^ " !!")) (Automaton.find_moves automaton.finals next);
    simulate automaton next tail


let () =
Keymap.print_keymap Keymap.keymaps;
List.iter (print_inputs Keymap.keymaps) inputs;
print_endline "----------------------";
List.iter (print_recognition uppercut) words;
print_endline "----------------------";
List.iter (print_recognition trained) words;
print_endline "----------------------";
simulate trained 0 inputs_symbols
