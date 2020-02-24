#!/bin/dash

"${__SHELI__LOADED-false}" && return   # If loaded, do not load again
"${__SHELI__LOADING-false}" && exit 70 # If stuck loading, something is wrong

export __SHELI__LOADING=true

# Copy of stdout to permit function to return values AND print in stdout
exec 8<&1

# We can now return values just like this:
#funct() {
#  printf 'stdout\n'
#  printf 'stderr\n' >&2
#  printf 'value' >&9
#} 9>&1 >&8
#var="$(funct)"
# This allows us to print in stdout AND assign a value to a var

sheli__main() {
  __argparse__parse "${@}"
  "${help}" && __argparse__help
  "${usage}" && __argparse__usage
  local font=false
  case "${color}" in
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
      "${PIPED}" && font=false
      ;;
    always)
      font=true
      ;;
  esac
  "${font}" && __font__enable || __font__disable
  __argparse__args
  # we need to adjust parameters according to positional arguments
  #FIXME? there is something better than eval, here?
  eval set -- "'$(printf '%s' "${args%?}" | sed -e "s/'/'\\\\&'/g" -e "s/${ifs}/' '/g")'"
  print_debug '%s initiated %s as : %s' "${BIN_NAME}" "$(date)" "${CMD}"
  if command -v main >/dev/null; then
    main "${@}" || return "${?}"
  else
    print_error 'main() function is missing.'
    exit $((EX_SOFTWARE))
  fi
}

__sheli__load() {
  export __SHELI_LIB__LOADING='sheli'

  if [ -z "${SHELI_DIR}" ]; then
    printf '%s.sh: error: var $SHELI_DIR not set\n' "${__SHELI_LIB__LOADING}" >&2
    return 70
  elif ! [ -f "${SHELI_DIR}/sheli.sh" ]; then
    printf '%s.sh: error: var $SHELI_DIR not properly set\n' "${__SHELI_LIB__LOADING}" >&2
    return 70
  fi
  # From here, we should know the root folder of sheli

  # We can now start to import some things...
  # Let's start with core libraries
  # We should consider core libraries those libs that will make sheli startup correctly
  # Without this libs, the whole framework should not work.
  export __SHELI_CORE_DIR="${SHELI_DIR}/core"

  . "${__SHELI_CORE_DIR}/magic.sh" # Using some magic to provide an initial environment
  # From here, we should have shell options and many environment vars set
  . "${__SHELI_CORE_DIR}/trap.sh"
  # From here, we can declare functions like ctrl_c(), quit(), stop() and die()
  . "${__SHELI_CORE_DIR}/dep.sh"
  . "${__SHELI_CORE_DIR}/font.sh"
  . "${__SHELI_CORE_DIR}/print.sh"

  # Loading essentials libs
  # We should consider essentials libraries those libs that make sheli work as intended
  # This libs can be potentially divided from sheli with some adjustments
  export __SHELI_ESS_DIR="${SHELI_DIR}/ess"

  #FIXME? should be considered core?
  . "${__SHELI_ESS_DIR}/debug.sh"
  . "${__SHELI_ESS_DIR}/argparse.sh"

  # Loading utilities libs
  # We should consider utility libraries those libs that make easier the life of the programmer
  # This libs can be potentially deleted without any issues
  # Here is where more libs can be added in the framework
  export __SHELI_UTIL_DIR="${SHELI_DIR}/util"

  . "${__SHELI_UTIL_DIR}/override.sh"
  . "${__SHELI_UTIL_DIR}/test.sh"
  . "${__SHELI_UTIL_DIR}/uptime.sh"
}

__sheli__load "${@}" || exit "${?}"
export __SHELI__LOADING=false
export __SHELI__LOADED=true

