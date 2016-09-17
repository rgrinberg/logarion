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
    | "title"  -> { ymd with meta = { ymd.meta with title  = List.hd value } }
    (*  | "author" -> ((ymd_t_meta |-- log_meta_t_author |-- author_t_name_t) ^= List.hd value) ymd *)
    | "text"   -> { ymd with body = List.hd value }
    | _ -> ymd
  in
  ListLabels.fold_left ~f:field_of_pair ~init:blank_ymd pairs

let process_form =
  post "/()/new"
       begin fun req ->
       let pairs = Lwt_main.run @@ App.urlencoded_pairs_of_body req in
       let open Logarion in
       `Html (Html.html_of (ymd_of_body_pairs pairs)) |> respond'
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
