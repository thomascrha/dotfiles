open Printf
open Unix

type project_type = Nested | Single

type project = {
  path : string;
  project_type : project_type;
}

type folder_info = {
  path : string;
  is_open : bool;
}

let projects = [
  { path = "/home/tcrha/dotfiles"; project_type = Single };
  { path = "/home/tcrha/qbe"; project_type = Nested };
]

let run_command cmd =
  try
    let ic = Unix.open_process_in cmd in
    let output = ref [] in
    (try
       while true do
         output := input_line ic :: !output
       done
     with End_of_file -> ());
    let _ = Unix.close_process_in ic in
    List.rev !output
  with _ -> []

let command_success cmd =
  try
    let status = Unix.system cmd in
    match status with
    | WEXITED 0 -> true
    | _ -> false
  with _ -> false

let get_active_sessions () =
  let lines = run_command "tmux list-sessions -F '#{session_name}' 2>/dev/null" in
  let sessions = Hashtbl.create 16 in
  List.iter (fun line ->
    if String.length line > 0 then
      Hashtbl.add sessions line true
  ) lines;
  sessions

let is_tmux_running () =
  command_success "pgrep tmux >/dev/null 2>&1"

let tmux_session_exists name =
  command_success (sprintf "tmux has-session -t=%s 2>/dev/null" name)

let run_fzf items =
  try
    let (fd_in, fd_out) = Unix.pipe () in
    let pid = Unix.create_process "fzf"
      [| "fzf"; "--layout=reverse"; "--tmux"; "center"; "--ansi" |]
      fd_in Unix.stdout Unix.stderr in
    Unix.close fd_in;
    let oc = Unix.out_channel_of_descr fd_out in
    List.iter (fun item -> fprintf oc "%s\n" item) items;
    close_out oc;
    let (_, status) = Unix.waitpid [] pid in
    match status with
    | WEXITED 0 ->
      let ic = Unix.open_process_in "fzf --layout=reverse --tmux center --ansi" in
      let temp_file = "/tmp/fzf_input_ocaml" in
      let temp_oc = open_out temp_file in
      List.iter (fun item -> fprintf temp_oc "%s\n" item) items;
      close_out temp_oc;
      let cmd = sprintf "cat %s | fzf --layout=reverse --tmux center --ansi" temp_file in
      let lines = run_command cmd in
      Unix.unlink temp_file;
      (match lines with
       | [] -> None
       | line :: _ -> Some (String.trim line))
    | _ -> None
  with _ -> None

let basename path =
  let parts = String.split_on_char '/' path in
  match List.rev parts with
  | [] -> ""
  | last :: _ -> last

let replace_char s old_char new_char =
  String.map (fun c -> if c = old_char then new_char else c) s

let remove_prefix prefix s =
  let prefix_len = String.length prefix in
  let s_len = String.length s in
  if s_len >= prefix_len && String.sub s 0 prefix_len = prefix then
    String.sub s prefix_len (s_len - prefix_len)
  else
    s

let read_directory path =
  try
    let files = Array.to_list (Sys.readdir path) in
    List.filter (fun name ->
      try Sys.is_directory (Filename.concat path name)
      with _ -> false
    ) files
  with _ -> []

let () =
  printf "tmux-sessionizer ocaml\n";

  let active_sessions = get_active_sessions () in
  let folders = Hashtbl.create 32 in

  List.iter (fun project ->
    match project.project_type with
    | Single ->
      let name = basename project.path in
      let session_name = replace_char name '.' '_' in
      let is_open = Hashtbl.mem active_sessions session_name in
      Hashtbl.add folders name { path = project.path; is_open = is_open }
    | Nested ->
      let entries = read_directory project.path in
      List.iter (fun entry ->
        let full_path = Filename.concat project.path entry in
        let session_name = replace_char entry '.' '_' in
        let is_open = Hashtbl.mem active_sessions session_name in
        Hashtbl.add folders entry { path = full_path; is_open = is_open }
      ) entries
  ) projects;

  if Hashtbl.length folders = 0 then begin
    eprintf "No folders found\n";
    exit 1
  end;

  (* Separate and sort open/closed sessions *)
  let open_names = ref [] in
  let closed_names = ref [] in

  Hashtbl.iter (fun name info ->
    if info.is_open then
      open_names := name :: !open_names
    else
      closed_names := name :: !closed_names
  ) folders;

  let open_names = List.sort String.compare !open_names in
  let closed_names = List.sort String.compare !closed_names in

  (* Build fzf input with prefixes *)
  let names =
    (List.map (fun name -> "🟢 " ^ name) open_names) @
    (List.map (fun name -> "   " ^ name) closed_names) in

  match run_fzf names with
  | None -> exit 0
  | Some selected ->
    (* Strip the prefix *)
    let selected = remove_prefix "🟢 " (remove_prefix "   " selected) in

    let folder_info =
      try Hashtbl.find folders selected
      with Not_found ->
        eprintf "Folder not found\n";
        exit 1 in

    let selected_name = replace_char (basename selected) '.' '_' in
    let in_tmux =
      try String.length (Sys.getenv "TMUX") > 0
      with Not_found -> false in
    let tmux_running = is_tmux_running () in

    if not in_tmux && not tmux_running then begin
      (* Start new tmux session and attach with nvim *)
      let cmd = sprintf "tmux new-session -s %s -c '%s' nvim" selected_name folder_info.path in
      ignore (Unix.system cmd);
      exit 0
    end;

    (* Check if session exists *)
    if not (tmux_session_exists selected_name) then begin
      (* Create detached session with nvim *)
      let cmd = sprintf "tmux new-session -ds %s -c '%s' nvim" selected_name folder_info.path in
      ignore (Unix.system cmd)
    end;

    if not in_tmux then begin
      (* Attach to session *)
      let cmd = sprintf "tmux attach -t %s" selected_name in
      ignore (Unix.system cmd)
    end else begin
      (* Switch client to session *)
      let cmd = sprintf "tmux switch-client -t %s" selected_name in
      ignore (Unix.system cmd)
    end

