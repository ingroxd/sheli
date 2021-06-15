#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_TIME__LOADED-false}" && return                 # If loaded, do nothing
"${__SHELI_LIB_TIME__LOADING-false}" && exit "${EX_SOFTWARE}" # If loading, something is wrong

export __SHELI_LIB_TIME__LOADING=true

time__time() {
  local uptime foo
  IFS=' ' read -r uptime foo </proc/uptime
  printf '%s' "${uptime%.*}${uptime#*.}" >&9
} 9>&1 >&8

time__uptime() {
  printf '%s' $((10 * ($(time__time) - __TIME__START))) >&9
} 9>&1 >&8


__time__load() {
  export __SHELI_LIB__LOADING='time'

  export __TIME__START; __TIME__START="$(time__time)"

  unset __SHELI_LIB__LOADING
}

__time__load "${@}" || exit "${?}"
export __SHELI_LIB_TIME__LOADING=false
export __SHELI_LIB_TIME__LOADED=true

