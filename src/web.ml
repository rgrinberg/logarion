open Opium.Std

let sanitised_path path =
  let parent = Str.regexp "\.\./" in
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
      `Html (Html.html_of (Logarion.ymd filepath)) |> respond'
      end

let print_form =
  get "/()/new"
      begin fun req ->
      `Html (Html.html_of_form (Logarion.blank_ymd)) |> respond'
      end

let process_form =
  post "/()/new"
       begin fun req ->
       let title = param req "title"
       and author= param req "author"
       and text  = param req "text" in
       let ymd = Logarion.blank_ymd in
       `Html (Html.html_of ymd) |> respond'
       end

let print_toc =
  get "/" begin fun req -> `Html (Html.html_of_titles (Logarion.ymd_titles ())) |> respond' end

let _ =
  App.empty
  |> print_ymd
  |> print_form
  |> print_css
  |> print_toc
  |> App.run_command
