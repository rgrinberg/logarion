# Contributing to Logarion

There are three layers: the YMD format, the repository system, and the outlets.

    ymd.ml <--> logarion.ml <--> intermediate formats <--> programs

### Core

- `src/ymd.ml`: parsing from and to YMD files.
- `src/logarion.ml`: repository related functions (listing, adding/removing, etc).

### Intermediate formats

- `src/html.ml`: conversions of articles and listings to HTML pages

### Interfaces

- `src/web.ml`: a program for accessing logarion over HTTP
