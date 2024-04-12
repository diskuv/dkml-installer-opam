#!/bin/sh
##########################################################################
# File: dktool/cmake/scripts/dkml/workflow/compilers-build-test.in.sh    #
#                                                                        #
# Copyright 2022 Diskuv, Inc.                                            #
#                                                                        #
# Licensed under the Apache License, Version 2.0 (the "License");        #
# you may not use this file except in compliance with the License.       #
# You may obtain a copy of the License at                                #
#                                                                        #
#     http://www.apache.org/licenses/LICENSE-2.0                         #
#                                                                        #
# Unless required by applicable law or agreed to in writing, software    #
# distributed under the License is distributed on an "AS IS" BASIS,      #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or        #
# implied. See the License for the specific language governing           #
# permissions and limitations under the License.                         #
#                                                                        #
##########################################################################

# Updating
# --------
#
# 1. Delete this file.
# 2. Run dk with your original arguments:
#        ./dk dkml.workflow.compilers CI GitHub Desktop
#    or get help to come up with new arguments:
#        ./dk dkml.workflow.compilers HELP

set -euf

# Set project directory
if [ -n "${CI_PROJECT_DIR:-}" ]; then
    PROJECT_DIR="$CI_PROJECT_DIR"
elif [ -n "${PC_PROJECT_DIR:-}" ]; then
    PROJECT_DIR="$PC_PROJECT_DIR"
elif [ -n "${GITHUB_WORKSPACE:-}" ]; then
    PROJECT_DIR="$GITHUB_WORKSPACE"
else
    PROJECT_DIR="$PWD"
fi
if [ -x /usr/bin/cygpath ]; then
    PROJECT_DIR=$(/usr/bin/cygpath -au "$PROJECT_DIR")
fi

# Constants
OPAM_PACKAGE=dkml-installer-offline-opam
PROGRAM_NAME_KEBAB=opam

# shellcheck disable=SC2154
echo "
=============
build-test.sh
=============
.
---------
Arguments
---------
$*
.
------
Matrix
------
dkml_host_abi=$dkml_host_abi
abi_pattern=$abi_pattern
opam_root=$opam_root
exe_ext=${exe_ext:-}
bits=$bits
.
---------
Constants
---------
OPAM_PACKAGE=$OPAM_PACKAGE
PROGRAM_NAME_KEBAB=$PROGRAM_NAME_KEBAB
.
"

# PATH. Add opamrun
export PATH="$PROJECT_DIR/.ci/sd4/opamrun:$PATH"

# Initial Diagnostics (optional but useful)
opamrun switch
opamrun list
opamrun var
opamrun config report
opamrun option
opamrun exec -- ocamlc -config

# Update
opamrun update

# Dev notes
# ---------
#
# Because of the error on manylinux2014 (CentOS 7):
#   No solution found, exiting
#   - conf-pkg-config
#   depends on the unavailable system package 'pkgconfig'.
# we use `--no-depexts`. The dockcross manylinux2014 has package names
# pkgconfig.i686 and pkgconfig.x86_64, it does not seem to match what
# opam 2.1.0 is looking for ("pkgconfig").
# `conf-pkg-config` is needed by `dkml-component-staging-unixutils` ->
# `digestif`

# Install
case "$dkml_host_abi" in
linux_*) opamrun install ./${OPAM_PACKAGE}.opam --with-test --yes --no-depexts ;;
*) opamrun install ./${OPAM_PACKAGE}.opam --with-test --yes ;;
esac

# Examine the installer
_share=$(opamrun var ${OPAM_PACKAGE}:share)
opamrun install diskuvbox --yes
opamrun exec -- diskuvbox tree -d 6 --encoding UTF-8 "$_share"

# Finalize and distribute the Console installer (each type of installer has its unique finalization procedure)
install -d dist
case "$dkml_host_abi" in
linux_*)
    opamrun exec -- "$_share"/t/bundle-${PROGRAM_NAME_KEBAB}-"$dkml_host_abi"-i.sh -o dist -e .tar.gz tar --gzip
    opamrun exec -- "$_share"/t/bundle-${PROGRAM_NAME_KEBAB}-"$dkml_host_abi"-u.sh -o dist -e .tar.gz tar --gzip
    ;;
darwin*)
    opamrun exec -- "$_share"/t/bundle-${PROGRAM_NAME_KEBAB}-"$dkml_host_abi"-i.sh -o dist -e .tar.gz -t bsd tar --gzip
    opamrun exec -- "$_share"/t/bundle-${PROGRAM_NAME_KEBAB}-"$dkml_host_abi"-i.sh -o dist -e .tar.gz -t bsd tar --gzip
    ;;
windows_*)
    opamrun exec -- find "$_share"/t -maxdepth 1 -name "unsigned-${PROGRAM_NAME_KEBAB}-$dkml_host_abi-i-*.exe" -exec install {} dist/ \;
    opamrun exec -- find "$_share"/t -maxdepth 1 -name "unsigned-${PROGRAM_NAME_KEBAB}-$dkml_host_abi-u-*.exe" -exec install {} dist/ \;
    opamrun exec -- find "$_share"/t -maxdepth 1 -name "${PROGRAM_NAME_KEBAB}-$dkml_host_abi-i-*.sfx" -exec install {} dist/ \;
    opamrun exec -- find "$_share"/t -maxdepth 1 -name "${PROGRAM_NAME_KEBAB}-$dkml_host_abi-u-*.sfx" -exec install {} dist/ \;
    ;;
esac
