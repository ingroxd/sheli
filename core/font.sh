#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  printf 'This library is intended to be imported by sheli.\n' >&2
  exit 69
fi
# If we are here, we have all the sheli env

"${__SHELI_LIB_FONT__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_FONT__LOADING-false}" && exit $((EX__SOFTWARE)) # If loading, something is wrong

export __SHELI_LIB_FONT__LOADING=true

__font__enable() {
  export BOLD='\033[1m'       # "$(tput bold)"
  export DARK='\033[2m'       # "$(tput smul)"
  export ITALIC='\033[3m'
  export ULINE='\033[4m'
  export BLINK='\033[5m'
  export REVERSE='\033[7m'
  export HIDE='\033[8m'
  export STRIKE='\033[9m'
  export _END='\033[0m'       # "$(tput sgr0)"

  export BLACK='\033[30m'     # "$(tput setaf 0)"
  export RED='\033[31m'       # "$(tput setaf 1)"
  export GREEN='\033[32m'     # "$(tput setaf 2)"
  export YELLOW='\033[33m'    # "$(tput setaf 3)"
  export BLUE='\033[34m'      # "$(tput setaf 4)"
  export MAGENTA='\033[35m'   # "$(tput setaf 5)"
  export CYAN='\033[36m'      # "$(tput setaf 6)"
  export WHITE='\033[38m'     # "$(tput setaf 7)"

  export BBLACK='\033[40m'    # "$(tput setab 0)"
  export BRED='\033[41m'      # "$(tput setab 1)"
  export BGREEN='\033[42m'    # "$(tput setab 2)"
  export BYELLOW='\033[43m'   # "$(tput setab 3)"
  export BBLUE='\033[44m'     # "$(tput setab 4)"
  export BMAGENTA='\033[45m'  # "$(tput setab 5)"
  export BCYAN='\033[46m'     # "$(tput setab 6)"
  export BWHITE='\033[47m'    # "$(tput setab 7)"
}

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

__font__load() {
  export __SHELI_LIB__LOADING='font'

  __font__enable

  unset __SHELI_LIB__LOADING
}

__font__load "${@}" || exit "${?}"
export __SHELI_LIB_FONT__LOADING=false
export __SHELI_LIB_FONT__LOADED=true

