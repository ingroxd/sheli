#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_CONFIG__LOADED-false}" && return                 # If loaded, do nothing
"${__SHELI_LIB_CONFIG__LOADING-false}" && exit "${EX_SOFTWARE}" # If loading, something is wrong

export __SHELI_LIB_CONFIG__LOADING=true

########################################
# XXX
# This lib emulates python's configparser
# It is not a complete solution and it is not implemented in the same way
# The aim is to read a simple .ini file divided in sections
########################################

########################################
# config__get()
# Return the value of the requested section_name.var_name
########################################
config__get() {
  local section_name="${1}"; shift
  local var_name="${1}"; shift

  local section; section="$(
    sed -e "0,/\\[${section_name}\\]/d" \
    -e '/\[[^]]\+\]/,$d' \
    "${CONFIG_FILE}"
  )"
  local var; var="$(
    printf '%s' "${section}" \
    | grep -e "^${var_name}[[:space:]]*=[[:space:]]*.*$" \
    | tail -n 1
  )"
  if [ "${var:-"${NULL}"}" != "${NULL}" ]; then
    local value; value="$(
      printf '%s' "${var}" \
      | sed -e "s/^${var_name}[[:space:]]*=//" \
        -e 's/^[[:space:]]*//' \
        -e 's/[[:space:]]*$//'
    )"
    printf '%s' "${value}" >&9
  else
    print__error 'No option %s in section: %s' "'${var_name}'" "'${section_name}'"
    return "${EX_CONFIG}"
  fi
} 9>&1 >&8

########################################
# config__getint()
# Same as config__get() with validation for integer numbers
########################################
config__getint() {
  local section_name="${1}"; shift
  local var_name="${1}"; shift
  value="$(config__get "${section_name}" "${var_name}")"
  if is_int "${value}"; then
    printf '%i' "${value}" >&9
  else
    print__error 'invalid literal with base 10: %s' "'${value}'"
    return "${EX_CONFIG}"
  fi
} 9>&1 >&8

__config__load_file() {
  local CONFIG_FILE_="${1}"; shift
  [ -n "${CONFIG_FILE-}" ] && CONFIG_FILE_="${CONFIG_FILE}"
  export CONFIG_FILE="${CONFIG_FILE_}"
}

__config__load() {
  export __SHELI_LIB__LOADING='config'

  dep__lib 'test'

  __config__load_file "${BIN_NAME}.ini"

  unset __SHELI_LIB__LOADING
}

__config__load "${@}" || exit "${?}"
export __SHELI_LIB_CONFIG__LOADING=false
export __SHELI_LIB_CONFIG__LOADED=true

