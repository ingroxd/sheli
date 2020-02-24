#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  printf 'This library is intended to be imported by sheli.\n' >&2
  exit 69
fi
# If we are here, we have all the sheli env

"${__SHELI_LIB_TRAP__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_TRAP__LOADING-false}" && exit $((EX__SOFTWARE)) # If loading, something is wrong

export __SHELI_LIB_TRAP__LOADING=true

########################################
# Manage INT signal
########################################
__trap__ctrl_c() {
  printf '%b' '\n'
  if command -v ctrl_c >/dev/null; then
    ctrl_c
  else
    printf '%s\n' '¯\_(ツ)_/¯' >&2
  fi
  export SIG=2
  exit # __trap__die will NOT run if using dash
}

########################################
# Manage QUIT signal
########################################
__trap__quit() {
  printf '%b' '\n'
  if command -v quit >/dev/null; then
    quit
  else
    if "${__SHELI_LIB_PRINT__LOADED-false}"; then
      print_info 'QUIT signal received.'
    else
      printf '%s\n' 'QUIT signal received' >&2
    fi
  fi
  export SIG=3
  exit
}

########################################
# Manage STOP signal
########################################
__trap__stop() {
  printf '%b' '\n'
  if command -v stop >/dev/null; then
    stop
  else
    if "${__SHELI_LIB_PRINT__LOADED-false}"; then
      print_info 'STOP signal received.'
    else
      printf '%s\n' 'STOP signal received' >&2
    fi
  fi
  export SIG=19
  exit
}

__trap__cleanup() {
  if command -v cleanup >/dev/null; then
    cleanup
  fi
  rm -rf "${TMP_DIR}"
}

__trap__die() {
  if command -v die >/dev/null; then
    die
  fi
  "${CLEANUP}" && __trap__cleanup

  # We need to resend the signal we trapped
  trap $((SIG))
  kill -$((SIG)) $((PID))
  exit
}

__trap__load() {
  export __SHELI_LIB__LOADING='trap'

  # Should we cleanup tmp files?
  local CLEANUP_=true
  case "${CLEANUP-}" in true|false) CLEANUP_="${CLEANUP}";; esac
  export CLEANUP="${CLEANUP_}"

  # We need to save the signal we trap to resend it
  export SIG=0

  trap __trap__ctrl_c 2 # INT
  trap __trap__quit 3   # QUIT
  trap __trap__stop 19  # STOP
  trap __trap__die 0    # EXIT
}

__trap__load "${@}" || exit "${?}"
export __SHELI_LIB_TRAP__LOADING=false
export __SHELI_LIB_TRAP__LOADED=true

