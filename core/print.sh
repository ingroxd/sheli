#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  printf 'This library is intended to be imported by sheli.\n' >&2
  exit 69
fi
# If we are here, we have all the sheli env

"${__SHELI_LIB_PRINT__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_PRINT__LOADING-false}" && exit $((EX__SOFTWARE)) # If loading, something is wrong

export __SHELI_LIB_PRINT__LOADING=true

########################################
# Print a line with a prefix;
# All the print_xxx call this function
########################################
__print__printf() {
  local font="${1}"; shift
  local prefix="${1}"; shift
  printf '%b%s%b ' "${font}" "${prefix}" "${_END}"
  printf "${@}"
  printf '%b' '\n'
}

print_good() {
  __print__printf "${GREEN}" '[+]' "${@}"
}

print_bad() {
  __print__printf "${RED}" '[-]' "${@}"
}

print_error() {
  __print__printf "${RED}" '[x]' "${@}" >&2
}

print_warning() {
  __print__printf "${YELLOW}" '[!]' "${@}" >&2
}

print_info() {
  __print__printf "${BLUE}" '[*]' "${@}" >&2
}

print_question() {
  __print__printf "${CYAN}" '[?]' "${@}"
}

print_list() {
  local argnum="${#}"
  local size="${#argnum}"
  local i=1
  for arg; do
    __print__printf "${CYAN}" "[$(printf '%.*i' "${size}" "${i}")]" "${arg}"
    i=$((i + 1))
  done
}

########################################
# Erase the current line and replace it with a sequence of spaces
########################################
print_blankline() {
  printf '\r%*s\r' "$(tput cols)" ''
}

__print_wheel() {
  export WHEEL_FRAME="${WHEEL_ANIM%"${WHEEL_ANIM#?}"}"
  export WHEEL_ANIM="${WHEEL_ANIM#?}${WHEEL_ANIM%"${WHEEL_ANIM#?}"}"

  printf '%b' '\r'
  printf '%b%s%b ' "${CYAN}" "[${WHEEL_FRAME}]" "${_END}"
  printf "${@}"
}

__print__load() {
  export __SHELI_LIB__LOADING='print'

  dep__lib 'font'
  dep__pkg 'printf' 'tput'

  #export WHEEL_ANIM='|/-\' # Beware of '-' when you grep the output
  export WHEEL_ANIM='.oO0Oo. '
  export WHEEL_TIME=.125 # 8 frames per seconds
  export WHEEL_FRAME=''

  unset __SHELI_LIB__LOADING
}

__print__load "${@}" || exit "${?}"
export __SHELI_LIB_PRINT__LOADING=false
export __SHELI_LIB_PRINT__LOADED=true

