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

let to_rfc v = match v with Some t -> Ptime.to_rfc3339 t | None -> "";;
let of_rfc v = match Ptime.of_rfc3339 v with Ok (t,_,_) -> Some t | Error _ -> None;;
let trim_str v = v |> String.trim
let list_of_csv = Re_str.(split (regexp " *, *"))
let of_str y k v = Lens.Infix.(k ^= trim_str v) y
let of_str_list y k v = Lens.Infix.(k ^= list_of_csv (trim_str v)) y

let meta_field line =
  let e = Re_str.(bounded_split (regexp ": *")) line 2 in
  if List.length e = 2
  then (Re_str.(replace_first (regexp "^[ -] ") "" (List.nth e 0)), List.nth e 1)
  else (Re_str.(replace_first (regexp "^[ -] ") "" line), "")

let meta_of_yaml yaml =
  let fields = List.map meta_field (BatString.nsplit yaml "\n") in
  let open Lens.Infix in
  let field_map meta (k,v) = match k with
    | "title"     -> of_str meta (meta_title) v
    | "name"      -> of_str meta (meta_author |-- author_name ) v
    | "email"     -> of_str meta (meta_author |-- author_email) v
    | "abstract"  -> of_str meta meta_abstract v
    | "published" -> ((meta_date |-- date_published) ^= of_rfc v) meta
    | "edited"    -> ((meta_date |-- date_edited   ) ^= of_rfc v) meta
    | "topics"    -> of_str_list meta meta_topics v
    | "keywords"  -> of_str_list meta meta_keywords v
    | "categories"-> of_str_list meta meta_categories v
    | "series"    -> of_str_list meta meta_series v
    | _ -> meta
  in
  List.fold_left field_map blank_meta fields

let of_file s =
  let segments = Re_str.(split (regexp "^---$")) (load_file s) in
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
             "\nabstract: ";   ymd.meta.abstract;
             "\n---\n"; ymd.body;
           ];
  Buffer.contents buf

let titles () =
  let files = Array.to_list @@ Sys.readdir "ymd/" in
  let ymds = List.fold_left
               (fun a e -> if BatString.ends_with e ".ymd" then List.cons e a else a)
               []
               files in
  let t y = (of_file ("ymd/" ^ y)).meta.title in
  List.map t ymds
