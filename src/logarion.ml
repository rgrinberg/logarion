open Ymd

let load_file f =
  let ic = open_in f in
  let n = in_channel_length ic in
  let s = Bytes.create n in
  really_input ic s 0 n;
  close_in ic;
  (s)

let of_file s =
  let segments = Re_str.(split (regexp "^---$")) (load_file s) in
  if List.length segments = 2 then
    let yaml_str = List.nth segments 0 in
    let md_str = List.nth segments 1 in
    let m = meta_of_yaml yaml_str in
    { meta = m; body = md_str }
  else
    { blank_ymd with body = "Error parsing file" }

let to_file ymd =
  let open Lwt.Infix in
  let path = "ymd/" ^ (filename ymd) in
  Lwt_io.with_file ~mode:Lwt_io.output path  (fun out ->
      Lwt_io.write out (to_string ymd)
    )

let titled_files () =
  let files = Array.to_list @@ Sys.readdir "ymd/" in
  let ymd_list a e =  if BatString.ends_with e ".ymd" then List.cons e a else a in
  let ymds = List.fold_left ymd_list [] files in
  let t y = (y, (of_file ("ymd/" ^ y)).meta.title) in
  List.map t ymds
