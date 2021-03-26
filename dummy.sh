#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_DUMMY__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_DUMMY__LOADING-false}" && exit "${EX_SOFTWARE}"  # If loading, something is wrong

export __SHELI_LIB_DUMMY__LOADING=true

__dummy__load() {
  export __SHELI_LIB__LOADING='dummy'

  unset __SHELI_LIB__LOADING
}

__dummy__load "${@}" || exit "${?}"
export __SHELI_LIB_DUMMY__LOADING=false
export __SHELI_LIB_DUMMY__LOADED=true

