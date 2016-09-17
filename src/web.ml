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
      `Html (Html.html_of (Logarion.of_file filepath)) |> respond'
      end

let print_form =
  get "/()/new"
      begin fun req ->
      `Html (Html.html_of_form (Logarion.blank_ymd)) |> respond'
      end

let ymd_of_body_pairs pairs =
  let open Logarion in
  let open Lens.Infix in
  let field_of_pair ymd (key, value) = match key with
    | "title"  -> ((ymd_meta |-- meta_title) ^= List.hd value) ymd
    | "author" -> ((ymd_meta |-- meta_author |-- author_name) ^= List.hd value) ymd
    | "text"   -> { ymd with body = List.hd value }
    | _ -> ymd
  in
  ListLabels.fold_left ~f:field_of_pair ~init:blank_ymd pairs
  |> ((ymd_meta |-- meta_date |-- date_edited) ^= Some (Ptime_clock.now ()))

let process_form =
  post "/()/new"
       begin fun req ->
       let pairs = Lwt_main.run @@ App.urlencoded_pairs_of_body req in
       let open Logarion in
       let ymd = ymd_of_body_pairs pairs in
       let oc = open_out "ymd/saved.ymd" in
       Printf.fprintf oc "%s" (to_string ymd);
       close_out oc;
       `Html (Html.html_of ymd) |> respond'
       end

let print_toc =
  get "/" begin fun req -> `Html (Html.html_of_titles (Logarion.titles ())) |> respond' end

let _ =
  App.empty
  |> print_ymd
  |> print_form
  |> process_form
  |> print_css
  |> print_toc
  |> App.run_command
