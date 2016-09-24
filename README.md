# Logarion

## Install

Make sure you have OCaml >= 4.03.

    opam install batteries lens ppx_deriving omd opium tyxml ptime re
    git clone git@github.com:orbifx/logarion.git
    cd logarion
    make

This should generate `logarion-web`. Run with:

    logarion-web

and open a browser to <http://localhost:3000>.
To post a new article visit <http://localhost:3000/()/new>.

## Summary

A Yamado archive publisher.

Focuses on:

1. System simplicity by delegating all functionality but parsing Yamado archives and generating outputs.
   Where possible it can compose with other programs (e.g. Pandoc).
2. Output quality
3. Distributed interactivity, like sharing with friends.

_YMD_ files can be stored internally and controlled by Logarion, or they can be piped from other sources.

Logarion can be used in two modes:

- Static, published upon a command

  Suitable for situations where installation on the server is not possible.
  Has the limitation that it can only output specific output once.

- Dynamic, published upon request according to query 
  
  Supports interactive features like searching and more advanced Atom feed parameters.

## Requirements

- [omd](https://github.com/ocaml/omd

## See also

- [CONTRIBUTING.md](CONTRIBUTING.md)
