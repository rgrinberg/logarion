open Tyxml.Html

let logarion_head ?(style="/style.css") t =
  head (title (pcdata t)) [link ~rel:[`Stylesheet] ~href:"/style.css" ()]
       
let of_ymd ymd =
  let ymd_title = Ymd.(ymd.meta.title) in
  let ymd_body = Omd.to_html (Omd.of_string Ymd.(ymd.body)) in
  html (logarion_head ymd_title)
       (body [
            header [
                h1 [Unsafe.data ymd_title];
                details
                  (summary [Unsafe.data Ymd.(ymd.meta.abstract)])
                  [time ~a:[a_datetime (Ymd.(rfc_string_of ymd.meta.date.published))] []];
              ];
            Unsafe.data ymd_body;
            footer [p []];
       ])
  |> Format.asprintf "%a" (Tyxml.Html.pp ())

let of_titled_files titles =
  let link_item (y,t) = li [a ~a:[a_href ("/" ^ Filename.chop_extension y)] [Unsafe.data t]] in
  html (logarion_head "Homepage")
       (body [
            header [ h1 [pcdata "Homepage"] ];
            div [
                h2 [pcdata "Articles"];
                ul (List.map link_item titles);
              ];
       ])
  |> Format.asprintf "%a" (Tyxml.Html.pp ())

let form ymd =
  let input_set title name value =
    p [ label [
            span [pcdata title];
            input ~a:[a_name name; a_value value] ()
      ]]
  in
  let open Ymd in
  html (logarion_head "Compose")
       (body [
            header [ h1 [pcdata "Create new article"] ];
            div [
                form
                  ~a:[a_method `Post; a_action (uri_of_string "/()/new")]
                  [
                    fieldset
                      ~legend:(legend [pcdata "Create new article"])
                      [
                        input_set "Title" "title" ymd.meta.title;
                        input_set "Author name" "author_name" ymd.meta.author.name;
                        input_set "Author email" "author_email" ymd.meta.author.email;
                        input_set "Topics" "topics" (String.concat ", " ymd.meta.topics);
                        input_set "Categories" "categories" (String.concat ", " ymd.meta.categories);
                        input_set "Keywords" "keywords" (String.concat ", " ymd.meta.keywords);
                        input_set "Series" "series" (String.concat ", " ymd.meta.series);
                        input_set "Abstract" "abstract" ymd.meta.abstract;
                        p [
                            label [
                                span [pcdata"Text"];
                                textarea ~a:[a_name "body"] (pcdata "");
                              ];
                          ];
                        p [ button ~a:[a_button_type `Submit] [pcdata "Submit"] ];
                      ]
                  ]
              ];
       ])
  |> Format.asprintf "%a" (Tyxml.Html.pp ())
