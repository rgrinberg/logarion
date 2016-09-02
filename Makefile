
all: web

web: logarion.cmx src/web.ml
	ocamlfind ocamlopt -o logarion-web -linkpkg -package opium.unix,omd,Str logarion.cmx src/web.ml

logarion.cmx: src/logarion.ml
	ocamlfind ocamlopt -c -o logarion.cmx -linkpkg -package omd src/logarion.ml
