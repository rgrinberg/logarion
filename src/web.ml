open Opium.Std


let print_css =
  get "/style.css"
      begin
        fun req -> `String (Logarion.load_file "ymd/style.css") |> respond'
      end
    
let print_ymd =
  get "/:title"
      begin fun req ->
      let filename = String.map (fun c -> if '/' = c then '_' else c) (param req "title") in
      let filepath = "ymd/" ^ filename ^ ".ymd" in
      `Html (Html.html_of (Logarion.ymd filepath)) |> respond'
      end

let print_toc =
  get "/" begin fun req -> `Html (Html.html_of_titles (Logarion.ymd_titles ())) |> respond' end

let _ =
  App.empty
  |> print_ymd
  |> print_css
  |> print_toc
  |> App.run_command
