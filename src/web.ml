open Opium.Std

let test = "---
title: Test
author: orbifx
---
Hello _world_!"
             
let print_ymd =
  let open Logarion in
  get "/" begin fun req ->
          `Html (html_of (ymd test)) |> respond'
          end
                       
let _ =
  App.empty
  |> print_ymd
  |> App.run_command
