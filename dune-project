(lang dune 2.9)

(name dkml-installer-offline-opam)
(version 2.2.0)

(generate_opam_files true)

(source
 (github diskuv/dkml-installer-opam))
(license Apache-2.0)
(authors "Diskuv, Inc. <opensource+dkml@support.diskuv.com>")
(maintainers "opensource+dkml@support.diskuv.com")

(package
 (name dkml-installer-offline-opam)
 (synopsis "DkML installer generator for Opam")
 (description "The DkML Installer for Opam generates installers for Opam.

The package version, and what [opam --version] returns, are closely associated with the Opam version from the Opam
source code. The only modifications are to ensure that the package version can be ordered using semver. In particular:

* 2.2.0~alpha~dev -> 2.2.0~alpha0~20221231
* 2.2.0~alpha~1   -> 2.2.0~alpha1~20230601
* 2.2.0           -> 2.2.0

The dates (YYYYMMDD) are the Git commit dates in the Opam source code, and simply replacing the tildes (~) with dashes (-) is
sufficient to be a semver version.
")
 (depends
  (odoc                                   (and (>= 1.5.3) :with-doc))
  (dune                                   (>= 2.9.3))
  ocaml
  dkml-component-offline-opam
  (dkml-install-installer                 (>= 0.3.0))
  (dkml-package-console                   (>= 0.2.0))
  (crunch                                 (>= 3.3.1))
  (alcotest                               (and (>= 1.4.0) :with-test))))
