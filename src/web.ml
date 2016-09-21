open Opium.Std

let sanitised_path path =
  let parent = Str.regexp "../" in
  Str.global_replace parent "" path

let print_css =
  get "/style.css"
      begin
        fun req -> `String (Logarion.load_file "ymd/style.css") |> respond'
      end

let print_ymd =
  get "/:title"
      begin fun req ->
      let filename = sanitised_path (param req "title") in
      let filepath = "ymd/" ^ filename ^ ".ymd" in
      `Html (Html.of_ymd (Logarion.of_file filepath)) |> respond'
      end

let print_form =
  get "/()/new"
      begin fun req ->
      `Html (Html.form (Ymd.blank_ymd)) |> respond'
      end

let ymd_of_body_pairs pairs =
  let open Ymd in
  let open Lens.Infix in
  ListLabels.fold_left ~f:(fun a (k,vl) -> with_kv a (k, List.hd vl) ) ~init:blank_ymd pairs
  |> ((ymd_meta |-- meta_date |-- date_edited) ^= Some (Ptime_clock.now ()))

let process_form =
  post "/()/new"
       begin fun req ->
       let pairs = Lwt_main.run @@ App.urlencoded_pairs_of_body req in
       let open Logarion in
       let ymd = ymd_of_body_pairs pairs in
       to_file ymd;
       `Html (Html.of_ymd ymd) |> respond'
       end

let print_toc =
  get "/" begin fun req -> `Html (Html.of_titled_files (Logarion.titled_files ())) |> respond' end

let _ =
  App.empty
  |> print_ymd
  |> print_form
  |> process_form
  |> print_css
  |> print_toc
  |> App.run_command
