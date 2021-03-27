#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_MAGIC__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_MAGIC__LOADING-false}" && exit "${EX_SOFTWARE}"  # If loading, something is wrong

export __SHELI_LIB_MAGIC__LOADING=true

__magic__load_npchars() {
  ####################
  # nonprinting (NP) chars
  ####################
  # FIXME?
  # export NP_NUL; NP_NUL="$(printf '%b' '\000')" # nul
  # NP_NUL() { printf '%b' '\000';}
  export NP_SOH; NP_SOH="$(printf '%b' '\001')"  # start of heading
  export NP_STX; NP_STX="$(printf '%b' '\002')"  # start of text
  export NP_ETX; NP_ETX="$(printf '%b' '\003')"  # end of text
  export NP_EOT; NP_EOT="$(printf '%b' '\004')"  # end of transmission
  export NP_ENQ; NP_ENQ="$(printf '%b' '\005')"  # enquiry
  export NP_ACK; NP_ACK="$(printf '%b' '\006')"  # acknowledge
  export NP_BEL; NP_BEL="$(printf '%b' '\007')"  # bell
  export NP_BS;  NP_BS="$(printf '%b' '\010')"   # backspace
  export NP_TAB; NP_TAB="$(printf '%b' '\011')"  # horizontal tab
  export NP_LF;  NP_LF="$(printf '%b' '\012')"   # NL line feed, new line
  export NP_VT;  NP_VT="$(printf '%b' '\013')"   # vertical tab
  export NP_FF;  NP_FF="$(printf '%b' '\014')"   # NP form feed, new page
  export NP_CR;  NP_CR="$(printf '%b' '\015')"   # carriage return
  export NP_SO;  NP_SO="$(printf '%b' '\016')"   # shift out
  export NP_SI;  NP_SI="$(printf '%b' '\017')"   # shift in
  export NP_DLE; NP_DLE="$(printf '%b' '\020')"  # data link escape
  export NP_DC1; NP_DC1="$(printf '%b' '\021')"  # device control 1
  export NP_DC2; NP_DC2="$(printf '%b' '\022')"  # device control 2
  export NP_DC3; NP_DC3="$(printf '%b' '\023')"  # device control 3
  export NP_DC4; NP_DC4="$(printf '%b' '\024')"  # device control 4
  export NP_NAK; NP_NAK="$(printf '%b' '\025')"  # negative acknowledge
  export NP_SYN; NP_SYN="$(printf '%b' '\026')"  # synchronous idle
  export NP_ETB; NP_ETB="$(printf '%b' '\027')"  # end of trans, block
  export NP_CAN; NP_CAN="$(printf '%b' '\030')"  # cancel
  export NP_EM;  NP_EM="$(printf '%b' '\031')"   # end of medium
  export NP_SUB; NP_SUB="$(printf '%b' '\032')"  # substitute
  export NP_ESC; NP_ESC="$(printf '%b' '\033')"  # escape
  export NP_FS;  NP_FS="$(printf '%b' '\034')"   # file separator
  export NP_GS;  NP_GS="$(printf '%b' '\035')"   # group separator
  export NP_RS;  NP_RS="$(printf '%b' '\036')"   # record separator
  export NP_US;  NP_US="$(printf '%b' '\037')"   # unit separator
}

__magic__load_env() {
  export PID="${$}"
  # Store used shell
  export EXE; EXE="$(readlink -f "/proc/${PID}/exe")"

  # Store the command used to launch the script
  local CMD_="${0}"
  local param
  for param; do
    CMD_="${CMD_} '$(printf '%s' "${param}" | sed -e "s/'/'\\\\&'/g")'"
  done
  export CMD="${CMD_}"

  export BIN; BIN="$(readlink -f "${0}")"
  export BIN_DIR="${BIN%/*}"
  local BIN_NAME_="${BIN##*/}"
  export BIN_NAME="${BIN_NAME_%.*}"

  # Check if piped
  local PIPED_=false
  if readlink "/proc/${PID}/fd/1" \
    | grep -i -e 'pipe' >/dev/null; then
    PIPED_=true
  fi
  export PIPED="${PIPED_}"

  # Check if backgrounded job
  local BACKGROUND_=false
  case "$(ps -o stat= -p "${PID}")" in
    *+*) BACKGROUND_=false;;
    *) BACKGROUND_=true;;
  esac
  # case "${-}" in *i*) BACKGROUND_=true;; esac
  export BACKGROUND="${BACKGROUND_}"

  local NULL_="${NP_NAK}N${NP_NAK}U${NP_NAK}L${NP_NAK}" # A very unlikely string
  [ -n "${NULL-}" ] && NULL_="${NULL}"
  export NULL="${NULL_}"

  ####################
  # XXX
  # It is possible to safely check a null value like this:
  # var="${NULL}"
  # [ "${var}" == "${NULL}" ]
  #
  # It is also possible to use it to check if a var exists like this:
  # [ "${var-"${NULL}"}" != "${NULL}" ]
  ####################

  # Custom IFS
  local FS_="${NP_ETX}" # A very unlikely char
  [ -n "${FS-}" ] && FS_="${FS}"
  export FS="${FS_}"

  local TMP_DIR_; TMP_DIR_="/tmp/${BIN_NAME}-${PID}"
  # FIXME? Because of cleanup, user should not be able to edit TMP_DIR
  # [ -n "${TMP_DIR-}" ] && TMP_DIR_="${TMP_DIR}"
  export TMP_DIR="${TMP_DIR_}"
  mkdir -p "${TMP_DIR}"
}

__magic__load() {
  export __SHELI_LIB__LOADING='magic'

  __magic__load_npchars
  __magic__load_env "${@}"
  # From now on, a temp folder ($TMP_DIR) is available to put temp files

  unset __SHELI_LIB__LOADING
}

__magic__load "${@}" || exit "${?}"
export __SHELI_LIB_MAGIC__LOADING=false
export __SHELI_LIB_MAGIC__LOADED=true

