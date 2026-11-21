let print_state result =
  match result with
  | Some state ->
      print_endline ("Next state: " ^ string_of_int state)
  | None ->
      print_endline "No transition"

let () =
  print_state (Automaton.step Automaton.fireball 16 "Down");
  print_state (Automaton.next_state Automaton.fireball 0 "Down");
  (* print_state (Automaton.next_state Automaton.fireball 1 "Punch");
  print_state (Automaton.next_state Automaton.fireball 2 "Punch"); *)
  (* print_endline (string_of_bool (Automaton.is_final Automaton.fireball 2)) *)
  (* print_endline (string_of_bool (Automaton.recognize Automaton.fireball ["Down"; "Right"; "Punch"])) *)
