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
    __print_wheel "${@-}"
    command sleep "${WHEEL_TIME}"
    timeout=$((timeout - 1))
  done
  print_blankline
}

########################################
# overrides wait() adding some feedback
########################################
if "${SET_m}"; then # when not in monitor mode, can have issues with '%1'
wait() {
  if [ "${#}" -gt 0 ]; then
    local pid="${1}"; shift
  else
    local pid='%%'
  fi
  [ -z "${pid##%*}" ] && pid="$(jobs -p "${pid}")"
  while kill -0 "${pid}" 2>/dev/null; do
    __print_wheel 'Wait for %s to finish...' "${pid}"
    command sleep "${WHEEL_TIME}"
  done
  printf '%b' '\n'
}
fi

########################################
# overrides select() with something simplier
########################################
_select() {
  local reply=0
  local first_attempt=true
  while [ "${reply}" -lt 1 ] || [ "${reply}" -gt "${#}" ]; do
    if ! "${first_attempt}"; then
      print_warning "Reply must be a number between 1 and ${#}"
    fi
    print_list "${@}"
    printf '%b%s%b ' "${CYAN}" '[?]' "${_END}" >&2
    read reply
    reply="$(printf '%i' "${reply}" 2>/dev/null)"
    "${first_attempt}" && first_attempt=false
  done
  while [ "${reply}" -gt 1 ]; do
    shift
    reply=$((reply - 1))
  done
  printf '%s' "${1}" >&9
} 9>&1 >&8

__override__load() {
  export __SHELI_LIB__LOADING='override'

  dep__lib 'font' 'print'

  unset __SHELI_LIB__LOADING
}

__override__load "${@}" || exit "${?}"
export __SHELI_LIB_OVERRIDE__LOADING=false
export __SHELI_LIB_OVERRIDE__LOADED=true

