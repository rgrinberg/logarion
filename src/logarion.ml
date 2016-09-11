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

type ymd_t = {
    meta: log_meta_t;
    text: string;
  }

open Str

let load_file f =
  let ic = open_in f in
  let n = in_channel_length ic in
  let s = String.create n in
  really_input ic s 0 n;
  close_in ic;
  (s)

let log_meta_field line =
  let e = bounded_split (regexp ": *") line 2 in
  if List.length e = 2
  then (List.nth e 0, List.nth e 1)
  else (line, "")
         
let log_meta yaml =
  let lines = split (regexp "\n") yaml in
  let fields = List.map log_meta_field lines in
  let m = { title = ""; author = { name = ""; email = "" };
            dates= { edited = 0.0; published = 0.0 };
            categories = []; topics = []; keywords = []; series = [];
            abstract = "" } in
  let field_map meta (k,v) = match k with
    | "title" -> { meta with title = v }
    | "abstract" -> { meta with abstract = v }
    | _ -> meta
  in
  List.fold_left field_map m fields

let ymd s =
  let segments = bounded_split (regexp "^---$") (load_file s) 3 in
  let yaml_str = List.nth segments 0 in
  let md_str = List.nth segments 1 in
  let m = log_meta yaml_str in
  { meta = m; text = md_str }

let ymd_titles () =
  let ymds = Array.to_list @@ Sys.readdir "ymd/" in
  let t y = (ymd ("ymd/" ^ y)).meta.title in
  List.map t ymds
