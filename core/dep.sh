#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_DEP__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_DEP__LOADING-false}" && exit "${EX_SOFTWARE}"  # If loading, something is wrong

export __SHELI_LIB_DEP__LOADING=true

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
# __dep__var()
# Check if a var exists
########################################
__dep__var() {
  set | grep -e "^${1}\\(=.*\\)\\?$" >/dev/null
}

########################################
# __dep__lib()
# Check if a lib exists
########################################
__dep__lib() {
  lib="$(printf '%s' "${1}" | tr '[:lower:]' '[:upper:]')"
  set | grep -e "^__SHELI_LIB_${lib}__LOADED\\(=.*\\)\\?$" >/dev/null
}

########################################
# __dep__pkg()
# Check if a pkg exists
########################################
__dep__pkg() {
  command -v "${1}" >/dev/null
}

########################################
# dep__var_opt()
# Check if vars exist
# Return an error if at least 1 var is not set
########################################
dep__var_opt() {
  local var
  for var; do
    __dep__var "${var}" || return "${EX_UNAVAILABLE}"
  done
  return 0
}

########################################
# dep__lib_opt()
# Check if libs exist
# Return an error if at least 1 lib is not loaded
########################################
dep__lib_opt() {
  local lib
  for lib; do
    __dep__lib "${lib}" || return "${EX_UNAVAILABLE}"
  done
  return 0
}

########################################
# dep__pkg_opt()
# Check if pkgs exist
# Return an error if at least 1 pkg is unavailable
########################################
dep__pkg_opt() {
  local pkg
  for pkg; do
    __dep__pkg "${pkg}" || return "${EX_UNAVAILABLE}"
  done
  return 0
}

########################################
# dep__var()
# Check if vars exist
# Exit with error if at least 1 var is not set
########################################
dep__var() {
  local var
  for var; do
    if ! __dep__var "${var}"; then
      print__error 'var $%s not set' "${var}"
      exit "${EX_UNAVAILABLE}"
    fi
  done
}

########################################
# dep__lib()
# Check if libs exist
# Exit with error if at least 1 lib is not loaded
########################################
dep__lib() {
  local lib
  for lib; do
    if ! __dep__lib "${lib}"; then
      local name="${__SHELI_LIB__LOADING-"${BIN_NAME}"}"
      print__error 'lib %s not loaded' "'${lib}'"
      exit "${EX_UNAVAILABLE}"
    fi
  done
}

########################################
# dep__pkg()
# Check if pkgs exists
# Exit with error if at least 1 pkg is unavailable
########################################
dep__pkg() {
  local pkg
  for pkg; do
    if ! __dep__pkg "${pkg}"; then
      local name="${__SHELI_LIB__LOADING-"${BIN_NAME}"}"
      print__error 'pkg %s not available' "'${pkg}'"
      exit "${EX_UNAVAILABLE}"
    fi
  done
}

__dep__load() {
  export __SHELI_LIB__LOADING='dep'

  unset __SHELI_LIB__LOADING
}

__dep__load "${@}" || exit "${?}"
export __SHELI_LIB_DEP__LOADING=false
export __SHELI_LIB_DEP__LOADED=true

