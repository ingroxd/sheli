#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_CHECK__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_CHECK__LOADING-false}" && exit "${EX_SOFTWARE}"  # If loading, something is wrong

export __SHELI_LIB_CHECK__LOADING=true

########################################
# All the check_xxx below use is_xxx and return a proper value
########################################
check__bin() {
  is_bin "${1}" || return "${EX_DATAERR}"
}

check__oct() {
  is_oct "${1}" || return "${EX_DATAERR}"
}

check__int() {
  is_int "${1}" || return "${EX_DATAERR}"
}

check__float() {
  is_float "${1}" || return "${EX_DATAERR}"
}

check__number() {
  is_number "${1}" || return "${EX_DATAERR}"
}

check__digit() {
  is_digit "${1}" || return "${EX_DATAERR}"
}

check__alpha() {
  is_alpha "${1}" || return "${EX_DATAERR}"
}

check__alnum() {
  is_alnum "${1}" || return "${EX_DATAERR}"
}

check__hex() {
  is_hex "${1}" || return "${EX_DATAERR}"
}

check__negative() {
  is_negative "${1}" || return "${EX_DATAERR}"
}

check__positive() {
  is_positive "${1}" || return "${EX_DATAERR}"
}

check__base64() {
  is_base64 "${1}" || return "${EX_DATAERR}"
}

check__md5() {
  is_md5 "${1}" || return "${EX_DATAERR}"
}

check__sha1() {
  is_sha1 "${1}" || return "${EX_DATAERR}"
}

check__sha256() {
  is_sha256 "${1}" || return "${EX_DATAERR}"
}

check__sha512() {
  is_sha512 "${1}" || return "${EX_DATAERR}"
}

check__date() {
  is_date "${1}" || return "${EX_DATAERR}"
}

check__epoch() {
  is_epoch "${1}" || return "${EX_DATAERR}"
}

check__wints() {
  is_wints "${1}" || return "${EX_DATAERR}"
}

check__ipv4() {
  is_ipv4 "${1}" || return "${EX_DATAERR}"
}

check__cidr() {
  is_cidr "${1}" || return "${EX_DATAERR}"
}

check__prefix() {
  is_prefix "${1}" || return "${EX_DATAERR}"
}

check__port() {
  is_port "${1}" || return "${EX_DATAERR}"
}

check__socket() {
  is_socket "${1}" || return "${EX_DATAERR}"
}

check__null() {
  is_null "${1}" || return "${EX_DATAERR}"
}

########################################
# All the check_w_xxx below use is_xxx and print a warning
########################################
check__w_bin() {
  if ! is_bin "${1}"; then
    print__warning 'Value %s is not a valid binary number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_oct() {
  if ! is_oct "${1}"; then
    print__warning 'Value %s is not a valid octal number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_int() {
  if ! is_int "${1}"; then
    print__warning 'Value %s is not a valid integer number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_float() {
  if ! is_float "${1}"; then
    print__warning 'Value %s is not a valid decimal number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_number() {
  if ! is_number "${1}"; then
    print__warning 'Value %s is not a valid number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_alpha() {
  if ! is_alpha "${1}"; then
    print__warning 'Value %s is not a valid alphabetic string' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_digit() {
  if ! is_digit "${1}"; then
    print__warning 'Value %s is not a valid digits only string' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_alnum() {
  if ! is_alnum "${1}"; then
    print__warning 'Value %s is not a valid alphanumeric string' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_hex() {
  if ! is_hex "${1}"; then
    print__warning 'Value %s is not a valid hexadecimal number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_negative() {
  if ! is_negative "${1}"; then
    print__warning 'Value %s is not a valid negative number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_positive() {
  if ! is_bin "${1}"; then
    print__warning 'Value %s is not a valid positive number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_base64() {
  if ! is_base64 "${1}"; then
    print__warning 'Value %s is not a valid base64 string' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_md5() {
  if ! is_md5 "${1}"; then
    print__warning 'Value %s is not a valid md5 hash' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_sha1() {
  if ! is_sha1 "${1}"; then
    print__warning 'Value %s is not a valid sha1 hash' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_sha256() {
  if ! is_sha256 "${1}"; then
    print__warning 'Value %s is not a valid sha256 hash' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_sha512() {
  if ! is_sha512 "${1}"; then
    print__warning 'Value %s is not a valid sha512 hash' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_date() {
  if ! is_date "${1}"; then
    print__warning 'Value %s is not a valid date' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_epoch() {
  if ! is_epoch "${1}"; then
    print__warning 'Value %s is not a valid epoch date' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_wints() {
  if ! is_wints "${1}"; then
    print__warning 'Value %s is not a valid Windows timestamp date' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_ipv4() {
  if ! is_ipv4 "${1}"; then
    print__warning 'Value %s is not a valid ipv4 address' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_cidr() {
  if ! is_bin "${1}"; then
    print__warning 'Value %s is not a valid cidr netmask' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_prefix() {
  if ! is_prefix "${1}"; then
    print__warning 'Value %s is not a valid prefix (ipv4/cidr)' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_port() {
  if ! is_port "${1}"; then
    print__warning 'Value %s is not a valid port number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_socket() {
  if ! is_socket "${1}"; then
    print__warning 'Value %s is not a valid socket (ipv4:port)' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__w_null() {
  if ! is_null "${1}"; then
    print__warning 'Value %s is not null' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

########################################
# All the check_e_xxx below use is_xxx and print an error
########################################
check__e_bin() {
  if ! is_bin "${1}"; then
    print__error 'Value %s is not a valid binary number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_oct() {
  if ! is_oct "${1}"; then
    print__error 'Value %s is not a valid octal number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_int() {
  if ! is_int "${1}"; then
    print__error 'Value %s is not a valid integer number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_float() {
  if ! is_float "${1}"; then
    print__error 'Value %s is not a valid decimal number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_number() {
  if ! is_number "${1}"; then
    print__error 'Value %s is not a valid number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_alpha() {
  if ! is_alpha "${1}"; then
    print__error 'Value %s is not a valid alphabetic string' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_digit() {
  if ! is_digit "${1}"; then
    print__error 'Value %s is not a valid digits only string' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_alnum() {
  if ! is_alnum "${1}"; then
    print__error 'Value %s is not a valid alphanumeric string' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_hex() {
  if ! is_hex "${1}"; then
    print__error 'Value %s is not a valid hexadecimal number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_negative() {
  if ! is_negative "${1}"; then
    print__error 'Value %s is not a valid negative number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_positive() {
  if ! is_bin "${1}"; then
    print__error 'Value %s is not a valid positive number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_base64() {
  if ! is_base64 "${1}"; then
    print__error 'Value %s is not a valid base64 string' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_md5() {
  if ! is_md5 "${1}"; then
    print__error 'Value %s is not a valid md5 hash' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_sha1() {
  if ! is_sha1 "${1}"; then
    print__error 'Value %s is not a valid sha1 hash' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_sha256() {
  if ! is_sha256 "${1}"; then
    print__error 'Value %s is not a valid sha256 hash' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_sha512() {
  if ! is_sha512 "${1}"; then
    print__error 'Value %s is not a valid sha512 hash' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_date() {
  if ! is_date "${1}"; then
    print__error 'Value %s is not a valid date' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_epoch() {
  if ! is_epoch "${1}"; then
    print__error 'Value %s is not a valid epoch date' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_wints() {
  if ! is_wints "${1}"; then
    print__error 'Value %s is not a valid Windows timestamp date' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_ipv4() {
  if ! is_ipv4 "${1}"; then
    print__error 'Value %s is not a valid ipv4 address' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_cidr() {
  if ! is_bin "${1}"; then
    print__error 'Value %s is not a valid cidr netmask' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_prefix() {
  if ! is_prefix "${1}"; then
    print__error 'Value %s is not a valid prefix (ipv4/cidr)' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_port() {
  if ! is_port "${1}"; then
    print__error 'Value %s is not a valid port number' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_socket() {
  if ! is_socket "${1}"; then
    print__error 'Value %s is not a valid socket (ipv4:port)' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

check__e_null() {
  if ! is_null "${1}"; then
    print__error 'Value %s is not null' "'${1}'"
    return "${EX_DATAERR}"
  fi
}

__check__load() {
  export __SHELI_LIB__LOADING='check'

  dep__lib 'test'

  unset __SHELI_LIB__LOADING
}

__check__load "${@}" || exit "${?}"
export __SHELI_LIB_CHECK__LOADING=false
export __SHELI_LIB_CHECK__LOADED=true

