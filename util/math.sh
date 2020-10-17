#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  printf 'This library is intended to be imported by sheli.\n' >&2
  exit 69
fi
# If we are here, we have all the sheli env

"${__SHELI_LIB_MATH__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_MATH__LOADING-false}" && exit $((EX__SOFTWARE)) # If loading, something is wrong

export __SHELI_LIB_MATH__LOADING=true

pow() {
  base="${1}"; shift
  exponent="${1}"; shift
  printf '%s^%s\n' "${base}" "${exponent}" | bc
}

__math__load() {
  export __SHELI_LIB__LOADING='math'

  dep__pkg 'bc'

  unset __SHELI_LIB__LOADING
}

__math__load "${@}" || exit "${?}"
export __SHELI_LIB_MATH__LOADING=false
export __SHELI_LIB_MATH__LOADED=true

