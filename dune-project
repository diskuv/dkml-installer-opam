(lang dune 2.9)

(name dkml-installer-offline-opam)
(version 2.2.0~alpha0~20221228)

(generate_opam_files true)

(source
 (github diskuv/dkml-installer-opam))
(license Apache-2.0)
(authors "Diskuv, Inc. <opensource+diskuv-ocaml@support.diskuv.com>")
(maintainers "opensource+diskuv-ocaml@support.diskuv.com")

(package
 (name dkml-installer-offline-opam)
 (synopsis "DKML installer generator for Opam")
 (description "The DKML Installer for Opam generates installers for Opam.

 The package version, and what [opam --version] returns, are closely associated with the Opam version from the Opam
source code. The only modifications are to ensure that the package version can be ordered using semver. In particular:

* 2.2.0~alpha~dev -> 2.2.0~alpha0~20221231
* 2.2.0~alpha~1   -> 2.2.0~alpha1~20230601
* 2.2.0           -> 2.2.0

The dates (YYYYMMDD) are the Git commit dates in the Opam source code, and simply replacing the tildes (~) with dashes (-) is
sufficient to be a semver version.

Includes a patch to distinguish MSYS2 from Cygwin, esp. for rsync rather than symlinking which is needed on MSYS2.
")
 (depends
  (odoc                                   (and (>= 1.5.3) :with-doc))
  (dune                                   (and (>= 2.9.3) (< 2.9.4~)))
  (dune-configurator                      (= 2.9.3))
  (ocaml                                  (= 4.12.1))
  (dkml-component-offline-opam            (= 2.2.0~alpha0~20221228))
  (dkml-install-installer                 (>= 0.3.0))
  (dkml-package-console                   (>= 0.2.0))
  (crunch                                 (>= 3.3.1))
  (alcotest                               (and (>= 1.4.0) :with-test))))
