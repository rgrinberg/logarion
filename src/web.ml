open Opium.Std

let ymdpath title = "ymd/" ^ (Ymd.filename_of_title title)

let ymd_of_body_pairs pairs =
  let open Ymd in
  let open Lens.Infix in
  ListLabels.fold_left ~f:(fun a (k,vl) -> with_kv a (k, List.hd vl) ) ~init:blank_ymd pairs
  |> ((ymd_meta |-- meta_date |-- date_edited) ^= Some (Ptime_clock.now ()))

let ymd_of_req req =
  Lwt.map ymd_of_body_pairs (App.urlencoded_pairs_of_body req)

let string_response s = `String s |> respond'
let html_response h = `Html h |> respond'

let () =
  App.empty
  |> post "/()/new"  (fun req ->
      ymd_of_req req >>= fun ymd ->
      Logarion.to_file ymd >>= fun () ->
      `Html (Html.of_ymd ymd) |> respond')
  |> get "/:ttl"      (fun req -> param req "ttl" |> ymdpath |> Logarion.of_file |> Html.of_ymd |> html_response)
  |> get "/:ttl/edit" (fun req -> param req "ttl" |> ymdpath |> Logarion.of_file |> Html.form   |> html_response)
  |> get "/style.css" (fun _   -> "ymd/style.css" |> Logarion.load_file |> string_response)
  |> get "/()/new"    (fun _   -> Ymd.blank_ymd |> Html.form |> html_response)
  |> get "/"          (fun req -> Logarion.titled_files () |> Html.of_titled_files |> html_response)
  |> App.run_command
