#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  printf 'This library is intended to be imported by sheli.\n' >&2
  exit 69
fi
# If we are here, we have all the sheli env

"${__SHELI_LIB_UPTIME__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_UPTIME__LOADING-false}" && exit $((EX__SOFTWARE)) # If loading, something is wrong

export __SHELI_LIB_UPTIME__LOADING=true

__uptime__gettime() {
  local uptime foo
  exec 3</proc/uptime
  IFS=' ' read -r uptime foo </proc/uptime
  exec 3>&-
  printf '%s' "${uptime%.*}${uptime#*.}"
}

uptime__get() {
  printf '%s' $((10 * ($(__uptime__gettime) - UPTIME_START)))
}

__uptime__load() {
  export __SHELI_LIB__LOADING='uptime'

  export UPTIME_START="$(__uptime__gettime)"
  
}

__uptime__load "${@}" || exit "${?}"
export __SHELI_LIB_UPTIME__LOADING=false
export __SHELI_LIB_UPTIME__LOADED=true

