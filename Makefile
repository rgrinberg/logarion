
all: web

web: logarion.cmx html.cmx ymd.cmx src/web.ml
	ocamlfind ocamlopt -o logarion-web -linkpkg \
	-package opium.unix,omd,str,batteries,tyxml,lens,ptime,ptime.clock.os,re.str \
	ymd.cmx logarion.cmx html.cmx src/web.ml

html.cmx: src/html.ml logarion.cmx
	ocamlfind ocamlopt -c -o html.cmx -linkpkg \
	-package omd,tyxml \
	logarion.cmx src/html.ml

logarion.cmx: src/logarion.ml ymd.cmx
	ocamlfind ocamlopt -c -o logarion.cmx -linkpkg \
	-package batteries,re \
	ymd.cmx src/logarion.ml

ymd.cmx: src/ymd.ml
	ocamlfind ocamlopt -c -o ymd.cmx -linkpkg \
	-package batteries,omd,lens,lens.ppx_deriving,ptime,re \
	src/ymd.ml

clean:
	rm -f src/*.{cmx,cmi,o} *.{cmx,cmi,o}
