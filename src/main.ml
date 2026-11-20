let inputs = ["q"; "w"; "a"]

let print_inputs keymap key =
  match Automaton.find_actions keymap key with
  | Some action -> print_endline (key ^ " : " ^ action)
  | None -> print_endline (key ^ " => ???")

let () =
  Automaton.print_keymap Automaton.keymaps;
  List.iter (print_inputs Automaton.keymaps) inputs
