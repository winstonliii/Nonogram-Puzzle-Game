(lang dune 3.16)
(name nonogram_web)

(generate_opam_files true)
(authors "Paul Wisner" "Winston Li" "Reena Assassa")
(maintainers "rassass1@jhu.edu, wli111@jhu.edu, pwisner2@jhu.edu")

(package
 (name nonogram_web)
 (allow_empty)
 (synopsis "A web based Nonogram puzzle game in OCaml")
 (description "A Dream based web UI for playing generated Nonogram puzzles, with a solver and validator library.")
 (depends
  (dune (>= 3.16))
  (core (>= 0.17.1))
  (dream (>= 1.0.0~alpha7))
  (ounit2 (>= 2.2.7))
 ))
