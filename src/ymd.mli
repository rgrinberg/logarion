(** Functions for Yamado (.ymd) text files *)

type author = {
    name : string;
    email : string;
  }
type date = {
    edited : Ptime.t option;
    published : Ptime.t option;
  }
type meta = {
    title : string;
    author : author;
    date : date;
    categories : string list;
    topics : string list;
    keywords : string list;
    series : string list;
    abstract : string;
  }
type ymd = { meta : meta; body : string; }

val blank_meta : meta
(** an empty [meta] *)

val blank_ymd : ymd
(** an empty [ymd] *)

val filename_of_title : string -> string
(** get how a file should be named according to a title [string] *)

val filename : ymd -> string
(** get how a file should be named based on a [ymd] value *)

(** {1 Conversions from and to string} *)

val of_string : string -> ymd
(** convert a string containing a ymd buffer to [ymd] *)

val to_string : ymd -> string
(** convert a ymd to a [string] *)

val meta_of_yaml : string -> meta
(** a [meta] record from a YAML string *)

val with_kv : ymd -> string * string -> ymd
(** [with_kv ymd (key,value)] returns a [ymd] record based on ymd, but with key field, set to value. *)

val trim_str : string -> string
val list_of_csv : string -> string list
val of_str : 'a -> ('a, string) Lens.t -> string -> 'a
val of_str_list : 'a -> ('a, string list) Lens.t -> string -> 'a

val meta_pair_of_string : string -> string * string
val with_meta_kv : meta -> string * string -> meta

(** {1 Conversions from and to date} *)

val rfc_string_of : Ptime.t option -> string
val date_of : string -> Ptime.t option
val date_string : ymd -> Ptime.t option
                                                                
(** {1 Lenses for accessing [ymd] record fields} *)

val author_name : (author, string) Lens.t
val author_email : (author, string) Lens.t
val date_edited : (date, Ptime.t option) Lens.t
val date_published : (date, Ptime.t option) Lens.t
val meta_title : (meta, string) Lens.t
val meta_author : (meta, author) Lens.t
val meta_date : (meta, date) Lens.t
val meta_categories : (meta, string list) Lens.t
val meta_topics : (meta, string list) Lens.t
val meta_keywords : (meta, string list) Lens.t
val meta_series : (meta, string list) Lens.t
val meta_abstract : (meta, string) Lens.t
val ymd_meta : (ymd, meta) Lens.t
val ymd_body : (ymd, string) Lens.t
