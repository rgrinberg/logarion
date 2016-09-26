OCB_FLAGS = -use-ocamlfind -I src # -I lib
OCB       = ocamlbuild $(OCB_FLAGS)

all: web

web:
	$(OCB) web.native -pkgs opium.unix,omd,str,batteries,tyxml,lens,ptime,ptime.clock.os,re.str,lens.ppx_deriving
	mv web.native web


clean:
	$(OCB) -clean
	rm -f src/*.{cmx,cmi,o} *.{cmx,cmi,o}
