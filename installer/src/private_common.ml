open Dkml_package_console_common

let organization =
  {
    Author_types.legal_name = "Diskuv, Inc.";
    common_name_full = "Diskuv";
    common_name_camel_case_nospaces = "Diskuv";
    common_name_kebab_lower_case = "diskuv";
  }

let program_name =
  {
    Author_types.name_full = "opam";
    name_camel_case_nospaces = "opam";
    name_kebab_lower_case = "opam";
    installation_prefix_camel_case_nospaces_opt = None;
    installation_prefix_kebab_lower_case_opt = None;
  }

let program_version = Opam_to_semver.to_semver Version.program_version

(* From ocaml-crunch defined in ./dune.

   Which comes from https://github.com/ocaml/ocaml-logo/tree/master/Colour/Favicon
*)
let program_assets =
  { Author_types.logo_icon_32x32_opt = Assets.read "32x32-win32-icon.ico" }

let program_info =
  {
    Author_types.url_info_about_opt =
      Some "https://github.com/diskuv/dkml-installer-opam#readme";
    url_update_info_opt =
      Some "https://github.com/diskuv/dkml-component-opam/blob/main/CHANGES.md";
    help_link_opt = Some "https://opam.ocaml.org/";
    (*
        45 MB in DKML 1.0.2
      - "{0} B" -f (Get-ChildItem $env:LOCALAPPDATA\Programs\opam -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum
     *)
    estimated_byte_size_opt = Some 45_861_428L;
    windows_language_code_id_opt = Some 0x00000409;
    embeds_32bit_uninstaller = true;
    embeds_64bit_uninstaller = true;
  }
