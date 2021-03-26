#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_BEHAVIOUR__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_BEHAVIOUR__LOADING-false}" && exit "${EX_SOFTWARE}"  # If loading, something is wrong

export __SHELI_LIB_BEHAVIOUR__LOADING=true

########################################
# __behaviour__load_errexit()
# Check and set errexit
########################################
__behaviour__load_errexit() {
  # Exit on error
  local SET_e_="${1}"; shift
  case "${SET_e-}" in true|false) SET_e_="${SET_e}";; esac
  export SET_e="${SET_e_}"
  "${SET_e}" && set -o errexit
}

########################################
# __behaviour__load_nounset()
# Check and set nounset
########################################
__behaviour__load_nounset() {
  # Exit on unset var
  local SET_u_="${1}"; shift
  case "${SET_u-}" in true|false) SET_u_="${SET_u}";; esac
  export SET_u="${SET_u_}"
  "${SET_u}" && set -o nounset
}

########################################
# __behaviour__load_noclobber()
# Check and set noclobber
########################################
__behaviour__load_noclobber() {
  # Do not write on existing files
  local SET_C_="${1}"; shift
  case "${SET_C-}" in true|false) SET_C_="${SET_C}";; esac
  export SET_C="${SET_C_}"
  "${SET_C}" && set -o noclobber
}

########################################
# __behaviour__load_monitor()
# Check and set monitor
########################################
__behaviour__load_monitor() {
  # Do job monitor
  local SET_m_="${1}"; shift
  case "${SET_m-}" in true|false) SET_m_="${SET_m}";; esac
  export SET_m="${SET_m_}"
  "${SET_m}" && set -o monitor
}

########################################
# __behaviour__load_verbose()
# Check and set verbose
########################################
__behaviour__load_verbose() {
  # Verbose execution
  local SET_v_="${1}"; shift
  case "${SET_v-}" in true|false) SET_v_="${SET_v}";; esac
  export SET_v="${SET_v_}"
  "${SET_v}" && set -o verbose
}

########################################
# __behaviour__load_xtrace()
# Check and set xtrace
########################################
__behaviour__load_xtrace() {
  # Execution trace
  local SET_x_="${1}"; shift
  case "${SET_x-}" in true|false) SET_x_="${SET_x}";; esac
  export SET_x="${SET_x_}"
  "${SET_x}" && set -o xtrace
}

__behaviour__load() {
  export __SHELI_LIB__LOADING='behaviour'

  __behaviour__load_errexit true
  __behaviour__load_nounset true
  __behaviour__load_noclobber true
  __behaviour__load_monitor false # FIXME? Should start as true
  __behaviour__load_verbose false
  __behaviour__load_xtrace false

  unset __SHELI_LIB__LOADING
}

__behaviour__load "${@}" || exit "${?}"
export __SHELI_LIB_BEHAVIOUR__LOADING=false
export __SHELI_LIB_BEHAVIOUR__LOADED=true

