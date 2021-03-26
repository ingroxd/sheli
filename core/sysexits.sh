#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_SYSEXITS__LOADED-false}" && return   # If loaded, do nothing
"${__SHELI_LIB_SYSEXITS__LOADING-false}" && exit 70 # If loading, something is wrong

export __SHELI_LIB_SYSEXITS__LOADING=true

__sysexits__load() {
  export __SHELI_LIB__LOADING='sysexits'

  ####################
  # exit (EX) values
  # see /usr/include/sysexits.h
  ####################

  export EX_OK=0           # Successful termination

  export EX__BASE=64       # Base value for error messages

  export EX_USAGE=64       # Command line usage error
  export EX_DATAERR=65     # data format error
  export EX_NOINPUT=66     # cannot open input
  export EX_NOUSER=67      # addressee unknown
  export EX_NOHOST=68      # host name unknown
  export EX_UNAVAILABLE=69 # service unavailable
  export EX_SOFTWARE=70    # internal software error
  export EX_OSERR=71       # system error (e.g., can't fork)
  export EX_OSFILE=72      # critical OS file missing
  export EX_CANTCREAT=73   # can't create (user) output file
  export EX_IOERR=74       # input/output error
  export EX_TEMPFAIL=75    # temp failure; user is invited to retry
  export EX_PROTOCOL=76    # remote error in protocol
  export EX_NOPERM=77      # permission denied
  export EX_CONFIG=78      # configuration error

  export EX__MAX=78        # maximum listed value 

  unset __SHELI_LIB__LOADING
}

__sysexits__load "${@}" || exit "${?}"
export __SHELI_LIB_SYSEXITS__LOADING=false
export __SHELI_LIB_SYSEXITS__LOADED=true

