#!/bin/bash

"${__SHELI__LOADED-false}" && return      # If loaded, do not load again
"${__SHELI__LOADING-false}" && return 70  # If stuck loading, something is wrong

export __SHELI__LOADING=true

# Copy of stdout to permit functions to both return values and print in stdout
exec 8<&1

####################
# XXX
# It is possible to return values like this:
# funct() {
#   printf 'stdout\n'
#   printf 'stderr\n' >&2
#   printf 'value\n' >&9
# } 9>&1 >&8
# var="$(funct)"
####################

########################################
# print__error()
# Fallback substitute of print.print__error
########################################
if ! command -v print__error >/dev/null; then
  print__error() {
    printf '%s: error: ' "${BIN_NAME}" >&2
    printf "${@}" >&2
    printf '%b' '\n'
  }
fi

########################################
# sheli__main()
# Everything starts from here
########################################
sheli__main() {
  argparse__parse "${@}"
  if "${usage}"; then
    argparse__usage && return "${EX_OK}"
  fi
  if "${help}"; then
    argparse__help && return "${EX_OK}"
  fi
  font__set "${color}"
  argparse__args
  args="$(printf '%s' "${args%?}" | sed -e "s/'/'\\\\&'/g")"
  # FIXME? Is there something better than eval?
  eval set -- "$(printf '%s' "${args:+"'${args}'"}" | sed -e "s/\\${FS}/' '/g")"
  if command -v print__debug >/dev/null; then
    print__debug '%s initiated %s as: %s' "${BIN_NAME}" "$(date)" "${CMD}"
  fi
  if command -v main >/dev/null; then         # Check if main exists
    main "${@}" || return "${?}"
  else                                        # if not
    print__error 'main() function is missing.'
    exit "${EX_SOFTWARE}"                     # error
  fi
  if command -v print__debug >/dev/null; then
    print__debug '%s ended %s' "${BIN_NAME}" "$(date)"
  fi
}

########################################
# __sheli__import_core()
# Import all the core libraries
########################################
__sheli__import_core() {
  # Core libraries are those libs that make sheli boot properly
  local sheli_core_dir="${SHELI_DIR}/core"
  . "${sheli_core_dir}/sysexits.sh"
  . "${sheli_core_dir}/behaviour.sh"
  . "${sheli_core_dir}/magic.sh"
  . "${sheli_core_dir}/trap.sh"
  . "${sheli_core_dir}/dep.sh"
  . "${sheli_core_dir}/font.sh"
}

########################################
# __sheli__import_ess()
# Import all the essential libraries
########################################
__sheli__import_ess() {
  # Essential libraries are those libs that make sheli work as intended
  local sheli_ess_dir="${SHELI_DIR}/ess"
  . "${sheli_ess_dir}/debug.sh"
  . "${sheli_ess_dir}/print.sh"
  . "${sheli_ess_dir}/argparse.sh"
  . "${sheli_ess_dir}/time.sh"
}

########################################
# __sheli__import_util()
# Import all the utility libraries
########################################
__sheli__import_util() {
  # Utility libraries are those libs that add features to sheli
  local sheli_util_dir="${SHELI_DIR}/util"
  . "${sheli_util_dir}/test.sh"
  . "${sheli_util_dir}/math.sh"
  . "${sheli_util_dir}/config.sh"
  . "${sheli_util_dir}/cast.sh"
  . "${sheli_util_dir}/override.sh"
}

__sheli__load() {
  export __SHELI_LIB__LOADING='sheli'
  local EX_SOFTWARE_=70
  # Check sheli root folder
  if [ -z "${SHELI_DIR}" ]; then
    printf '%s: error: var $SHELI_DIR not set\n' "${__SHELI_LIB__LOADING}.sh" >&2
    return "${EX_SOFTWARE_}"
  elif ! [ -f "${SHELI_DIR}/sheli.sh" ]; then
    printf '%s: error: var $SHELI_DIR not properly set\n' "${__SHELI_LIB__LOADING}.sh" >&2
    return "${EX_SOFTWARE_}"
  fi
  # From now on, sheli root folder is known
  # Need to import some things...
  __sheli__import_core "${@}"
  # From now on, it is possible to declare:
  # trap__int()
  # trap__quit()
  # trap__term()
  # trap__cleanup()
  # trap__die()
  __sheli__import_ess
  # From now on, it is possible to declare arguments like python's argparse
  # XXX
  # argparse__add_argument name='varname' choices='value1,value2'
  # argparse__add_argument name='varname' nargs=? const='value1'
  # argparse__add_argument name='varname' action='store_true'
  __sheli__import_util
  unset __SHELI_LIB__LOADING
}

__sheli__load "${@}" || exit "${?}"
export __SHELI__LOADING=false
export __SHELI__LOADED=true

