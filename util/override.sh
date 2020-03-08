#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  printf 'This library is intended to be imported by sheli.\n' >&2
  exit 69
fi
# If we are here, we have all the sheli env

"${__SHELI_LIB_OVERRIDE__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_OVERRIDE__LOADING-false}" && exit $((EX__SOFTWARE)) # If loading, something is wrong

export __SHELI_LIB_OVERRIDE__LOADING=true

########################################
# ovierrides sleep() adding some feedback
########################################
sleep() {
  local timeout="${1}"; shift
  timeout="$(printf '1 / %s * %s\n' "${WHEEL_TIME}" "${timeout}" | bc)"
  while [ "${timeout}" -gt 0 ]; do
    __print_wheel "${@}"
    command sleep "${WHEEL_TIME}"
    timeout=$((timeout - 1))
  done
  print_blankline
}

########################################
# overrides wait() adding some feedback
########################################
#if "${SET_m}"; then # when not in monitor mode, can have issues with '%1'
wait() {
  local pid="${1}"; shift
#  [ -z "${%%%*}" ] && pid="$(jobs -p "${1}")"
  while kill -0 "${pid}" 2>/dev/null; do
    __print_wheel 'Wait for %s to finish...' "${pid}"
    command sleep "${WHEEL_TIME}"
  done
  printf '%b' '\n'
}
#fi

__override__load() {
  export __SHELI_LIB__LOADING='override'

  dep__lib 'font' 'print'

  unset __SHELI_LIB__LOADING
}

__override__load "${@}" || exit "${?}"
export __SHELI_LIB_OVERRIDE__LOADING=false
export __SHELI_LIB_OVERRIDE__LOADED=true

