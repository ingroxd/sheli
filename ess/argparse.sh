#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  printf 'This library is intended to be imported by sheli.\n' >&2
  exit 69
fi
# If we are here, we have all the sheli env

"${__SHELI_LIB_ARGPARSE__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_ARGPARSE__LOADING-false}" && exit $((EX__SOFTWARE)) # If loading, something is wrong

export __SHELI_LIB_ARGPARSE__LOADING=true

########################################
# This library emulates python argparse
# It is not a complete solution and it should not be implemented in the same way...
# Bash is slow, you know? lol
# This is why this library will make use of "global" vars between functions without them being
#   explicitly declared as so.
########################################

__argparse__print_error() {
  local str="${1}"; shift
  print_error "%s: argparse: ${str}" "${BIN_NAME}" "${@}"
}

__argparse__err__bad_attr() {
  local name="${1}"; shift
  local attr="${1}"; shift
  local action="${1}"; shift
  __argparse__print_error '%s: %s cannot be set for action %s' "${name}" "'${attr}'" "'${action}'"
  exit $((EX_DATAERR))
}

__argparse__err__bad_attr_positional() {
  local name="${1}"; shift
  local attr="${1}"; shift
  __argparse__print_error '%s: %s cannot be set for positional arguments' "${name}" "'${attr}'"
  exit $((EX_DATAERR))
}

argparse__description() {
  export ARGPARSE__DESCRIPTION="${*}"
}

argparse__synopsis() {
  export ARGPARSE__SYNOPSIS="${*}"
}

########################################
# Adds an argument to the parser to be managed
#   $name is the equivalent of 'dest' in python argparse
#   $flags is the equivalent of all the -* arguments in python argparse
#   $required can be 'true' or 'false'
#   $metavar is mostly the equivalent of 'metavar' in python argparse
#   $action can be 'count', 'store', 'store_true' and 'store_false'
#   $nargs can be '?' or a positive integer
#TODO? Implement nargs = *
#   $const can be one of $choices values
#   $default can be one of $choices values
#   $choices contains all the possible values (divided by comma):
#      = $NULL, any value is allowed
#   $usage_ can be 'true' or 'false' and specify if it should be printed in the usage message
#   $help_ contains the help message for the argument:
#      = '' means no message; = $NULL means hide argument
########################################
argparse__add_argument() {
  # Parse the attributes and locally initialize them
  local attr
  for attr; do
    if [ "${attr%%=*}" = 'help' ] || [ "${attr%%=*}" = 'usage' ]; then
      attr="${attr%%=*}_=${attr#*=}"
    fi
    case "${attr}" in
      name=*\
      |flags=*\
      |required=*\
      |metavar=*\
      |action=*\
      |nargs=*\
      |const=*\
      |default=*\
      |choices=*\
      |usage_=*\
      |help_=*)
        if set | grep -e "^${attr%%=*}\\(=.*\\)\\?$" >/dev/null; then
          __argparse__print_error 'attribute %s already set' "'${attr%%=*}'"
          exit $((EX_DATAERR))
        else
          local "${attr}"
        fi
        ;;
      *)
        __argparse__print_error '%s is not a valid attribute' "'${attr%%=*}'"
        exit $((EX_DATAERR))
        ;;
    esac
  done

  # Finish initialize all the attrs
  local name="${name-"${NULL}"}" \
    flags="${flags-}" \
    required="${required-"${NULL}"}" \
    metavar="${metavar-"${NULL}"}" \
    action="${action-store}" \
    nargs="${nargs-"${NULL}"}" \
    const="${const-"${NULL}"}" \
    default="${default-"${NULL}"}" \
    choices="${choices-"${NULL}"}" \
    usage_="${usage_-true}" \
    help_="${help_-}"

  # Check if name is set
  if [ "${name}" = "${NULL}" ]; then
    __argparse__print_error 'every argument must have the attribute %s' "'name'"
    exit $((EX_DATAERR))
  fi
  # python argparse uses flags in order to set dest (here called name); this is intentionally avoided

  # Check if option already exists
  if printf '%s' "${ARGPARSE__ARGUMENTS}" | grep -e "^${name}${ifs}" >/dev/null; then
    __argparse__print_error 'option %s already exists' "'${name}'"
    exit $((EX_DATAERR))
  fi

  #TODO Check if flags already exist

  ####################
  # Apply standard value if not set
  ####################
  if [ "${required}" = "${NULL}" ]; then
    [ -n "${flags}" ] && required=false || required=true
  fi

  if [ "${metavar}" = "${NULL}" ]; then
    if [ -n "${flags}" ]; then # If we have flags
      local flag
      for flag in $(printf '%s' "${flags}" | tr ',' ' '); do
        flag="${flag#-}"
        metavar="${flag#-}"
        [ "${#metavar}" -gt 1 ] && break # Set with the first long flag (if there is any)
      done
    else
      metavar="${name}"
    fi
  fi
  metavar="$(printf '%s' "${metavar}" | tr '[:lower:]' '[:upper:]')"

#  if [ "${action}" = "${NULL}" ]; then
#    action='store'
#    #[ "${nargs}" = "${NULL}" ] && nargs=1
#  fi

  if [ "${nargs}" = '?' ] && [ "${const}" = "${NULL}" ]; then
    __argparse__print_error "%s: attribute 'const' must be set with 'nargs' = '?'" "${name}"
    exit $((EX_DATAERR))
  fi

  if [ "${usage_}" != true ] && [ "${usage_}" != false ]; then
    __argparse__print_error "%s: attribute 'usage' can only be 'true' or 'false'" "${name}"
    exit $((EX_DATAERR))
  fi

  # Some more check for arguments without flags
  if [ -z "${flags}" ]; then
    # 'required' must be = 'true' for positionals
    [ "${required}" != true ] && __argparse__err__bad_attr_positional "${name}" 'required'
    # 'action' must be = 'store' for positionals
    [ "${action}" != 'store' ] && __argparse__err__bad_attr_positional "${name}" 'action'
    # 'const' must be = '$NULL' for positionals
    [ "${const}" != "${NULL}" ] && __argparse__err__bad_attr_positional "${name}" 'const'
  fi

  # Check on attributes based on action
  case "${action}" in
    count)
      # nargs = 0
      [ "${nargs}" = "${NULL}" ] && nargs=0
      [ "${nargs}" != 0 ] && __argparse__err__bad_attr "${name}" 'nargs' "${action}"
      # const = $NULL
      [ "${const}" != "${NULL}" ] && __argparse__err__bad_attr "${name}" 'const' "${action}"
      # default = 0
      [ "${default}" = "${NULL}" ] && default=0
      [ "${default}" != 0 ] && __argparse__err__bad_attr "${name}" 'default' "${action}"
      # choices = $NULL
      [ "${choices}" != "${NULL}" ] && __argparse__err__bad_attr "${name}" 'choices' "${action}"
      ;;
    store)
      # nargs = ? || int > 0
      [ "${nargs}" = "${NULL}" ] && nargs=1
      if printf '%i' "${nargs}" >/dev/null 2>&1 && [ "${nargs}" -le 0 ] 2>/dev/null \
        || ! printf '%i' "${nargs}" >/dev/null 2>&1 && [ "${nargs}" != '?' ]; then
        __argparse__print_error '%s: %s can only be a positive integer or %s for action %s' \
          "${name}" "'nargs'" "'?'" "${action}"
        exit $((EX_DATAERR))
      fi
      # const = *
      # default = * (no default needed if 'nargs' != '?')
      # choices = *
      ;;
    store_true)
      # nargs = 0
      [ "${nargs}" = "${NULL}" ] && nargs=0
      [ "${nargs}" != 0 ] && __argparse__err__bad_attr "${name}" 'nargs' "${action}"
      # const = true
      [ "${const}" = "${NULL}" ] && const=true
      [ "${const}" != true ] && __argparse__err__bad_attr "${name}" 'const' "${action}"
      # default = false
      [ "${default}" = "${NULL}" ] && default=false
      [ "${default}" != false ] && __argparse__err__bad_attr "${name}" 'default' "${action}"
      # choices = true,false
      [ "${choices}" = "${NULL}" ] && choices='true,false'
      [ "${choices}" != 'true,false' ] && __argparse__err__bad_attr "${name}" 'choices' "${action}"
      ;;
    store_false)
      # nargs = 0
      [ "${nargs}" = "${NULL}" ] && nargs=0
      [ "${nargs}" != 0 ] && __argparse__err__bad_attr "${name}" 'nargs' "${action}"
      # const = false
      [ "${const}" = "${NULL}" ] && const=false
      [ "${const}" != false ] && __argparse__err__bad_attr "${name}" 'const' "${action}"
      # default = false
      [ "${default}" = "${NULL}" ] && default=true
      [ "${default}" != true ] && __argparse__err__bad_attr "${name}" 'default' "${action}"
      # choices = true,false
      [ "${choices}" = "${NULL}" ] && choices='true,false'
      [ "${choices}" != 'true,false' ] && __argparse__err__bad_attr "${name}" 'choices' "${action}"
      ;;
  esac

  # Check if 'default' and 'const' are valid choices
  if [ "${choices}" != "${NULL}" ]; then
    if [ "${default}" != "${NULL}" ]; then
      if ! printf '%s' "${choices}" | grep -e "\(^\|,\)${default}\(,\|$\)" >/dev/null; then
        __argparse__print_error '%s: default value %s not valid (%s)' \
          "${name}" "'${default}'" "${choices}"
        exit $((EX_DATAERR))
      fi
    fi
    if [ "${const}" != "${NULL}" ]; then
      if ! printf '%s' "${choices}" | grep -e "\(^\|,\)${const}\(,\|$\)" >/dev/null; then
        __argparse__print_error '%s: const value %s not valid (%s)' \
          "${name}" "'${const}'" "${choices}"
        exit $((EX_DATAERR))
      fi
    fi
  fi

  # define a local argument to be exported
  local argument=''
  argument="$(printf "%s${ifs}" "${name}" "${flags}" "${required}" "${metavar}" \
    "${action}" "${nargs}" "${const}" "${default}" "${choices}" "${usage_}" "${help_}")"
  # add a trailing new line
  argument="$(printf '%s\n_' "${argument}")"
  argument="${argument%?}"

  export ARGPARSE__ARGUMENTS="${ARGPARSE__ARGUMENTS}${argument}"
}

########################################
# checks if all the positional arguments are satisfied
########################################
__argparse__args() {
  local value=''
  local name flags required metavar action nargs const default choices usage_ help_
  while IFS="${ifs}" read -r \
    name flags required metavar action nargs const default choices usage_ help_; do
    if [ -z "${flags}" ]; then
      if [ -n "${args}" ]; then
        value="${args%%${ifs}*}"
        __argparse__parse_checkchoices
        export "${name}=${value}"
        export args="${args#*${ifs}}"
      else
        __argparse__usage
        __argparse__print_error 'too few arguments'
        exit $((EX_USAGE))
      fi
    fi
  done <<EOF
${ARGPARSE__ARGUMENTS%?}
EOF
}

########################################
# sets all the optional arguments that were not used
########################################
__argparse__initunset() {
  local name flags required metavar action nargs const default choices usage_ help_
  while IFS="${ifs}" read -r \
    name flags required metavar action nargs const default choices usage_ help_; do
    if ! set | grep -e "^${name}\\(=.*\\)\\?$" >/dev/null; then
      export "${name}=${default}" # default should always be set
    fi
  done <<EOF
${ARGPARSE__ARGUMENTS%?}
EOF
}

########################################
# (Auxiliary) checks if a value is a valid choice
########################################
__argparse__parse_checkchoices() {
  if [ "${choices}" != "${NULL}" ]; then
    if ! printf '%s' "${choices}" | grep -e "\\(^\\|,\\)${value}\\(,\\|$\\)" >/dev/null; then
      __argparse__print_error 'argument %s: invalid choice: %s (choose from %s)' \
        "$(printf '%s' "${flags}" | sed -e 's|,|/|')" "${value}" \
        "$(printf '%s' "'${choices}'" | sed -e "s/,/'& '/g")"
      exit $((EX_USAGE))
    fi
  fi
}

########################################
# Parses all the arguments passed to the program and checks if they are good options or not
# In a second phase, what is not an optional argument will be checked against positional arguments
########################################
__argparse__parse() {
  export args=''

  local validopt
  local name flags required metavar action nargs const default choices usage_ help_
  local param param_ # we will use $param_ for short options
  while [ "${#}" -gt 0 ]; do
    param="${1}"; shift
    param_=''
    # Deleting a '-' because we manually add it recovering $param_
    while [ -n "${param#-}" ]; do
      # if short option
      if [ -z "${param##-[0-9A-Za-z]*}" ] && [ -n "${param##--[0-9A-Za-z]*}" ]; then
        param_="${param#-?}"        # save spare letters
        param="${param%"${param_}"}" # and evaluate the first
      fi
      case "${param}" in
        --)
          export args="${args}$(printf "%s${ifs}" "${@}")"
          shift "${#}"
          ;;
        -*)
          validopt=false
          while IFS="${ifs}" read -r \
            name flags required metavar action nargs const default choices usage_ help_; do
            if printf '%s' "${flags}" | grep -e "\\(^\\|,\\)${param}\\(,\\|$\\)" >/dev/null; then
              validopt=true
              case "${action}" in
                count)
                  ! set | grep -e "^${name}\\(=.*\\)\\?$" >/dev/null && export "${name}=0"
                  export "${name}=$((${name} + 1))"
                  ;;
                store) # we should always have at least a var to store
                  # python argparse always fail if not on choices
                  local value='' value_=''
                  if [ -n "${param_}" ]; then # if we have spare letters
                    value="${param_}"         # threat them as input value
                    value_='set'
                    param_=''                 # and flus them
                  else
                    value="${1-"${NULL}"}"    # use next parameter
                    if [ "${value}" != "${NULL}" ]; then # if usable
                      value_='set'
                      shift
                    fi
                  fi
                  case "${nargs}" in
                    '?')
                      if [ "${value_}" = 'set' ]; then # if I have a set value
                        __argparse__parse_checkchoices # check it
                        export "${name}=${value}"      # and use it
                      else
                        export "${name}=${const}"
                      fi
                      ;;
                    [1-9]*)
                      local nargs_=$((nargs))
                      if [ "${value_}" = 'set' ]; then
                        __argparse__parse_checkchoices
                        value_="${value}${ifs}"
                        nargs_=$((nargs_ - 1))
                      fi
                      while [ $((nargs_)) -gt 0 ]; do
                        value="${1-"${NULL}"}"
                        if [ "${value}" = "${NULL}" ]; then
                          __argparse__print_error 'argument %s: expected %i argument(s)' \
                            "'${name}'" $((nargs))
                          exit $((EX_USAGE))
                        fi
                        shift
                        __argparse__parse_checkchoices
                        value_="${value_}${value}${ifs}"
                        nargs_=$((nargs_ - 1))
                      done
                      export "${name}=${value_%?}"
                      ;;
                    *)
                      print_error 'IMPOSSIBRU!'
                      exit $((EX_DATAERR))
                      ;;
                  esac
                  ;;
                store_true|store_false)
                  export "${name}=${const}" # const should always be set
                  ;;
              esac
            fi
          done <<EOF
${ARGPARSE__ARGUMENTS%?}
EOF
          if ! "${validopt}"; then
            __argparse__print_error 'unrecognized argument: %s' "${param}"
            exit $((EX_USAGE))
          fi
          ;;
        *)
          export args="${args}${param}${ifs}"
          ;;
      esac
      param="-${param_}" # if we didn't use spare letters, recover them
    done
  done
  __argparse__initunset
}

__argparse__usage() {
  printf 'usage: %s' "${BIN_NAME}"

  local roptargs='' rposargs='' uoptargs='' arg=''

  local name flags required metavar action nargs const default choices usage_ help_
  while IFS="${ifs}" read -r \
    name flags required metavar action nargs const default choices usage_ help_; do
    arg=''
    if [ "${help_}" != "${NULL}" ] && "${usage_}"; then
      if [ -n "${flags}" ]; then
        arg="${flags%%,*}"
        if [ "${action}" = 'store' ]; then
          if [ "${choices}" = "${NULL}" ]; then
            if [ "${nargs}" = '?' ]; then
              arg="${arg} [${metavar}]"
            else
              arg="${arg} ${metavar}"
            fi
          else
            if [ "${nargs}" = '?' ]; then
              arg="${arg} [{${choices}}]"
            else
              arg="${arg} {${choices}}"
            fi
          fi
        fi
        if "${required}"; then
          roptargs="${roptargs} ${arg}"
        else
          arg="[${arg}]"
          uoptargs="${uoptargs} ${arg}"
        fi
      else
        if [ "${choices}" = "${NULL}" ]; then
          arg="${metavar}"
        else
          arg="{${choices}}"
        fi
        rposargs="${rposargs} ${arg}"
      fi
    fi
  done <<EOF
${ARGPARSE__ARGUMENTS%?}
EOF

  printf '%s%s%s\n' "${uoptargs}" "${roptargs}" "${rposargs}"

  #TODO Check on $usage flag
  #"${usage}" && exit $((EX_OK))
}

__argparse__help() {
  ####################
  # Things the help message should contains are (sorted):
  # usage
  # description
  # positional arguments
  # optional arguments
  # synopsis
  ####################

  local tab=3

  __argparse__usage
  printf '%b' '\n'

  if [ "${ARGPARSE__DESCRIPTION:-"${NULL}"}" != "${NULL}" ]; then
    printf '%s\n' "${ARGPARSE__DESCRIPTION}"
    printf '%b' '\n'
  fi

  local firstpos=true
  local name flags required metavar action nargs const default choices usage_ help_
  while IFS="${ifs}" read -r \
    name flags required metavar action nargs const default choices usage_ help_; do
    if [ "${help_}" != "${NULL}" ]; then
      if [ -z "${flags}" ]; then
        if "${firstpos}"; then
          printf 'Positional arguments:\n'
          firstpos=false
        fi
        printf '%*s' $((tab)) ''
        printf '%s\n' "${metavar}"
        if [ -n "${help_}" ]; then # already not $NULL
          printf '%*s' $((2 * tab)) ''
          printf '%s\n' "${help_}"
        fi
        if [ "${action}" = 'store' ]; then
          if [ "${choices}" != "${NULL}" ]; then
            printf '%*s' $((2 * tab)) ''
            printf '%s is %s\n' "${metavar}" "'${choices}'" | sed -e "s/\(.*\),/\1' or '/" -e "s/,/', '/g"
          fi
          if [ "${nargs}" = '?' ] && [ "${const}" != "${NULL}" ]; then
              printf '%*s' $((2 * tab)) ''
              printf 'If %s is omitted, value %s is used by default\n' "${metavar}" "'${const}'"
          fi
        fi
      fi
    fi
  done <<EOF
${ARGPARSE__ARGUMENTS%?}
EOF

  local firstopt=true
  local name flags required metavar action nargs const default choices usage_ help_
  while IFS="${ifs}" read -r \
    name flags required metavar action nargs const default choices usage_ help_; do
    if [ "${help_}" != "${NULL}" ]; then
      if [ -n "${flags}" ]; then
        if "${firstopt}"; then
          ! "${firstpos}" && printf '%b' '\n'
          printf 'Optional arguments:\n'
          firstopt=false
        fi
        printf '%*s' $((tab)) ''
        [ "${nargs}" = '?' ] && metavar="[${metavar}]"
        if [ "${action}" = 'store' ]; then
          printf '%s ' "${flags}" | sed -e "s/,/ ${metavar}, /g"
          printf '%s\n' "${metavar}"
        else
          printf '%s\n' "${flags}" | sed -e "s/,/, /g"
        fi
        if [ -n "${help_}" ]; then
          printf '%*s' $((2 * tab)) ''
          printf '%s\n' "${help_}"
        fi
        if [ "${action}" = 'store' ]; then
          if [ "${choices}" != "${NULL}" ]; then
            printf '%*s' $((2 *tab)) ''
            printf '%s is %s\n' "${metavar}" "'${choices}'" | sed -e "s/\(.*\),/\1' or '/" -e "s/,/', '/g"
          fi
          if [ "${default}" != "${NULL}" ]; then
            printf '%*s' $((2 * tab)) ''
            printf 'If the option is omitted, value %s is used by default\n' "'${default}'"
          fi
          if [ "${nargs}" = '?' ]; then
            if [ "${const}" != "${NULL}" ]; then
              printf '%*s' $((2 * tab)) ''
              printf 'If %s is omitted, value %s is used by default\n' "${metavar}" "'${const}'"
            fi
          fi
        fi
      fi
    fi
  done <<EOF
${ARGPARSE__ARGUMENTS%?}
EOF

  if [ "${ARGPARSE__SYNOPSIS:-"${NULL}"}" != "${NULL}" ]; then
    if ! "${firstopt}" || ! "${firstpos}"; then
      printf '%b' '\n'
    fi
    printf '%s\n' "${ARGPARSE__SYNOPSIS}"
  fi

  #TODO Check on $help flag
  if "${help}"; then
    exit $((EX_OK))
  else
    exit $((EX_USAGE))
  fi
}

__argparse__load() {
  export __SHELI_LIB__LOADING='argparse'

  export ARGPARSE__ARGUMENTS=''

  # Always include option --help and usage
  argparse__add_argument name='help' flags='--help' action='store_true' usage=false \
    help='Show this help message and exit'
  argparse__add_argument name='usage' flags='--usage' action='store_true' help="${NULL}"
  # help = $NULL means that the options will not be shown in help message
  argparse__add_argument name='color' flags='--color' metavar='when' nargs='?' \
    const='auto' default='auto' choices='never,auto,always' usage=false
  # usage = false means that the options will not be shown in usage message

  argparse__description "${NULL}" # No description
  argparse__synopsis 'Remember, remember! The fifth of November, The Gunpowder treason and plot; I know of no reason why the Gunpowder treason should ever be forgot!'

  unset __SHELI_LIB__LOADING
}

__argparse__load "${@}" || exit "${?}"
export __SHELI_LIB_ARGPARSE__LOADING=false
export __SHELI_LIB_ARGPARSE__LOADED=true

