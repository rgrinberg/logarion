
let ymd s =
  let open Str in
  bounded_split_delim (regexp "---") s 5

let html_of string =
  let open Omd in
  to_html (of_string string)

let test = "---
title: Test
author: orbifx
---
Hello _world_!"
	     
let () =
  let md_str = List.nth (ymd test) 2 in
  
  Printf.printf "%s" (html_of md_str)
