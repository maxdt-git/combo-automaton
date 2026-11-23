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

let print_recognition automaton word =
  match Automaton.recognize automaton word with
  | [] -> print_endline "Wrong combination, no move found"
  | moves -> List.iter (fun m -> print_endline ("Move found : " ^ m)) moves

let rec simulate automaton state symbols =
  match symbols with
  | [] -> ()
  | head :: tail ->
    let next = Automaton.step automaton state head in
    print_endline head;
    List.iter(fun m -> print_endline (m ^ " !!")) (Automaton.find_moves automaton.finals next);
    simulate automaton next tail

let get_grammar_path () =
  match Sys.argv with
  | [| _; path |] -> path
  | _ -> prerr_endline "Usage: ./ft_ality path_to_grammar_file"; exit 1

let load_grammar path =
  match Grammar.read_lines path with
  | lines -> lines
  | exception Sys_error msg -> prerr_endline msg; exit 1

let () =
(* Keymap.print_keymap Keymap.keymaps;
List.iter (print_inputs Keymap.keymaps) inputs;
print_endline "----------------------";
List.iter (print_recognition uppercut) words;
print_endline "----------------------";
List.iter (print_recognition trained) words;
print_endline "----------------------";
simulate trained 0 inputs_symbols;
print_endline "----------------------";
print_endline "OPEN TEST ------";
(* test_path (get_grammar_path ()) *)
List.iter print_endline (Grammar.clean_lines (load_grammar (get_grammar_path ())));
let lines = Grammar.clean_lines (load_grammar (get_grammar_path ())) in
let (keys, moves) = Grammar.split_sections lines in
let bindings = List.map Grammar.parse_key keys in
let combos = List.map Grammar.parse_move moves in
print_endline (string_of_int (List.length bindings) ^ " keys");
print_endline (string_of_int (List.length combos) ^ " moves") *)
  let lines = load_grammar (get_grammar_path ()) in
  match Grammar.parse_grammar lines with
  | Error msg ->
    prerr_endline ("Error: " ^ msg);
    exit 1
  | Ok (keymap, combos) ->
    let automaton = Automaton.train combos in
    Keymap.print_keymap keymap;
    simulate automaton 0 inputs_symbols
