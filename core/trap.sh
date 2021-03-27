#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_TRAP__LOADED-false}" && return                 # If loaded, do nothing
"${__SHELI_LIB_TRAP__LOADING-false}" && exit "${EX_SOFTWARE}" # If loading, something is wrong

export __SHELI_LIB_TRAP__LOADING=true

########################################
# print__info()
# Fallback substitute of print.print__info
########################################
if ! command -v print__info >/dev/null; then
  print__info() {
    {
      printf '%s: info: ' "${BIN_NAME}"
      printf "${@}"
      printf '%b' '\n'
    } >&2
  }
fi

########################################
# __trap__int()
# Manage INT signal
# If defined, ctrl_c() is called
########################################
__trap__int() {
  printf '%b' '\n'
  if command -v trap__int >/dev/null; then
    trap__int
  else
    #print__info '¯\_(ツ)_/¯'
    print__info 'terminated by signal Interrupt (2)'
  fi
  export SIG=2
  __trap__die
}

########################################
# __trap__quit()
# Manage QUIT signal
# If defined, quit() is called
########################################
__trap__quit() {
  printf '%b' '\n'
  if command -v trap__quit >/dev/null; then
    trap__quit
  else
    print__info 'terminated by signal Quit (3)'
  fi
  export SIG=3
  __trap__die
}

########################################
# __trap__term()
# Manage TERM signal
# If defined, terminate() is called
########################################
__trap__term() {
  printf '%b' '\n'
  if command -v trap__term >/dev/null; then
    trap__term
  else
    print__info 'terminated by signal Terminate (15)'
  fi
  export SIG=15
  __trap__die
}

########################################
# __trap__cleanup()
# Clean all the temp files
# If defined, cleanup() is called
########################################
__trap__cleanup() {
  if command -v trap__cleanup >/dev/null; then
    trap__cleanup
  fi
  rm -rf "${TMP_DIR}"
}

__trap__die() {
  if command -v trap__die >/dev/null; then
    trap__die
  fi
  "${CLEANUP}" && __trap__cleanup
  # Simulate the signal we trapped
  trap "${SIG}"
  kill "-${SIG}" "${PID}"
  exit
}

########################################
# __trap__load_cleanup()
# Check and set $CLEANUP
########################################
__trap__load_cleanup() {
  local CLEANUP_="${1}"; shift
  case "${CLEANUP-}" in true|false) CLEANUP_="${CLEANUP}";; esac
  export CLEANUP="${CLEANUP_}"
}

__trap__load() {
  export __SHELI_LIB__LOADING='trap'

  __trap__load_cleanup true
  export SIG=0

  trap __trap__int 2    # INT
  trap __trap__quit 3   # QUIT
  trap __trap__term 15  # TERM
  trap __trap__die 0    # EXIT

  unset __SHELI_LIB__LOADING
}

__trap__load "${@}" || exit "${?}"
export __SHELI_LIB_TRAP__LOADING=false
export __SHELI_LIB_TRAP__LOADED=true

