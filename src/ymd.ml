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

let blank_meta = {
    title = "";
    author = { name = ""; email = "" };
    date = { edited = None; published = None };
    categories = []; topics = []; keywords = []; series = [];
    abstract = ""
  }

let blank_ymd = { meta = blank_meta; body = "" }

let rfc_string_of date = match date with
    Some t -> Ptime.to_rfc3339 t | None -> "";;
let date_of (rfc : string) = match Ptime.of_rfc3339 rfc with
    Ok (t,_,_) -> Some t | Error _ -> None;;

let date_string ymd = match ymd.meta.date.published with
    Some t -> Some t | None -> ymd.meta.date.edited

let trim_str v = v |> String.trim
let list_of_csv = Re_str.(split (regexp " *, *"))
let of_str y k v = Lens.Infix.(k ^= trim_str v) y
let of_str_list y k v = Lens.Infix.(k ^= list_of_csv (trim_str v)) y

let filename_of_title t =
  let sub c = match c with ' ' -> '_' | '/' -> '-' | c -> c in
  String.map sub t ^ ".ymd"

let filename ymd = filename_of_title ymd.meta.title

let with_meta_kv meta (k,v) =
  let open Lens.Infix in
  match k with
  | "title"     -> of_str meta (meta_title) v
  | "name"      -> of_str meta (meta_author |-- author_name ) v
  | "email"     -> of_str meta (meta_author |-- author_email) v
  | "abstract"  -> of_str meta meta_abstract v
  | "published" -> ((meta_date |-- date_published) ^= date_of v) meta
  | "edited"    -> ((meta_date |-- date_edited   ) ^= date_of v) meta
  | "topics"    -> of_str_list meta meta_topics v
  | "keywords"  -> of_str_list meta meta_keywords v
  | "categories"-> of_str_list meta meta_categories v
  | "series"    -> of_str_list meta meta_series v
  | _ -> meta

let with_kv ymd (k,v) =
  let open Lens.Infix in
  match k with
  | "body" -> of_str ymd (ymd_body) v
  | _      -> { ymd with meta = with_meta_kv ymd.meta (k,v) }

let meta_pair_of_string line =
  let e = Re_str.(bounded_split (regexp ": *")) line 2 in
  if List.length e = 2
  then (Re_str.(replace_first (regexp "^[ -] ") "" (List.nth e 0)), List.nth e 1)
  else (Re_str.(replace_first (regexp "^[ -] ") "" line), "")

let meta_of_yaml yaml =
  let fields = List.map meta_pair_of_string (BatString.nsplit yaml "\n") in
  let open Lens.Infix in
  List.fold_left with_meta_kv blank_meta fields

let of_string s =
  let segments = Re_str.(split (regexp "^---$")) s in
  if List.length segments = 2 then
    let yaml_str = List.nth segments 0 in
    let md_str = List.nth segments 1 in
    let m = meta_of_yaml yaml_str in
    { meta = m; body = md_str }
  else
    { blank_ymd with body = "Error parsing file" }
                 
let to_string ymd =
  let buf = Buffer.create (String.length ymd.body + 256) in
  let buf_acc = Buffer.add_string buf in
  let str_of_ptime time = match time with
    | Some t -> Ptime.to_rfc3339 t | None -> "" in
  List.iter buf_acc [
              "---\n";
              "title: ";   ymd.meta.title;
              "\nauthors:";
              "\n- name: ";  ymd.meta.author.name;
              "\n  email: "; ymd.meta.author.email;
              "\ndate:";
              "\n  edited: ";    str_of_ptime ymd.meta.date.edited;
              "\n  published: "; str_of_ptime ymd.meta.date.published;
              "\ntopics: ";     String.concat ", " ymd.meta.topics;
              "\ncategories: "; String.concat ", " ymd.meta.categories;
              "\nkeywords: ";   String.concat ", " ymd.meta.keywords;
              "\nseries: ";     String.concat ", " ymd.meta.series;
              "\nabstract: ";   ymd.meta.abstract;
              "\n---\n"; ymd.body;
            ];
  Buffer.contents buf
