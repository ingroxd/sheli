#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  printf 'This library is intended to be imported by sheli.\n' >&2
  exit 69
fi
# If we are here, we have all the sheli env

"${__SHELI_LIB_MAGIC__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_MAGIC__LOADING-false}" && exit $((EX__SOFTWARE)) # If loading, something is wrong

export __SHELI_LIB_MAGIC__LOADING=true

########################################
# Set shell behaviour
########################################
__magic__load_behaviour() {
  # Exit on error
  local SET_e_=true
  case "${SET_e-}" in true|false) SET_e_="${SET_e}";; esac
  export SET_e="${SET_e_}"
  "${SET_e}" && set -o errexit

  # Exit on unset var
  local SET_u_=true
  case "${SET_u-}" in true|false) SET_u_="${SET_u}";; esac
  export SET_u="${SET_u_}"
  "${SET_u}" && set -o nounset
  # Unset vars, no more!

  # Do not write on existing files
  local SET_C_=true
  case "${SET_C-}" in true|false) SET_C_="${SET_C}";; esac
  export SET_C="${SET_C_}"
  "${SET_C}" && set -o noclobber

  # Use job monitor
  #FIXME? Has to start as false
  local SET_m_=false #false
  case "${SET_m-}" in true|false) SET_m_="${SET_m}";; esac
  export SET_m="${SET_m_}"
  "${SET_m}" && set -o monitor

  # Verbose execution
  local SET_v_=false
  case "${SET_v-}" in true|false) SET_v_="${SET_v}";; esac
  export SET_v="${SET_v_}"
  "${SET_v}" && set -o verbose

  # Execution trace
  local SET_x_=false
  case "${SET_x-}" in true|false) SET_x_="${SET_x}";; esac
  export SET_x="${SET_x_}"
  "${SET_x}" && set -o xtrace
}

__magic__load() {
  export __SHELI_LIB__LOADING='magic'

  __magic__load_behaviour
  # From here unset vars will cause errors.

  #################### 
  # exit (EX) values
  # see /usr/include/sysexists.h
  #################### 
  export EX_OK=0            # successful termination

  export __EX_BASE=64       # base value for error messages

  export EX_USAGE=64        # command line usage error
  export EX_DATAERR=65      # data format error
  export EX_NOINPUT=66      # cannot open input
  export EX_NOUSER=67       # addressee unknown
  export EX_NOHOST=68       # host name unknown
  export EX_UNAVAILABLE=69  # service unavailable
  export EX_SOFTWARE=70     # internal software error
  export EX_OSERR=71        # system error (e.g., can't fork)
  export EX_OSFILE=72       # critical OS file missing
  export EX_CANTCREAT=73    # can't create (user) output file
  export EX_IOERR=74        # input/output error
  export EX_TEMPFAIL=75     # temp failure; user is invited to retry
  export EX_PROTOCOL=76     # remote error in protocol
  export EX_NOPERM=77       # permission denied
  export EX_CONFIG=78       # configuration error

  export __EX_MAX=78        # maximum listed value

  #################### 
  # nonprinting (NP) chars
  #################### 
  #FIXME
  #NP_NUL=''; export NP_NUL="$(printf '%b' "\\000")"
  #NP_NUL() { printf '%b' '\000';}                   # (null)
  export NP_SOH="$(printf '%b' '\001')"   # (start of heading)
  export NP_STX="$(printf '%b' '\002')"   # (start of text)
  export NP_ETX="$(printf '%b' '\003')"   # (end of text)
  export NP_EOT="$(printf '%b' '\004')"   # (end of transmission)
  export NP_ENQ="$(printf '%b' '\005')"   # (enquiry)
  export NP_ACK="$(printf '%b' '\006')"   # (acknowledge)
  export NP_BEL="$(printf '%b' '\007')"   # (bell)
  export NP_BS="$(printf '%b' '\010')"    # (backspace)
  export NP_TAB="$(printf '%b' '\011')"   # (horizontal tab)
  export NP_LF="$(printf '%b' '\012')"    # (NL line feed, new line)
  export NP_VT="$(printf '%b' '\013')"    # (vertical tab)
  export NP_FF="$(printf '%b' '\014')"    # (NP form feed, new page)
  export NP_CR="$(printf '%b' '\015')"    # (carriage return)
  export NP_SO="$(printf '%b' '\016')"    # (shift out)
  export NP_SI="$(printf '%b' '\017')"    # (shift in)
  export NP_DLE="$(printf '%b' '\020')"   # (data link escape)
  export NP_DC1="$(printf '%b' '\021')"   # (device control 1)
  export NP_DC2="$(printf '%b' '\022')"   # (device control 2)
  export NP_DC3="$(printf '%b' '\023')"   # (device control 3)
  export NP_DC4="$(printf '%b' '\024')"   # (device control 4)
  export NP_NAK="$(printf '%b' '\025')"   # (negative acknowledge)
  export NP_SYN="$(printf '%b' '\026')"   # (synchronous idle)
  export NP_ETB="$(printf '%b' '\027')"   # (end of trans, block)
  export NP_CAN="$(printf '%b' '\030')"   # (cancel)
  export NP_EM="$(printf '%b' '\031')"    # (end of medium)
  export NP_SUB="$(printf '%b' '\032')"   # (substitute)
  export NP_ESC="$(printf '%b' '\033')"   # (escape)
  export NP_FS="$(printf '%b' '\034')"    # (file separator)
  export NP_GS="$(printf '%b' '\035')"    # (group separator)
  export NP_RS="$(printf '%b' '\036')"    # (record separator)
  export NP_US="$(printf '%b' '\037')"    # (unit separator)

  ####################
  # Some env info
  ####################
  export PID="${$}"
  export EXE="$(readlink -f "/proc/$((PID))/exe")" # Always points to the shell

  # Which command we used to start the program?
  local CMD_="${0}"
  local param
  for param; do
    CMD_="${CMD_} '$(printf '%s' "${param}" | sed -e "s/'/'\\\\&'/g")'"
  done
  export CMD="${CMD_}"

  local BIN_=''; BIN_="$(readlink -f "${0}")" # Absolute path
  local BIN_DIR_="${BIN_%/*}"                 # Remove file
  local BIN_NAME_="${BIN_##*/}"               # Remove dir
  export BIN="${BIN_}"
  export BIN_DIR="${BIN_DIR_}"
  export BIN_NAME="${BIN_NAME_%.*}"           # Remove ext

  # Are we in a pipeline?
  local PIPED_=false
  if ls -l "/proc/$((PID))/fd/1" \
    | grep -i -e 'pipe' >/dev/null; then
    PIPED_=true
  fi
  export PIPED="${PIPED_}"

  # Are we in a background job?
  local BACKGROUND_=false
  case "$(ps -o stat= -p $((PID)) )" in
    *+*) :;;
    *) BACKGROUND_=true
  esac
  #case "${-}" in *i*) BACKGROUND_=true;; esac
  export BACKGROUND="${BACKGROUND_}"

  local NULL_="${NP_BS}${NP_BS}${NP_BS}" # Just a very unlikely string
  [ -n "${NULL-}" ] && NULL_="${NULL}"
  export NULL="${NULL_}"

  # Internal IFS
  local ifs_="${NP_ETX}"
  [ -n "${IFS_-}" ] && ifs_="${IFS_}"
  export ifs="${ifs_}"

  local TMP_DIR_="/tmp/${BIN_NAME}-$((PID))"
  [ -n "${TMP_DIR-}" ] && TMP_DIR_="${TMP_DIR}"
  export TMP_DIR="${TMP_DIR_}"
  mkdir -p "${TMP_DIR}"

  # From here we have a temp folder ($TMP_DIR) where to put files.
  #TODO? Provide functions that create disposable files in $TMP_DIR
}

__magic__load "${@}" || exit "${?}"
export __SHELI_LIB_MAGIC__LOADING=false
export __SHELI_LIB_MAGIC__LOADED=true

