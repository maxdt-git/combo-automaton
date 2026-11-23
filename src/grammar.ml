let read_lines path =
  let ic = open_in path in
  let rec loop acc =
    match input_line ic with
    | line -> loop (line :: acc)
    | exception End_of_file ->
      close_in ic;
      List.rev acc
    in
    loop []

let clean_lines lines =
  List.filter (fun line -> line <> "" && line.[0] <> '#') (List.map String.trim lines)

type section = Keys | Moves | Nothing

let split_sections lines =
  let rec loop section keys moves lines =
    match lines with
    | [] -> (List.rev keys, List.rev moves)
    | line :: rest ->
      match line with
      | "[keys]" -> loop Keys keys moves rest
      | "[moves]" -> loop Moves keys moves rest
      | _ ->
        match section with
        | Keys -> loop Keys (line :: keys) moves rest
        | Moves -> loop Moves keys (line :: moves) rest
        | Nothing -> loop Nothing keys moves rest
  in
  loop Nothing [] [] lines

let parse_key line =
  match String.split_on_char ':' line with
  | [ left; right ] ->
    let key = String.trim left in
    let action = String.trim right in
    if key = "" || action = "" then
      Error ("invalid key line \"" ^ line ^ "\", expected key:action")
    else Ok { Keymap.key; action }
  | _ -> Error ("invalid key line \"" ^ line ^ "\", expected key:action")

let parse_move line =
  match String.split_on_char ':' line with
  | [ left; right ] ->
    let symbols = List.map String.trim (String.split_on_char ',' left) in
    let name = String.trim right in
    if name = "" || List.exists (fun s -> s = "") symbols then
      Error ("invalid move line \"" ^ line ^ "\", expected symbol,symbol:name")
    else Ok { Automaton.sequence = symbols; name }
  | _ -> Error ("invalid move line \"" ^ line ^ "\", expected symbol,symbol:name")

let collect results =
  let rec loop acc results =
    match results with
    | [] -> Ok (List.rev acc)
    | Ok x :: rest -> loop (x :: acc) rest
    | Error e :: _ -> Error e
  in
  loop [] results

let check_duplicate_keys bindings =
  let rec loop rest =
    match rest with
    | [] -> Ok bindings
    | b :: tail ->
      if List.exists (fun other -> other.Keymap.key = b.Keymap.key) tail then
        Error ("duplicate key: " ^ b.Keymap.key)
      else loop tail
  in
  loop bindings

let parse_grammar lines =
  let (keys, moves) = split_sections (clean_lines lines) in
  match collect (List.map parse_key keys) with
  | Error e -> Error e
  | Ok bindings ->
    match check_duplicate_keys bindings with
    | Error e -> Error e
    | Ok bindings ->
      match collect (List.map parse_move moves) with
      | Error e -> Error e
      | Ok combos -> Ok (bindings, combos)
