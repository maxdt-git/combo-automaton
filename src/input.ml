let read_key () =
  let key = input_char stdin in
  String.make 1 key

let enable_raw_mode () =
  let status = Sys.command "stty -icanon -echo min 1 time 0" in
  if status <> 0 then
    failwith "Failed to enable raw mode"

let disable_raw_mode () =
  let status = Sys.command "stty sane" in
  if status <> 0 then
    failwith "Failed to disable raw mode"

let rec loop automaton bindings current_state =
  let key = read_key () in
  if key = "\027" then ()
  else
    let (next_state, lst_finals, action) = Recognition.process_key automaton bindings current_state key in
    match action with
    | None -> loop automaton bindings next_state
    | Some action ->
      let () = print_endline action;
      List.iter print_endline lst_finals in
      loop automaton bindings next_state

let start automaton bindings =
  enable_raw_mode ();
  (
    try loop automaton bindings 0
    with e ->
      disable_raw_mode ();
      raise e
  );
  disable_raw_mode ()

