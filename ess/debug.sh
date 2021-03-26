#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_DEBUG__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_DEBUG__LOADING-false}" && exit "${EX_SOFTWARE}"  # If loading, something is wrong

export __SHELI_LIB_DEBUG__LOADING=true

########################################
# debug()
# Execute code only in debug mode
########################################
debug__exec() {
  if "${DEBUG}"; then
    # TODO? Save a log
    "${@}"
  fi
}

########################################
# xtrace()
# Execute and trace only in debug mode
########################################
debug__xtrace() {
  if "${DEBUG}"; then
    set -o xtrace
    # TODO? Save a log
    "${@}"
    ! "${SET_x}" && set +o xtrace
  fi
}

__debug__load_debug() {
  local DEBUG_="${1}"; shift
  case "${DEBUG-}" in true|false) DEBUG_="${DEBUG}";; esac
  export DEBUG="${DEBUG_}"
}

__debug__load_debug_log() {
  local DEBUG_LOG_="${1}"; shift
  [ -n "${DEBUG_LOG-}" ] && DEBUG_LOG_="${DEBUG_LOG}"
  export DEBUG_LOG="${DEBUG_LOG_}"
  if ! [ -e "${DEBUG_LOG}" ]; then
    touch "${DEBUG_LOG}" || return "${EX_CANTCREAT}"
  fi
}

__debug__load() {
  export __SHELI_LIB__LOADING='debug'

  __debug__load_debug false
  if "${DEBUG}"; then
    __debug__load_debug_log "${TMP_DIR}/${BIN_NAME}.log"
    export CLEANUP=false
  fi

  unset __SHELI_LIB__LOADING
}

__debug__load "${@}" || exit "${?}"
export __SHELI_LIB_DEBUG__LOADING=false
export __SHELI_LIB_DEBUG__LOADED=true

