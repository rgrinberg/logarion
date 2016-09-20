open Tyxml.Html

let logarion_head ?(style="/style.css") t =
  head (title (pcdata t)) [link ~rel:[`Stylesheet] ~href:"/style.css" ()]
       
let html_of ymd =
  let ymd_title = Logarion.(ymd.meta.title) in
  let ymd_date = match Logarion.(ymd.meta.date.published) with
    | Some t -> Some t
    | None -> Logarion.(ymd.meta.date.edited) in
  let ymd_body = Omd.to_html (Omd.of_string Logarion.(ymd.body)) in
  html (logarion_head ymd_title)
       (body [
            header [
                h1 [Unsafe.data ymd_title];
                details
                  (summary [Unsafe.data Logarion.(ymd.meta.abstract)])
                  [time ~a:[a_datetime (Logarion.(to_rfc ymd_date))] []];
              ];
            Unsafe.data ymd_body;
            footer [p []];
       ])
  |> Format.asprintf "%a" (Tyxml.Html.pp ())

let html_of_titles titles =
  let link_item x = li [a ~a:[a_href ("/" ^ x)] [Unsafe.data x]] in
  html (logarion_head "Homepage")
       (body [
            header [ h1 [pcdata "Homepage"] ];
            div [
                h2 [pcdata "Articles"];
                ul (List.map link_item titles);
              ];
       ])
  |> Format.asprintf "%a" (Tyxml.Html.pp ())

let html_of_form ymd =
  let input_set t n =
    p [ label [
            span [pcdata t];
            input ~a:[a_name n] ()
      ]]
  in
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
                        input_set "Title" "title";
                        input_set "Author name" "author_name";
                        input_set "Author email" "author_email";
                        input_set "Topics" "topics";
                        input_set "Categories" "categories";
                        input_set "Keywords" "keywords";
                        input_set "Series" "series";
                        input_set "Abstract" "abstract";
                        p [
                            label [
                                span [pcdata"Text"];
                                textarea ~a:[a_name "text"] (pcdata "");
                              ];
                          ];
                        p [ button ~a:[a_button_type `Submit] [pcdata "Submit"] ];
                      ]
                  ]
              ];
       ])
  |> Format.asprintf "%a" (Tyxml.Html.pp ())
