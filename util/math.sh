#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_MATH__LOADED-false}" && return                 # If loaded, do nothing
"${__SHELI_LIB_MATH__LOADING-false}" && exit "${EX_SOFTWARE}" # If loading, something is wrong

export __SHELI_LIB_MATH__LOADING=true

pow() {
  base="${1}"; shift
  exponent="${1}"; shift
  if ! is_int "${base}"; then
    print__warning '%s is not a valid integer number' "${base}"
    base=0
  fi
  if ! is_int "${exponent}" || is_negative "${exponent}"; then
    print__warning '%s is not a valid positive integer number' "${exponent}"
    exponent=0
  fi
  if command -v 'bc' >/dev/null; then
    printf '%s^%s\n' "${base}" "${exponent}" | bc
  else
    local pow=1
    while [ "${exponent}" -gt 0 ]; do
      pow="$((pow * base))"
      exponent="$((exponent - 1))"
    done
    printf '%s' "${pow}"
  fi >&9
} 9>&1 >&8

rand() {
  printf '%i' "0x$(od -A n -N 4 -t x /dev/urandom | tr -d ' ')" >&9
} 9>&1 >&8

__math__load() {
  export __SHELI_LIB__LOADING='math'

  dep__lib 'test'
  dep__pkg 'od'
  dep__pkg_opt 'bc'

  unset __SHELI_LIB__LOADING
}

__math__load "${@}" || exit "${?}"
export __SHELI_LIB_MATH__LOADING=false
export __SHELI_LIB_MATH__LOADED=true

