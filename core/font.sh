#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_FONT__LOADED-false}" && return                 # If loaded, do nothing
"${__SHELI_LIB_FONT__LOADING-false}" && exit "${EX_SOFTWARE}" # If loading, something is wrong

export __SHELI_LIB_FONT__LOADING=true

########################################
# print__error()
# Fallback substitute of print.print__error
########################################
if ! command -v print__error >/dev/null; then
  print__error() {
    local name="${__SHELI_LIB__LOADING-"${BIN_NAME}"}"
    {
      printf '%s: error: ' "${name}"
      printf "${@}"
      printf '%b' '\n'
    } >&2
  }
fi

########################################
# __font__enable()
# Set all font variables
########################################
__font__enable() {
  # FIXME
  # Some tput commands are not working properly (E.G. tput invis)
  # if command -v tput >/dev/null && tput setaf 1 >/dev/null 2>&1; then
  #   export BOLD="$(tput bold)"
  #   export DARK="$(tput dim)"
  #   export ITALIC="$(tput smso)"
  #   export ULINE="$(tput smul)"
  #   export BLINK="$(tput blink)"
  #   export REVERSE="$(tput rev)"
  #   export HIDE="$(tput invis)"
  #   export STRIKE='\033[9m'
  #   export _END="$(tput sgr0)"

  #   export BLACK="$(tput setaf 0)"
  #   export RED="$(tput setaf 1)"
  #   export GREEN="$(tput setaf 2)"
  #   export YELLOW="$(tput setaf 3)"
  #   export BLUE="$(tput setaf 4)"
  #   export MAGENTA="$(tput setaf 5)"
  #   export CYAN="$(tput setaf 6)"
  #   export WHITE="$(tput setaf 7)"

  #   export BBLACK="$(tput setab 0)"
  #   export BRED="$(tput setab 1)"
  #   export BGREEN="$(tput setab 2)"
  #   export BYELLOW="$(tput setab 3)"
  #   export BBLUE="$(tput setab 4)"
  #   export BMAGENTA="$(tput setab 5)"
  #   export BCYAN="$(tput setab 6)"
  #   export BWHITE="$(tput setab 7)"
  # else
  export BOLD='\033[1m'
  export DARK='\033[2m'
  export ITALIC='\033[3m'
  export ULINE='\033[4m'
  export BLINK='\033[5m'
  export REVERSE='\033[7m'
  export HIDE='\033[8m'
  export STRIKE='\033[9m'
  export _END='\033[0m'

  export BLACK='\033[30m'
  export RED='\033[31m'
  export GREEN='\033[32m'
  export YELLOW='\033[33m'
  export BLUE='\033[34m'
  export MAGENTA='\033[35m'
  export CYAN='\033[36m'
  export WHITE='\033[38m'

  export BBLACK='\033[40m'
  export BRED='\033[41m'
  export BGREEN='\033[42m'
  export BYELLOW='\033[43m'
  export BBLUE='\033[44m'
  export BMAGENTA='\033[45m'
  export BCYAN='\033[46m'
  export BWHITE='\033[47m'
  # fi
}

########################################
# __font__disable()
# Unset all font variables
# Technically, all vars are set as '' (due to nounset)
########################################
__font__disable() {
  export BOLD=''
  export DARK=''
  export ITALIC=''
  export ULINE=''
  export BLINK=''
  export REVERSE=''
  export HIDE=''
  export STRIKE=''
  export _END=''

  export BLACK=''
  export RED=''
  export GREEN=''
  export YELLOW=''
  export BLUE=''
  export MAGENTA=''
  export CYAN=''
  export WHITE=''

  export BBLACK=''
  export BRED=''
  export BGREEN=''
  export BYELLOW=''
  export BBLUE=''
  export BMAGENTA=''
  export BCYAN=''
  export BWHITE=''
}

########################################
# font__enable()
# If $FONT_ENABLED is 'never' or 'always', never or always enable font, respectively
# If $FONT_ENABLED is 'auto', decide wethere enable or disable font
########################################
font__set() {
  local FONT_ENABLED_="${1}"; shift
  case "${FONT_ENABLED-}" in never|auto|always) FONT_ENABLED_="${FONT_ENABLED}";; esac
  #export FONT_ENABLED="${FONT_ENABLED_}"
  local FONT_ENABLED="${FONT_ENABLED_}"
  
  local font=false
  case "${FONT_ENABLED}" in
    never)
      font=false
      ;;
    auto)
      if command -v tput >/dev/null && tput setaf 1 >/dev/null 2>&1; then
        # assuming Ecma-48 (ISO/IEC-6429)
        font=true
      else
        font=false
      fi
      # If piped or backgrounded, disable font
      "${PIPED}" && font=false
      "${BACKGROUND}" && font=false
      ;;
    always)
      font=true
      ;;
    *)
      print__error 'Wrong $FONT_ENABLED value'
      exit "${EX_SOFTWARE}"
  esac

  if "${font}"; then
    __font__enable
  else
    __font__disable
  fi
}

__font__load() {
  export __SHELI_LIB__LOADING='font'

  dep__pkg 'tput'

  font__set 'auto'

  unset __SHELI_LIB__LOADING
}

__font__load "${@}" || exit "${?}"
export __SHELI_LIB_FONT__LOADING=false
export __SHELI_LIB_FONT__LOADED=true

