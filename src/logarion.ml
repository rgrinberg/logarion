open Lens

type author = {
    name: string;
    email: string;
  } [@@deriving lens]

type date = {
    edited: float;
    published: float;
  } [@@deriving lens]

type meta = {
    title: string;
    author: author;
    dates: date;
    categories: string list;
    topics: string list;
    keywords: string list;
    series: string list;
    abstract: string;
  } [@@deriving lens]

type ymd = {
    meta: meta;
    body: string;
  } [@@deriving lens]

open Str

let blank_meta = {
    title = ""; author = { name = ""; email = "" };
    dates = { edited = 0.0; published = 0.0 };
    categories = []; topics = []; keywords = []; series = [];
    abstract = ""
  }

let blank_ymd =
  { meta = blank_meta; body = "" }

let load_file f =
  let ic = open_in f in
  let n = in_channel_length ic in
  let s = String.create n in
  really_input ic s 0 n;
  close_in ic;
  (s)

let meta_field line =
  let e = bounded_split (regexp ": *") line 2 in
  if List.length e = 2
  then (List.nth e 0, List.nth e 1)
  else (line, "")

let meta_of_yaml yaml =
  let lines = split (regexp "\n") yaml in
  let fields = List.map meta_field lines in
  let field_map meta (k,v) = match k with
    | "title" -> { meta with title = v }
    | "abstract" -> { meta with abstract = v }
    | _ -> meta
  in
  List.fold_left field_map blank_meta fields

let of_file s =
  let segments = bounded_split (regexp "^---$") (load_file s) 3 in
  let yaml_str = List.nth segments 0 in
  let md_str = List.nth segments 1 in
  let m = meta_of_yaml yaml_str in
  { meta = m; body = md_str }

let titles () =
  let ymds = Array.to_list @@ Sys.readdir "ymd/" in
  let t y = (of_file ("ymd/" ^ y)).meta.title in
  List.map t ymds
