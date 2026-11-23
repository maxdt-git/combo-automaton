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

let split_lines lines =
  List.map (String.split_on_char ':') lines
