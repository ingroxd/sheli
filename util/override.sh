#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_OVERRIDE__LOADED-false}" && return                 # If loaded, do nothing
"${__SHELI_LIB_OVERRIDE__LOADING-false}" && exit "${EX_SOFTWARE}" # If loading, something is wrong

export __SHELI_LIB_OVERRIDE__LOADING=true

########################################
# sleep()
# Override sleep adding some feedback
########################################
sleep() {
  if "${BACKGROUND}"; then
    local timeout="${1}"; shift
    command sleep "${timeout}"
  else
    local timeout="${1}00"; shift
    local done=false
    local start="$(time__time)"
    while ! "${done}"; do
      time="$(($(time__time) - start))"
      if [ "${@:-"${NULL}"}" = "${NULL}" ]; then
        print__wheel 'Wait: %ss' "$(((timeout - time) / 100))"
      else
        print__wheel "${@}"
      fi
      command sleep "${WHEEL_TIME}"
      if [ "${time}" -ge "${timeout}" ]; then done=true; fi
    done
    print__blankline
  fi
}

########################################
# wait()
# Override wait adding some feedback
########################################
if "${SET_m}"; then # '%i' can be troublesome if monitor mode disabled
wait() {
  if [ "${#}" -gt 0 ]; then
    local pid="${1}"; shift
  else
    local pid='%%'
  fi
  if "${BACKGROUND}"; then
    command wait "${pid}"
  else
    [ -z "${pid##%*}" ] && pid_="$(jobs -p "${pid}" 2>/dev/null)" # Convert %% to pid
    # Dash has problems with `jobs -p %%` so an extra check is needed
    [ -n "${pid_}" ] && pid="${pid_}"
    while kill -0 "${pid}" 2>/dev/null; do
      if [ "${@:-"${NULL}"}" = "${NULL}" ]; then
        print__wheel 'Wait for %s to finish...' "${pid}"
      else
        print__wheel "${@}"
      fi
      command sleep "${WHEEL_TIME}"
    done
    print__blankline
  fi
}
fi

########################################
# select()
# Override select() with something simplier
########################################
_select() {
  local reply=0
  local first_attempt=true
  while [ "${reply}" -lt 1 ] || [ "${reply}" -gt "${#}" ]; do
    if ! "${first_attempt}"; then
      print__warning 'Reply must be a number between 1 and %i' "${#}"
    fi
    print__list "${@}"
    printf '%b%s%b ' "${CYAN}" '[?]' "${_END}"
    IFS= read -r reply
    ! is_int "${reply:-"${NULL}"}" && reply=0
    first_attempt=false
  done
  shift "$((reply - 1))"
  printf '%s' "${1}" >&9
} 9>&1 >&8
export alias select=_select

__override__load() {
  export __SHELI_LIB__LOADING='override'

  dep__lib 'print' 'time' 'test'

  unset __SHELI_LIB__LOADING
}

__override__load() {
  export __SHELI_LIB__LOADING='override'

  unset __SHELI_LIB__LOADING
}

__override__load "${@}" || exit "${?}"
export __SHELI_LIB_OVERRIDE__LOADING=false
export __SHELI_LIB_OVERRIDE__LOADED=true

