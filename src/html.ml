let html_of ymd =
  let ymd_title = ymd.Logarion.meta.title in
  let ymd_body = Omd.to_html (Omd.of_string ymd.Logarion.text) in
  let open Tyxml.Html in
  let tyhtml =
    html
      (head
         (title (Unsafe.data ymd_title))
         [link ~rel:[`Stylesheet] ~href:"style.css" ();]
      )
      (body [
           header [
               h1 [Unsafe.data ymd_title];
               details (summary [Unsafe.data ymd.Logarion.meta.abstract]) [];
             ];
           Unsafe.data ymd_body;
           footer [p []];
      ])
  in
  Format.asprintf "%a" (Tyxml.Html.pp ()) tyhtml

let html_of_titles titles =
  let open Tyxml.Html in
  let link_item x = li [a ~a:[a_href ("/" ^ x)] [Unsafe.data x]] in
  let tyhtml =
    html
      (head
         (title (pcdata "Homepage"))
         [link ~rel:[`Stylesheet] ~href:"style.css" ();]
      )
      (body [
           header [
               h1 [pcdata "Homepage"];
             ];
           div [
               h2 [pcdata "Articles"];
               ul (List.map link_item titles);
             ];
      ])
  in
  Format.asprintf "%a" (Tyxml.Html.pp ()) tyhtml
