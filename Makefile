
all: web

web: logarion.cmx html.cmx src/web.ml
	ocamlfind ocamlopt -o logarion-web -linkpkg \
	-package opium.unix,omd,str,tyxml,lens,ptime,ptime.clock.os \
	logarion.cmx html.cmx src/web.ml

html.cmx: src/html.ml logarion.cmx
	ocamlfind ocamlopt -c -o html.cmx -linkpkg \
	-package omd,tyxml \
	logarion.cmx src/html.ml

logarion.cmx: src/logarion.ml
	ocamlfind ocamlopt -c -o logarion.cmx -linkpkg \
	-package omd,lens,lens.ppx_deriving,ptime \
	src/logarion.ml
