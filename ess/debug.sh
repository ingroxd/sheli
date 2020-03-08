#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  printf 'This library is intended to be imported by sheli.\n' >&2
  exit 69
fi
# If we are here, we have all the sheli env

"${__SHELI_LIB_DEBUG__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_DEBUG__LOADING-false}" && exit $((EX__SOFTWARE)) # If loading, something is wrong

export __SHELI_LIB_DEBUG__LOADING=true

########################################
# Prints only in debug mode
########################################
print_debug() {
  if "${DEBUG}"; then
    __print__printf "${MAGENTA}" '[#]' "${@}"
  fi
}

########################################
# Execute code only in debug mode
########################################
debug() {
  if "${DEBUG}"; then
    #TODO? save a log
    "${@}" #|tee -a "${DEBUG_LOG}" >&2
  fi
}

########################################
# Execute and trace code only in debug mode
########################################
xtrace() {
  if "${DEBUG}"; then
    set -o xtrace
    #TODO? save a log
    "${@}" #| tee -a "${DEBUG_LOG}" >&2
    ! "${SET_x}" && set +o xtrace
  fi
}

__debug__load() {
  export __SHELI_LIB__LOADING='debug'

  dep__lib 'print'
  dep__pkg 'tee'

  # Should we enable debug?
  local DEBUG_=false
  case "${DEBUG-}" in true|false) DEBUG_="${DEBUG}";; esac
  export DEBUG="${DEBUG_}"

  if "${DEBUG}"; then

    local DEBUG_LOG="${TMP_DIR}/${BIN_NAME}.log"
    [ -n "${DEBUG_LOG-}" ] && DEBUG_LOG_="${DEBUG_LOG}"
    export DEBUG_LOG="${DEBUG_LOG_}"

    if ! [ -e "${DEBUG_LOG}" ]; then
      touch "${DEBUG_LOG}" || return $((EX_CANTCREAT))
    fi

    export CLEANUP=false
  fi

  unset __SHELI_LIB__LOADING
}

__debug__load "${@}" || exit "${?}"
export __SHELI_LIB_DEBUG__LOADING=false
export __SHELI_LIB_DEBUG__LOADED=true

