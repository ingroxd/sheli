#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  printf 'This library is intended to be imported by sheli.\n' >&2
  exit 69
fi
# If we are here, we have all the sheli env

"${__SHELI_LIB_DEP__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_DEP__LOADING-false}" && exit $((EX__SOFTWARE)) # If loading, something is wrong

export __SHELI_LIB_DEP__LOADING=true

########################################
# Checks if a var exists
########################################
dep__var() {
  local name="${__SHELI_LIB__LOADING-"${BIN_NAME}"}"
  local var
  for var; do
    if ! set | grep -e "^${var}\(=.*\)\?$" >/dev/null; then # if var is not set
      if "${__SHELI_LIB_PRINT__LOADED-false}"; then
        print_error '%s.sh: var $%s not set' "${name}" "${var}"
      else
        printf '%s.sh: error: var $%s not set\n' "${name}" "${var}" >&2
      fi
      exit $((EX_UNAVAILABLE))
    fi
  done
}

########################################
# Checks if a lib has already been loaded
########################################
dep__lib() {
  local name="${__SHELI_LIB__LOADING-"${BIN_NAME}"}"
  local lib
  for lib; do
    lib="$(printf '%s' "${lib}" | tr '[:lower:]' '[:upper:]')"
    if ! set | grep -e "^__SHELI_LIB_${lib}__LOADED\(=.*\)\?$" >/dev/null; then
      if "${__SHELI_LIB_PRINT__LOADED-false}"; then
        print_error '%s.sh: lib %s.sh not loaded' "${name}" "${lib}"
      else
        printf '%s.sh: error: lib %s.sh not loaded\n' "${name}" "${lib}" >&2
      fi
      exit $((EX_UNAVAILABLE))
    fi
  done
}

########################################
# Checks if a packages (or functions) are available
########################################
dep__pkg() {
  local name="${__SHELI_LIB__LOADING-"${BIN_NAME}"}"
  local pkg
  for pkg; do
    if ! command -v "${pkg}" >/dev/null; then
      if "${__SHELI_LIB_PRINT__LOADED-false}"; then
        print_error '%s.sh: pkg %s.sh not available' "${name}" "${pkg}"
      else
        printf '%s.sh: error: pkg %s.sh not available\n' "${name}" "${pkg}" >&2
      fi
      exit $((EX_UNAVAILABLE))
    fi
  done
}

export __SHELI_LIB_DUMMY__LOADING=false
export __SHELI_LIB_DUMMY__LOADED=true

