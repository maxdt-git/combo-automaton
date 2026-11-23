let process_key automaton bindings state key =
  match Keymap.find_actions bindings key with
  | None -> (state, [], None)
  | Some action ->
    let next = Automaton.step automaton state action in
    (next, Automaton.find_moves automaton.finals next, Some action)
