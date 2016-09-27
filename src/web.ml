open Opium.Std

let filepath_of_param req prm =
  let filename = Ymd.filename_of_title @@ param req prm in
  "ymd/" ^ filename

let ymd_of_body_pairs pairs =
  let open Ymd in
  let open Lens.Infix in
  ListLabels.fold_left ~f:(fun a (k,vl) -> with_kv a (k, List.hd vl) ) ~init:blank_ymd pairs
  |> ((ymd_meta |-- meta_date |-- date_edited) ^= Some (Ptime_clock.now ()))

let ymd_of_req req =
  let pairs = Lwt_main.run @@ App.urlencoded_pairs_of_body req in
  ymd_of_body_pairs pairs

let file_response file = `String (Logarion.load_file file) |> respond'
let ymd_response ymd = `Html (Html.of_ymd (Logarion.of_file ymd)) |> respond'
let form_response ymd = `Html (Html.form (Logarion.of_file ymd)) |> respond'

let print_css  = get "/style.css" @@ (fun _ -> file_response "ymd/style.css")
let print_ymd  = get "/:title" @@ (fun req -> filepath_of_param req "title" |> ymd_response)
let print_form = get "/()/new" @@ (fun _ -> `Html (Html.form (Ymd.blank_ymd)) |> respond')

let process_form = post "/()/new" (fun req -> let ymd = ymd_of_req req in Logarion.to_file ymd; `Html (Html.of_ymd ymd) |> respond')
let edit_form = get "/:title/edit" (fun req -> filepath_of_param req "title" |> form_response)
let print_toc = get "/" (fun req -> `Html (Html.of_titled_files (Logarion.titled_files ())) |> respond')

let _ =
  App.empty
  |> print_ymd
  |> print_form
  |> edit_form
  |> process_form
  |> print_css
  |> print_toc
  |> App.run_command
