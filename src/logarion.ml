type author_t = {
    name: string;
    email: string;
  }

type date_t = {
    edited: float;
    published: float;
  }

type log_meta_t = {
    title: string;
    author: author_t;
    dates: date_t;
    categories: string list;
    topics: string list;
    keywords: string list;
    series: string list;
    abstract: string;
  }

open Str

let log_meta_field line =
  let e = bounded_split (regexp ": *") line 2 in
  (List.nth e 0, List.nth e 1)

let log_meta yaml =
  let lines = split (regexp "\n") yaml in
  let fields = List.map log_meta_field lines in
  let meta = { title = ""; author = { name = ""; email = "" };
               dates= { edited = 0.0; published = 0.0 };
               categories = []; topics = []; keywords = []; series = [];
               abstract = "" } in
  let field_map meta (k,v) = match k with
    | "title" -> { meta with title = v }
    | _ -> meta
  in
  List.fold_left field_map meta fields

let ymd s =
  let segments = bounded_split (regexp "^---$") s 3 in
  let yaml_str = List.nth segments 0 in
  let md_str = List.nth segments 1 in
  Printf.printf "%s" yaml_str;
  let meta = log_meta yaml_str in
  print_endline meta.title;
  Printf.printf "%s" md_str

let html_of string =
  let open Omd in
  to_html (of_string string)

let test = "---
title: Test
author: orbifx
---
Hello _world_!"

let () = ymd test
