let read_key () =
  let key = input_char stdin in
  if key <> '\027' then
    String.make 1 key
  else
    let second = input_char stdin in
    if second = '[' || second = 'O' then
      match input_char stdin with
      | 'A' -> "up"
      | 'B' -> "down"
      | 'C' -> "right"
      | 'D' -> "left"
      | _ -> ""
    else
      ""

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
  if key = "\004" then ()
  else
    let (next_state, lst_finals, action) = Recognition.process_key automaton bindings current_state key in
    match action with
    | None -> loop automaton bindings next_state
    | Some action ->
      let () = print_endline action;
      List.iter print_endline lst_finals in
      loop automaton bindings next_state

let start automaton bindings =
  Sys.catch_break true;
  enable_raw_mode ();
  (
    try loop automaton bindings 0
    with e ->
      (try disable_raw_mode () with _ -> ());
      raise e
  );
  disable_raw_mode ()

