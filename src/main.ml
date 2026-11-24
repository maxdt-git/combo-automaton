let get_grammar_path () =
  match Sys.argv with
  | [| _; path |] -> path
  | _ -> prerr_endline "Usage: ./ft_ality path_to_grammar_file"; exit 1

let load_grammar path =
  match Grammar.read_lines path with
  | lines -> lines
  | exception Sys_error msg -> prerr_endline msg; exit 1

let () =
  let lines = load_grammar (get_grammar_path ()) in
  match Grammar.parse_grammar lines with
  | Error msg ->
    prerr_endline ("Error: " ^ msg);
    exit 1
  | Ok (bindings, combos) ->
    let trained = Automaton.train combos in
    Keymap.print_keymap bindings;
    Input.start trained bindings
