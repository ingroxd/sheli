#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_PRINT__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_PRINT__LOADING-false}" && exit "${EX_SOFTWARE}"  # If loading, something is wrong

export __SHELI_LIB_PRINT__LOADING=true

########################################
# __print__printf_()
# Print a prefixed line.
# All the print__xxx call this function
########################################
__print__printf_() {
  local font="${1}"; shift
  local prefix="${1}"; shift
  printf '%b%s%b ' "${font}" "${prefix}" "${_END}"
  printf "${@}"
}

########################################
# __print__printf()
# same as __print__printf_() with a new line
########################################
__print__printf() {
  __print__printf_ "${@}"
  printf '%b' '\n'
}

########################################
# print__timestamp()
# Print text prefixed by YYYYmmddTHHMMSS+zzzz
########################################
print__timestamp() {
  __print__printf '' "$(date +'%Y%m%dT%H%M%S%z')" "${@}"
}

########################################
# print__good()
# Print text prefixed by [+]
########################################
print__good() {
  __print__printf "${GREEN}" '[+]' "${@}"
}

########################################
# print__bad()
# Print text prefixed by [-]
########################################
print__bad() {
  __print__printf "${RED}" '[-]' "${@}"
}

########################################
# print__error()
# Print text prefixed by [x]
########################################
print__error() {
  __print__printf "${RED}" '[x]' "${@}" >&2
}

########################################
# print__warning()
# Print text prefixed by [!]
########################################
print__warning() {
  __print__printf "${YELLOW}" '[!]' "${@}" >&2
}

########################################
# print__info()
# Print text prefixed by [*]
########################################
print__info() {
  __print__printf "${BLUE}" '[*]' "${@}" >&2
}

########################################
# print__debug()
# Print text prefixed by [#] only in debug mode
########################################
print__debug() {
  if "${DEBUG}"; then
    __print__printf "${MAGENTA}" '[#]' "${@}" >&2
  fi
}

########################################
# print__question()
# Print text prefixed by [?]
########################################
print__question() {
  __print__printf "${CYAN}" '[?]' "${@}"
}

########################################
# print__list()
# Print a list of elements prefixed by its index padded
#   E.G. [03] for third element in a list of at least 10
########################################
print__list() {
  local argno="${#}"
  local i=1
  for arg; do
    __print__printf "${CYAN}" "[$(printf '%.*i' "${#argno}" "${i}")]" "${arg}"
    i=$((i + 1))
  done
}

########################################
# print__list()
# Replace the current line with spaces
########################################
print__blankline() {
  printf '%b%b' '\r' '\033[K'
}

########################################
# print__wheel()
# Print a wheel starting from $WHEEL_ANIM
# To be used in a cycle
########################################
print__wheel() {
  export WHEEL_FRAME="${WHEEL_ANIM%"${WHEEL_ANIM#?}"}"
  export WHEEL_ANIM="${WHEEL_ANIM#?}${WHEEL_FRAME}"

  print__blankline
  #printf '%b' '\r'
  __print__printf_ "${CYAN}" "[${WHEEL_FRAME}]" "${@}"
}

__print__load_wheel() {
  local WHEEL_ANIM_="${1}"; shift
  local WHEEL_TIME_="${1}"; shift
  # Not used because of bc
  # local WHEEL_TIME_=.125  # 8fps
  # if [ -n "${WHEEL_ANIM-}" ]; then
  #   WHEEL_ANIM_="${WHEEL_ANIM}"
  #   WHEEL_TIME_="$(printf 'scale=3; 1 / %s\n' "${#WHEEL_ANIM_}" | bc)"
  # fi
  # FIXME? Should be editable
  # [ -n "${WHEEL_ANIM-}" ] && WHEEL_ANIM_="${WHEEL_ANIM}"
  # [ -n "${WHEEL_TIME-}" ] && WHEEL_TIME_="${WHEEL_TIME}"
  export WHEEL_ANIM="${WHEEL_ANIM_}"
  export WHEEL_TIME="${WHEEL_TIME_}"
  export WHEEL_FRAME=''
}

__print__load() {
  export __SHELI_LIB__LOADING='print'

  dep__lib 'debug'

  # __print__load_wheel '|/-\' .125 # Beware of '-' when you grep the output
  __print__load_wheel '.oO0Oo. ' .1 # 10fps

  unset __SHELI_LIB__LOADING
}

__print__load "${@}" || exit "${?}"
export __SHELI_LIB_PRINT__LOADING=false
export __SHELI_LIB_PRINT__LOADED=true

