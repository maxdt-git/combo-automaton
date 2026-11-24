type binding = { key: string; action : string }

let print_binding b =
  print_endline (b.key ^ " -> " ^ b.action)

let print_keymap km =
  print_endline "Key mappings:";
  List.iter print_binding km;
  print_endline "----------------------"

let rec find_actions lst key =
  match lst with
  | [] -> None
  | head :: _ when head.key = key -> Some head.action
  | _ :: tail -> find_actions tail key
