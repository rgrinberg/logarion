open Opium.Std

let test = "---
title: Test
author: orbifx
---
Hello _world_!"

let load_file f =
  let ic = open_in f in
  let n = in_channel_length ic in
  let s = String.create n in
  really_input ic s 0 n;
  close_in ic;
  (s)
             
let print_ymd =
  get "/:title" begin fun req ->
                let file = (param req "title") ^ ".ymd" in
                `Html (Html.html_of (Logarion.ymd (load_file file))) |> respond'
                end
                       
let _ =
  App.empty
  |> print_ymd
  |> App.run_command
