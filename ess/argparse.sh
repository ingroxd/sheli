#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_ARGPARSE__LOADED-false}" && return                 # If loaded, do nothing
"${__SHELI_LIB_ARGPARSE__LOADING-false}" && exit "${EX_SOFTWARE}" # If loading, something is wrong

export __SHELI_LIB_ARGPARSE__LOADING=true

########################################
# XXX
# This lib emulates python's argparse
# It is not a complete solution and it is not implemented in the same way
# Bash is slow, you know?
# This is why this lib makes use of "global" vars
########################################

########################################
# __argparse__print_error()
# Print error with lib suffix
########################################
__argparse__print_error() {
  local str="${1}"; shift
  print__error "%s: argparse: ${str}" "${BIN_NAME}" "${@}"
}

########################################
# __argparse__err__bad_attr()
# Throw error for bad attribute value
########################################
__argparse__err__bad_attr() {
  local name="${1}"; shift
  local attr="${1}"; shift
  local action="${1}"; shift
  __argparse__print_error '%s: %s cannot be set for action %s' "${name}" "'${attr}'" "'${action}'"
  exit "${EX_DATAERR}"
}

########################################
# __argparse__err__bad_attr_positional()
# Throw error for bad attribute value in positional arguments
########################################
__argparse__err__bad_attr_positional() {
  local name="${1}"; shift
  local attr="${1}"; shift
  __argparse__print_error '%s: %s cannot be set for positional arguments' "${name}" "'${attr}'"
  exit "${EX_DATAERR}"
}

########################################
# __argparse__initunset()
# Init unset arguments
########################################
__argparse__initunset() {
  local name flags required metavar action nargs const default choices usage_ help_
  while IFS="${FS}" read -r \
    name flags required metavar action nargs const default choices usage_ help_; do
    if ! set | grep -e "^${name}\\(=.*\\)\\?$" >/dev/null; then
      export "${name}=${default}" # default should always be set
    fi
  done <<EOF
${ARGPARSE__ARGUMENTS%?}
EOF
}

########################################
# __argparse__parse_checkchoices()
# Check if a value is a valid choice
# Auxiliary; use "global" vars:
#   $choices
#   $value
#   $flags
########################################
__argparse__parse_checkchoices() {
  if [ "${choices}" != "${NULL}" ]; then
    if ! printf '%s' "${choices}" | grep -e "\\(^\\|,\\)${value}\\(,\\|$\\)" >/dev/null; then
      __argparse__print_error 'argument %s: invalid choice: %s (choose from %s)' \
        "'${name}'" "'${value}'" "$(printf '%s' "'${choices}'" | sed -e "s/,/'& '/g")"
      exit "${EX_USAGE}"
    fi
  fi
}

########################################
# argparse__add_argument()
# Add an argument to the parser
# This is a comparison with python argparse
#   $name = dest
#   $flags = -*
#   $required = required (true|false)
#   $metavar ~= metavar
#   $action = action (count|store|store_true|store_false)
#   $nargs = nargs (?) TODO? $nargs = *
#   $const = const (value must be in $choices, if set)
#   $default = default (value must be in $choices, if set)
#   $choices = choices (comma separated list)
#   $usage_ (true|false) Suggest if the options must figure in the usage
#   $help_ Suggest the help message
#     '' = no message; $NULL = hide argument
########################################
argparse__add_argument() {
  # Parse the attributes and locally initialize them
  local name flags required metavar action nargs const default choices usage_ help_
  local attr value
  for attr; do
    value="${attr#*=}"
    attr="${attr%%=*}"
    case "${attr}" in help|usage) attr="${attr}_" ;; esac
    case "${attr}" in
      name\
      |flags\
      |required\
      |metavar\
      |action\
      |nargs\
      |const\
      |default\
      |choices\
      |usage_\
      |help_)
        if ! set | grep -e "^${attr}\\(=.*\\)\\?$" >/dev/null; then
          local "${attr}=${value}"
        else
          __argparse__print_error 'attribute %s already set' "'${attr}'"
          exit "${EX_DATAERR}"
        fi
        ;;
      *)
        __argparse__print_error '%s is not a valid attribute' "'${attr}'"
        exit "${EX_DATAERR}"
        ;;
    esac
  done

  ####################
  # XXX
  # Python's argparse use flags to set 'dest' (here explicitly called 'name')
  # This is intentionally avoided
  ####################
  if [ "${name-"${NULL}"}" = "${NULL}" ]; then
    __argparse__print_error 'every arument must have the attribute %s' "'name'"
    exit "${EX_DATAERR}"
  fi

  if [ "${flags-"${NULL}"}" = "${NULL}" ]; then
    flags="${NULL}"
  fi


  if [ "${required-"${NULL}"}" = "${NULL}" ]; then
    if [ "${flags}" = "${NULL}" ]; then
      required=true
    else
      required=false
    fi
  else
    case "${required}" in true|false) :;;
      *)
        __argparse__print_error '%s must be true or false' "'required'"
        exit "${EX_DATAERR}"
        ;;
    esac
  fi

  if [ "${metavar-"${NULL}"}" = "${NULL}" ]; then
    if [ "${flags}" != "${NULL}" ]; then
      # Set the first long flag (if there is any)
      local flag
      for flag in $(printf '%s' "${flags}" | tr ',' ' '); do
        flag="${flag#-}"
        metavar="${flag#-}"
        # FIXME? If the user set a custom $NULL starting with '-', it will fail
        [ "${metavar}" != "${NULL}" ] && [ "${#metavar}" -gt 1 ] && break
      done
    else
      # $name can't be null
      metavar="${name}"
    fi
  fi

  if [ "${action-"${NULL}"}" = "${NULL}" ]; then
    action='store'
  fi

  if [ "${nargs-"${NULL}"}" = "${NULL}" ]; then
    nargs="${NULL}"
  fi

  if [ "${const-"${NULL}"}" = "${NULL}" ]; then
    const="${NULL}"
    if [ "${nargs}" = '?' ]; then
      __argparse__print_error "%s: attribute 'const' must be set with 'nargs' = '?'" "${name}"
      exit "${EX_DATAERR}"
    fi
  fi

  if [ "${default-"${NULL}"}" = "${NULL}" ]; then
    default="${NULL}"
  fi

  if [ "${choices-"${NULL}"}" = "${NULL}" ]; then
    choices="${NULL}"
  fi

  if [ "${usage_-"${NULL}"}" = "${NULL}" ]; then
    usage_=true
  else
    case "${usage_}" in true|false) :;;
      *)
        __argparse__print_error '%s must be true or false' "'usage'"
        exit "${EX_DATAERR}"
        ;;
    esac
  fi

  if [ -z "${help_-}" ]; then
    help_=''
  fi
  # From now on, we have all the attributes of the argument set

  # Checks for arguments w/o flags
  if [ "${flags}" = "${NULL}" ]; then
    # $required = true
    ! "${required}" && __argparse__err__bad_attr_positional "${name}" 'required'
    # $nargs = $NULL
    [ "${nargs}" != "${NULL}" ] && __argparse__err__bad_attr_positional "${name}" 'nargs'
    # $action = store
    [ "${action}" != 'store' ] && __argparse__err__bad_attr_positional "${name}" 'action'
    # $const = $NULL
    [ "${const}" != "${NULL}" ] && __argparse__err__bad_attr_positional "${name}" 'const'
    # $default = $NULL
    [ "${default}" != "${NULL}" ] && __argparse__err__bad_attr_positional "${name}" 'default'
  fi

  # $action based checks
  case "${action}" in
    count)
      # $required = false
      "${required}" &&  __argparse__err__bad_attr "${name}" 'required' "${action}"
      # $nargs = 0
      [ "${nargs}" = "${NULL}" ] && nargs=0
      [ "${nargs}" != 0 ] && __argparse__err__bad_attr "${name}" 'nargs' "${action}"
      # $const = $NULL
      [ "${const}" != "${NULL}" ] && __argparse__err__bad_attr "${name}" 'const' "${action}"
      # $default = 0
      [ "${default}" = "${NULL}" ] && default=0
      [ "${default}" != 0 ] && __argparse__err__bad_attr "${name}" 'default' "${action}"
      # $choices = $NULL
      [ "${choices}" != "${NULL}" ] && __argparse__err__bad_attr "${name}" 'choices' "${action}"
      ;;
    store)
      # nargs = ? || int > 0
      [ "${nargs}" = "${NULL}" ] && nargs=1
      if printf '%i' "${nargs}" >/dev/null 2>&1; then
        if [ "${nargs}" -le 0 ]; then 
          __argparse__print_error '%s: %s must be a positive integer or %s for action %s' \
            "${name}" "'nargs'" "'?'" "'store'"
          exit "${EX_DATAERR}"
        fi
      else
        if [ "${nargs}" != '?' ]; then
          __argparse__print_error '%s: %s must be a positive integer or %s for action %s' \
            "${name}" "'nargs'" "'?'" "'store'"
          exit "${EX_DATAERR}"
        fi
      fi
      # $const = *
      # $default = * ($default will be ignored if $nargs != ?)
      # $choices = *
      ;;
    store_true)
      # $required = false
      "${required}" &&  __argparse__err__bad_attr "${name}" 'required' "${action}"
      # $nargs = 0
      [ "${nargs}" = "${NULL}" ] && nargs=0
      [ "${nargs}" != 0 ] && __argparse__err__bad_attr "${name}" 'nargs' "${action}"
      # $const = true
      [ "${const}" = "${NULL}" ] && const=true
      [ "${const}" != true ] &&  __argparse__err__bad_attr "${name}" 'const' "${action}"
      # $default = false
      [ "${default}" = "${NULL}" ] && default=false
      [ "${default}" != false ] && __argparse__err__bad_attr "${name}" 'default' "${action}"
      # $choices = true,false
      [ "${choices}" = "${NULL}" ] && choices='true,false'
      [ "${choices}" != 'true,false' ] && __argparse__err__bad_attr "${name}" 'choices' "${action}"
      ;;
    store_false)
      # $required = false
      "${required}" &&  __argparse__err__bad_attr "${name}" 'required' "${action}"
      # $nargs = 0
      [ "${nargs}" = "${NULL}" ] && nargs=0
      [ "${nargs}" != 0 ] && __argparse__err__bad_attr "${name}" 'nargs' "${action}"
      # $const = false
      [ "${const}" = "${NULL}" ] && const=false
      [ "${const}" != false ] &&  __argparse__err__bad_attr "${name}" 'const' "${action}"
      # $default = true
      [ "${default}" = "${NULL}" ] && default=true
      [ "${default}" != true ] && __argparse__err__bad_attr "${name}" 'default' "${action}"
      # $choices = true,false
      [ "${choices}" = "${NULL}" ] && choices='true,false'
      [ "${choices}" != 'true,false' ] && __argparse__err__bad_attr "${name}" 'choices' "${action}"
      ;;
  esac

  # Check if $default and $const are valid choices
  if [ "${choices}" != "${NULL}" ]; then
    if [ "${default}" != "${NULL}" ]; then
      if ! printf '%s' "${choices}" | grep -e "\\(^\\|,\\)${default}\\(,\\|$\\)" >/dev/null; then
        __argparse__print_error '%s: default value %s not valid (%s)' \
          "${name}" "'${default}'" "${choices}"
        exit "${EX_DATAERR}"
      fi
    fi
    if [ "${const}" != "${NULL}" ]; then
      if ! printf '%s' "${choices}" | grep -e "\\(^\\|,\\)${const}\\(,\\|$\\)" >/dev/null; then
        __argparse__print_error '%s: const value %s not valid (%s)' \
          "${name}" "'${const}'" "${choices}"
        exit "${EX_DATAERR}"
      fi
    fi
  fi

  # prepare a local argument to export
  local argument=''
  argument="$(
    printf "%s${FS}" "${name}" "${flags}" "${required}" "${metavar}" "${action}" \
    "${nargs}" "${const}" "${default}" "${choices}" "${usage_}" "${help_}"
  )"
  # add an EOL
  argument="$(printf '%s\n_' "${argument}")"; argument="${argument%?}"

  export ARGPARSE__ARGUMENTS="${ARGPARSE__ARGUMENTS}${argument}"
}

########################################
# argparse__description()
# Set the description to print in help
########################################
argparse__description() {
  export ARGPARSE__DESCRIPTION="${*}"
}

########################################
# argparse__synopsis()
# Set the synopsis to print in help
########################################
argparse__synopsis() {
  export ARGPARSE__SYNOPSIS="${*}"
}

########################################
# argparse__parse()
# Parse all the arguments and:
#   - check if they are good options
#   - check if they are good positional
########################################
argparse__parse() {
    export args=''

    local param_ok
    local param param_  # $param_ will be used to manage short options
    local name flags required metavar action nargs const default choices usage_ help_

    while [ "${#}" -gt 0 ]; do
      param="${1}"; shift
      param_=''
      # Deleting a '-'; It will be added when $param_ is recovered
      while [ -n "${param#-}" ]; do
        if [ -z "${param##-[0-9A-Za-z]*}" ]; then # if short option
          param_="${param#-?}"                    # save spare letters (if any)
          param="${param%"${param_}"}"            # and evaluate the first
        fi
        case "${param}" in
          --)
            args="${args}$(printf "%s${FS}" "${@}")"
            shift "${#}"
            ;;
          -*)
            param_ok=false
            while IFS="${FS}" read -r \
              name flags required metavar action nargs const default choices usage_ help_; do
              if printf '%s' "${flags}" | grep -e "\\(^\\|,\\)${param}\\(,\\|$\\)" >/dev/null; then
                param_ok=true
                case "${action}" in
                  count)
                    ! set | grep -e "^${name}\\(=.*\\)\\?$" >/dev/null && export "${name}=0"
                    export "${name}=$((name + 1))"
                    ;;
                  store) # at least a var to store should be there
                    local value='' value_=false
                    if [ -n "${param_}" ]; then # if spare letters
                      value="${param_}"         # threat them as input value
                      value_=true
                      param_=''                 # and flush them
                    else                        # otherwise
                      value="${1-"${NULL}"}"    # use next parameter
                      if [ "${value}" != "${NULL}" ] && [ "${value#-}" = "${value}" ]; then
                        value_=true
                        shift
                      fi
                    fi
                    case "${nargs}" in
                      '?')
                        if "${value_}"; then              # If we have a value set
                          __argparse__parse_checkchoices  # check it
                          export "${name}=${value}"       # and use it
                        else
                          export "${name}=${const}"
                        fi
                        ;;
                      [1-9]*)
                        local nargs_="${nargs}"
                        if "${value_}"; then
                          __argparse__parse_checkchoices
                          value_="${value}${FS}"
                          nargs_=$((nargs_ - 1))
                        else
                          value_=''
                        fi
                        while [ "${nargs_}" -gt 0 ]; do
                          value="${1-"${NULL}"}"
                          if [ "${value}" != "${NULL}" ]; then
                            shift
                            __argparse__parse_checkchoices
                            value_="${value_}${value}${FS}"
                            nargs_=$((nargs_ - 1))
                          else
                            __argparse__print_error 'argument %s: expected %i argument(s)' \
                              "'${name}'" "${nargs}"
                            exit "${EX_USAGE}"
                          fi
                        done
                        export "${name}=${value_%?}"
                        ;;
                      *)
                        print__error 'IMPOSSIBRU!'
                        exit "${EX_DATAERR}"
                        ;;
                    esac
                    ;;
                  store_true|store_false)
                    export "${name}=${const}"  # const should always be set
                    ;;
                esac
              fi
              set +x
            done <<EOF
${ARGPARSE__ARGUMENTS%?}
EOF
            if ! "${param_ok}"; then
              __argparse__print_error 'unrecognized argument: %s' "${param}"
              exit "${EX_USAGE}"
            fi
            ;;
          *)
            args="${args}${param}${FS}"
            ;;
        esac
        param="-${param_}" # Recover spare letters (if any)
      done
    done
    __argparse__initunset
}

########################################
# argparse__opts()
# Check if optional (required) arguments are satisfied
########################################
argparse__opts() {
  local value
  local name flags required metavar action nargs const default choices usage_ help_
  while IFS="${FS}" read -r \
    name flags required metavar action nargs const default choices usage_ help_; do
    if [ "${flags}" != "${NULL}" ] && "${required}"; then
      if [ "${action}" = 'store' ]; then
        if [ "${nargs}" = '?' ] && [ "${default}" = "${NULL}" ]; then
          if eval [ "\${${name}}" = "${NULL}" ]; then
            if ! argparse__usage; then
              __argparse__print_error 'too few arguments'
              return "${EX_USAGE}"
            fi
          fi
        fi
      fi
    fi
  done <<EOF
${ARGPARSE__ARGUMENTS%?}
EOF
}

########################################
# argparse__args()
# Check if positional arguments are satisfied
########################################
argparse__args() {
  local value
  local name flags required metavar action nargs const default choices usage_ help_
  while IFS="${FS}" read -r \
    name flags required metavar action nargs const default choices usage_ help_; do
    if [ "${flags}" = "${NULL}" ]; then
      if [ -n "${args}" ]; then
        value="${args%%${FS}*}"
        __argparse__parse_checkchoices
        export "${name}=${value}"
        export args="${args#*${FS}}"
      else
        if ! argparse__usage; then
          __argparse__print_error 'too few arguments'
          return "${EX_USAGE}"
        fi
      fi
    fi
  done <<EOF
${ARGPARSE__ARGUMENTS%?}
EOF
}

########################################
# argparse__usage()
# Print the usage
# Things to print (sorted):
# optional arguments
# positional_arguments
########################################
argparse__usage() {
  printf 'usage: %s' "${BIN_NAME}"

  local uopts='' ropts='' rposs='' arg
  local name flags required metavar action nargs const default choices usage_ help_
  while IFS="${FS}" read -r \
    name flags required metavar action nargs const default choices usage_ help_; do
    arg=''
    if [ "${help_}" != "${NULL}" ] && "${usage_}"; then
      if [ "${flags}" != "${NULL}" ]; then
        arg="${flags%%,*}"
        if [ "${action}" = 'store' ]; then
          if [ "${choices}" = "${NULL}" ]; then
            [ "${nargs}" = '?' ] && metavar="[${metavar}]"
            arg="${arg} ${metavar}"
          else
            choices="{${choices}}"
            [ "${nargs}" = '?' ] && choices="[${choices}]"
            arg="${arg} ${choices}"
          fi
        fi
        if "${required}"; then
          ropts="${ropts} ${arg}"
        else
          uopts="${uopts} [${arg}]"
        fi
      else
        if [ "${choices}" = "${NULL}" ]; then
          arg="${metavar}"
        else
          arg="(${choices})"
        fi
        rposs="${rposs} ${arg}"
      fi
    fi
  done <<EOF
${ARGPARSE__ARGUMENTS%?}
EOF

  printf '%s%s%s\n' "${uopts}" "${ropts}" "${rposs}"

  ! "${help}" && ! "${usage}" && return "${EX_USAGE}" 
  return 0
}

########################################
# argparse__help()
# Print a help message
# Things to print (sorted):
# usage
# description
# positional_arguments
# optional arguments
# synopsis
########################################
argparse__help() {
  local tab=3

  argparse__usage
  printf '%b' '\n'

  if [ "${ARGPARSE__DESCRIPTION}" != "${NULL}" ]; then
    printf '%s\n' "${ARGPARSE__DESCRIPTION}"
    printf '%b' '\n'
  fi

  local pos_=true opt_=true
  local name flags required metavar action nargs const default choices usage_ help_
  while IFS="${FS}" read -r \
    name flags required metavar action nargs const default choices usage_ help_; do
    if [ "${help_}" != "${NULL}" ]; then
      if [ "${flags}" = "${NULL}" ]; then
        if "${pos_}"; then
          printf 'Positional arguments:\n'
          pos_=false
        fi
        printf '%*s' $((tab)) ''
        printf '%s\n' "${metavar}"
        if [ -n "${help_}" ]; then
          printf '%*s' $((2 * tab)) ''
          printf '%s\n' "${help_}"
        fi
        if [ "${action}" = 'store' ]; then
          if [ "${choices}" != "${NULL}" ]; then
            printf '%*s' $((2 * tab)) ''
            printf '%s is %s\n' "${metavar}" "'${choices}'" \
              | sed -e "s/\\(.*\\),/\\1' or '/" -e "s/,/'& '/g"
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

  while IFS="${FS}" read -r \
    name flags required metavar action nargs const default choices usage_ help_; do
    if [ "${help_}" != "${NULL}" ]; then
      if [ "${flags}" != "${NULL}" ]; then
        if "${opt_}"; then
          ! "${pos_}" && printf '%b' '\n'
          printf 'Optional arguments:\n'
          opt_=false
        fi
        [ "${nargs}" = '?' ] && metavar="[${metavar}]"
        printf '%*s' $((tab)) ''
        if [ "${action}" = 'store' ]; then
          printf '%s ' "${flags}" | sed -e "s/,/ ${metavar}& /g"
          printf '%s\n' "${metavar}"
        else
          printf '%s\n' "${flags}" | sed -e 's/,/& /g'
        fi
        if [ -n "${help_}" ]; then
          printf '%*s' $((2 * tab)) ''
          printf '%s\n' "${help_}"
        fi
        if [ "${action}" = 'store' ]; then
          if [ "${choices}" != "${NULL}" ]; then
            printf '%*s' $((2 * tab)) ''
            printf '%s is %s\n' "${metavar}" "'${choices}'" \
              | sed -e "s/\\(.*\\),/\\1' or '/" -e "s/,/'& '/g"
          fi
          if [ "${default}" != "${NULL}" ]; then
            printf '%*s' $((2 * tab)) ''
            printf 'If the option is omitted, value %s is used by default\n' "'${default}'"
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

  if [ "${ARGPARSE__SYNOPSIS}" != "${NULL}" ]; then
    if ! "${pos_}" || ! "${opt_}"; then
      printf '%b' '\n'
    fi
    printf '%s\n' "${ARGPARSE__SYNOPSIS}"
  fi

  ! "${help}" && return "${EX_USAGE}" 
  return 0
}

__argparse__load() {
  export __SHELI_LIB__LOADING='argparse'

  dep__lib 'print'

  export ARGPARSE__ARGUMENTS=''

  # Always include option --help
  argparse__add_argument name='help' flags='--help' action='store_true' usage=false \
    help='Show this help message end exit'
  # Always include option --usage
  argparse__add_argument name='usage' flags='--usage' action='store_true' help="${NULL}"
  # help = $NULL means that options will not be shown in help message (or usage)
  argparse__add_argument name='color' flags='--color' metavar='when' nargs='?' \
    const='auto' default='auto' choices='never,auto,always' usage=false
  # usage = false means that the option will not be shown in usage message

  argparse__description "${NULL}" # No description
  argparse__synopsis "${NULL}"    # No synopsys

  unset __SHELI_LIB__LOADING
}

__argparse__load "${@}" || exit "${?}"
export __SHELI_LIB_ARGPARSE__LOADING=false
export __SHELI_LIB_ARGPARSE__LOADED=true

