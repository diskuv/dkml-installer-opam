(lang dune 2.9)

(name dkml-installer-offline-opam)
(version 1.0.1)

(generate_opam_files true)

(source
 (github diskuv/dkml-installer-opam))
(license Apache-2.0)
(authors "Diskuv, Inc. <opensource+diskuv-ocaml@support.diskuv.com>")
(maintainers "opensource+diskuv-ocaml@support.diskuv.com")

(package
 (name dkml-installer-offline-opam)
 (synopsis "DKML installer generator for Opam")
 (description "The DKML Installer for Opam generates installers for Opam")
 (depends
  (odoc                                   (and (>= 1.5.3) :with-doc))
  (dune                                   (and (>= 2.9.3) (< 2.9.4~)))
  (dune-configurator                      (= 2.9.3))
  (ocaml                                  (= 4.12.1))
  (dkml-component-offline-opam            (>= 2.2.0~alpha~20221104))
  (dkml-install-installer                 (>= 0.2.0))
  (dkml-package-console                   (>= 0.2.0))
  (crunch                                 (>= 3.2.0))
  (alcotest                               (and (>= 1.4.0) :with-test))))
