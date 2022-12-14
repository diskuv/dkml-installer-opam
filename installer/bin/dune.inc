; Auto-generated by dune-of-installer-generator.exe.
; Do not edit unless need to regenerate!
; When regenerating, erase **all** content from this file, save the file, and then run:
;   dune clean
;   dune build installer/bin/dune.inc --auto-promote
(executable (name discover) (libraries dune.configurator bos fpath)
 (modules discover))

(rule
 (targets admin-link-flags.sexp user-link-flags.sexp console-link-flags.sexp)
 (deps (:discover discover.exe) entry-application.manifest
  entry.assembly.manifest)
 (action (run %{discover})))

(executable (public_name dkml-install-user-runner) (name runner_user)
 (modules runner_user) (ocamlopt_flags (:include user-link-flags.sexp))
 (libraries dkml-install-runner.user private_common
  dkml-component-offline-opam dkml-component-staging-ocamlrun
  dkml-component-staging-opam32 dkml-component-staging-opam64))

(executable (public_name dkml-install-admin-runner) (name runner_admin)
 (modules runner_admin) (ocamlopt_flags (:include admin-link-flags.sexp))
 (libraries dkml-install-runner.admin private_common
  dkml-component-offline-opam dkml-component-staging-ocamlrun
  dkml-component-staging-opam32 dkml-component-staging-opam64))

(executable (public_name dkml-install-create-installers)
 (name create_installers)
 (libraries dkml-package-console.create cmdliner private_common
  dkml-component-offline-opam dkml-component-staging-ocamlrun
  dkml-component-staging-opam32 dkml-component-staging-opam64)
 (modules create_installers))

(executable (public_name dkml-install-package-install) (name entry_install)
 (libraries dkml-package-console.entry cmdliner private_common
  dkml-component-offline-opam dkml-component-staging-ocamlrun
  dkml-component-staging-opam32 dkml-component-staging-opam64)
 (modules entry_install) (ocamlopt_flags (:include console-link-flags.sexp)))

(executable (public_name dkml-install-package-uninstall)
 (name entry_uninstall)
 (libraries dkml-package-console.entry cmdliner private_common
  dkml-component-offline-opam dkml-component-staging-ocamlrun
  dkml-component-staging-opam32 dkml-component-staging-opam64)
 (modules entry_uninstall)
 (ocamlopt_flags (:include console-link-flags.sexp)))

(executable (name entry_assembly_manifest)
 (libraries dkml-package-console.common private_common fmt)
 (modules entry_assembly_manifest))

(rule (target entry.assembly.manifest)
 (action (with-stdout-to %{target} (run %{exe:entry_assembly_manifest.exe}))))

(executable (name package_setup) (modes (byte exe))
 (libraries dkml-package-console.setup cmdliner private_common
  dkml-component-offline-opam dkml-component-staging-ocamlrun
  dkml-component-staging-opam32 dkml-component-staging-opam64)
 (modules package_setup))

(executable (name package_uninstaller) (modes (byte exe))
 (libraries dkml-package-console.uninstaller cmdliner private_common
  dkml-component-offline-opam dkml-component-staging-ocamlrun
  dkml-component-staging-opam32 dkml-component-staging-opam64)
 (modules package_uninstaller))

(install (section bin)
 (files (package_setup.bc as dkml-install-package-setup.bc)
  (package_uninstaller.bc as dkml-install-package-uninstaller.bc)))

(rule (alias runtest)
 (deps (:ps package_setup.bc) (:pu package_uninstaller.bc))
 (action
  (progn (with-stdout-to package_setup.info.txt (run ocamlobjinfo %{ps}))
   (with-stdout-to package_uninstaller.info.txt (run ocamlobjinfo %{pu}))
   (with-stdout-to dlls.corrected.txt
    (progn
     (run awk
      "/.*:/ {x=0} /Used DLLs:/{x=1; $1=\"package_setup.bc Used\"} x==1 {print}"
      package_setup.info.txt)
     (run awk
      "/.*:/ {x=0} /Used DLLs:/{x=1; $1=\"package_uninstaller.bc Used\"} x==1 {print}"
      package_uninstaller.info.txt)))
   (diff? dlls.txt dlls.corrected.txt))))
