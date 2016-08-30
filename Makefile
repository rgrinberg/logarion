
all: foo

foo: src/logarion.ml
	ocamlfind ocamlopt -o logarion -linkpkg -package omd,Str src/logarion.ml
