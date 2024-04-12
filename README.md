# DkML installer for Opam

An installer for Opam.

The installer is an _offline_ installer, meaning it is fully self-contained.
However on Windows `opam` by itself is not very useful! The base OCaml compiler
package, for example, requires a POSIX shell from MSYS2 or Cygwin.

For 2022 and 2023 you should expect to need the `dkml-installer-ocaml` installer
as well to provide the missing pieces.

## Making a new version

> The following assumes you have a Unix shell. On Windows with DkML installed you can use `with-dkml bash` to get one.

> We won't be using code-signing for this section, although that is documented in [BINARY_SIGNING.md](contributors/BINARY_SIGNING.md).

1. Ensure you have cloned https://github.com/diskuv/dkml-component-opam.git in a sibling directory to this `dkml-installer-opam/` project. So your directory structure should look like:
   ```

    ├── dkml-component-opam
    │   ├── ...
    │   └── dune-project
    ├── dkml-installer-opam
        ├── ...
        └── dune-project
   ```
2. Follow [dkml-component-opam's "Making a new version"](https://github.com/diskuv/dkml-component-opam?tab=readme-ov-file#making-a-new-version)
3. Edit the `(version ...)` in [dune-project](./dune-project). Use the same version as you used in `dkml-component-opam`.
4. Edit the `--program-version` in [dkml-installer-offline-opam.opam.template](./dkml-installer-offline-opam.opam.template). Use the hyphenated version, not the opam version. So replace `~` with `-`.
5. Edit the `arp_version` in [version.ml](installer/src/version.ml). It should be the hyphenated version **and should not include the date** since this is highly visible to the user. So `2.2.0-beta2` not `2.2.0-beta2-20240409` if you are publishing a beta release. **It is not recommended to publish a beta release to winget; all new users would get the beta version**.
6. Do the following in `dkml-installer-opam/`:

   ```sh
   eval $(opam env --switch ../dkml-component-opam --set-switch)

   opam exec -- dune build *.opam
   opam exec -- dune runtest
   git add dune-project *.opam dkml-installer-offline-opam.opam.template installer/src/version.ml
   git commit -m "Prepare new version (1/2)"

   opam remove dkml-installer-offline-opam -y
   opam install ./dkml-installer-offline-opam.opam --keep-build-dir

   # See the OS-specific installer or installer generator script.
   # macOS ARM64 is not part of DkML opam distribution.
   find "$(opam var dkml-installer-offline-opam:share)/t"
   ```
7. Do:

   ```sh
   # 2.2.0~beta2~20240409 is tagged as 2.2.0-beta2-20240409
   tagversion=$(awk '/\(version / { sub(/)/, ""); gsub(/~/, "-"); print $2 }' dune-project)
   git tag "$tagversion"
   git push origin "$tagversion"
   ```

   and wait for GitHub Actions to complete successfully.
8. In the `installer/winget/manifest` directory search for all `# BUMP` in the `.yaml` files and edit each line.
   - The `PackageVersion` in all `.yaml` files should be set to the ARP version that has **no date** (you set this in Step 5).
9.  Do the [winget Testing instructions](installer/winget/README.md#testing).
10. Do the following in `dkml-installer-opam/`:

   ```sh
   git add installer/winget/manifest
   git commit -m "Prepare new version (2/2)"

   tagversion=$(awk '/\(version / { sub(/)/, ""); gsub(/~/, "-"); print $2 }' dune-project)
   git tag "$tagversion+winget"
   git push origin "$tagversion+winget"
   ```
11. Do the [winget Submitting instructions](installer/winget/README.md#submitting).

> See the suggestions in https://github.com/diskuv/dkml-installer-opam/issues/1 for automating these
> steps.

## (Pending) Developing

You can test on your desktop with a shell session as follows:

```console
# For macOS/Intel (darwin_x86_64)
$ sh ci/setup-dkml/pc/setup-dkml-darwin_x86_64.sh --SECONDARY_SWITCH=true
# For Linux/Intel (linux_x86_64). You will need Docker
#   - Running this from macOS with Docker will also work
#   - Running this using with-dkml.exe on Windows with Docker will also work
#     (the normal Linux containers host, not the Windows containers host)
$ sh ci/setup-dkml/pc/setup-dkml-linux_x86_64.sh --SECONDARY_SWITCH=true
...
Finished setup.

To continue your testing, run:
  export dkml_host_abi='darwin_x86_64'
  export abi_pattern='macos-darwin_all'
  export opam_root='/Volumes/Source/dkml-component-desktop/.ci/o'
  export exe_ext=''

Now you can use 'opamrun' to do opam commands like:

  opamrun install XYZ.opam
  sh ci/build-test.sh

# Copy and adapt from above (the text above will be different for each of: Linux, macOS and Windows)
$ export dkml_host_abi='darwin_x86_64'
$ export abi_pattern='macos-darwin_all'
$ export opam_root="$PWD/.ci/o"
$ export exe_ext=''

# Run the build
#   The first argument is: 'ci' or 'full'
#   The second argument is: 'release' or 'next'
$ sh ci/build-test.sh ci next
```

## (Pending) Upgrading CI

```bash
opam upgrade dkml-workflows && opam exec -- generate-setup-dkml-scaffold && dune build '@gen-dkml' --auto-promote
```

## Contributing

The installer makes heavy use of the dkml-install-api.
See [the Contributors section of dkml-install-api](https://github.com/diskuv/dkml-install-api/blob/main/contributors/README.md).

Any new dkml-components used by this installer will need an access token
(`repo public_repo`)
to automatically trigger builds, which you'll save as a repository secret
in your component. Create an issue to get access if you have a new
component that you would like to get distributed.

In addition, there are

* [code signing documents](contributors/BINARY_SIGNING.md)
* [winget package submission documents](installer/winget/README.md)

## Status

| What                   | Branch/Tag | Status                                                                                                                                                                                          |
| ---------------------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Installer packages     |            | [![Package OCaml Releases](https://github.com/diskuv/dkml-installer-opam/actions/workflows/package.yml/badge.svg)](https://github.com/diskuv/dkml-installer-opam/actions/workflows/package.yml) |
| Installer syntax check |            | [![Syntax check](https://github.com/diskuv/dkml-installer-opam/actions/workflows/syntax.yml/badge.svg)](https://github.com/diskuv/dkml-installer-opam/actions/workflows/syntax.yml)             |
