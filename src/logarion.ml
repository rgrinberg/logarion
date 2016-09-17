open Lens

type author = {
    name: string;
    email: string;
  } [@@deriving lens]

type date = {
    edited: Ptime.t option;
    published: Ptime.t option;
  } [@@deriving lens]

type meta = {
    title: string;
    author: author;
    date: date;
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
    date = { edited = None; published = None };
    categories = []; topics = []; keywords = []; series = [];
    abstract = ""
  }

let blank_ymd =
  { meta = blank_meta; body = "" }

let load_file f =
  let ic = open_in f in
  let n = in_channel_length ic in
  let s = Bytes.create n in
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
  let open Lens.Infix in
  let field_map meta (k,v) = match k with
    | "title" -> { meta with title = v }
    | "abstract" -> { meta with abstract = v }
    | "published" -> ((meta_date |-- date_published) ^=
                        (match Ptime.of_rfc3339 v with Ok (t,_,_) -> Some t | Error _ -> None )) meta
    | _ -> meta
  in
  List.fold_left field_map blank_meta fields

let of_file s =
  let segments = bounded_split (regexp "^---$") (load_file s) 3 in
  let yaml_str = List.nth segments 0 in
  let md_str = List.nth segments 1 in
  let m = meta_of_yaml yaml_str in
  { meta = m; body = md_str }

let to_string ymd =
  let buf = Buffer.create (String.length ymd.body + 256) in
  let buf_acc = Buffer.add_string buf in
  let str_of_ptime time = match time with
    | Some t -> Ptime.to_rfc3339 t | None -> "" in
  List.map buf_acc [
             "---\n";
             "title: ";   ymd.meta.title;
             "\nauthors:";
             "\n- name: ";  ymd.meta.author.name;
             "\n  email: "; ymd.meta.author.email;
             "\ndate:";
             "\n  edited: ";    str_of_ptime ymd.meta.date.edited;
             "\n  published: "; str_of_ptime ymd.meta.date.published;
             "\ncategories: ";  String.concat ", " ymd.meta.categories;
             "\ntopics: "; String.concat ", " ymd.meta.topics;
             "\n---\n"; ymd.body;
           ];
  Buffer.contents buf


let titles () =
  let ymds = Array.to_list @@ Sys.readdir "ymd/" in
  let t y = (of_file ("ymd/" ^ y)).meta.title in
  List.map t ymds
