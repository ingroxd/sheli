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
# __check()
# Generic function to evaluate data and eventually log
########################################
__check() {
  local level="${1}"; shift
  local test="${1}"; shift
  local data="${1}"; shift
  local text="${1}"; shift

  if ! "${test}" "${data}"; then
    case level in info|warning|error|debug) "print__${level}" "${text}";; esac
    return "${EX_DATAERR}"
  fi
  return 0
}

########################################
# All the __check__xxx below use is_xxx
########################################
__check__bin() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_bin "${data}" \
  "Value '${data}' is not a valid binary number"
}

__check__oct() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_oct "${data}" \
  "Value '${data}' is not a valid octal number"
}

__check__int() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_int "${data}" \
  "Value '${data}' is not a valid integer number"
}

__check__float() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_float "${data}" \
  "Value '${data}' is not a valid decimal number"
}

__check__number() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_number "${data}" \
  "Value '${data}' is not a valid number"
}

__check__digit() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_digit "${data}" \
  "Value '${data}' is not a valid digits only string"
}

__check__alpha() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check__silent is_alpha "${data}" \
  "Value '${data}' is not a valid alphabetical string"
}

__check__alnum() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_alnum "${data}" \
  "Value '${data}' is not a valid alphanumeric string"
}

__check__hex() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_hex "${data}" \
  "Value '${data}' is not a valid hexadecimal number"
}

__check__negative() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_negative "${data}" \
  "Value '${data}' is not a valid negative number"
}

__check__positive() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_positive "${data}" \
  "Value '${data}' is not a valid positive number"
}

__check__base64() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_base64 "${data}" \
  "Value '${data}' is not a valid base64 string"
}

__check__md5() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_md5 "${data}" \
  "Value '${data}' is not a valid md5 hash"
}

__check__sha1() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_sha1 "${data}" \
  "Value '${data}' is not a valid sha1 hash"
}

__check__sha256() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_sha256 "${data}" \
  "Value '${data}' is not a valid sha256 hash"
}

__check__sha512() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_sha512 "${data}" \
  "Value '${data}' is not a valid sha512 hash"
}

__check__date() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_bin "${data}" \
  "Value '${data}' is not a valid date"
}

__check__epoch() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_bin "${data}" \
  "Value '${data}' is not a valid epoch date"
}

__check__wints() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_bin "${data}" \
  "Value '${data}' is not a valid Windows timestamp date"
}

__check__ipv4() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_bin "${data}" \
  "Value '${data}' is not a valid ipv4 address"
}

__check__cidr() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_cidr "${data}" \
  "Value '${data}' is not a valid cidr netmask"
}

__check__prefix() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_prefix "${data}" \
  "Value '${data}' is not a valid prefix (ipv4/cidr)"
}

__check__port() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_port "${data}" \
  "Value '${data}' is not a valid port number"
}

__check__socket() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_socket "${data}" \
  "Value '${data}' is not a valid socket (ipv4:port)"
}

__check__null() {
  local level="${1}"; shift
  local data="${1}"; shift
  __check "${level}" is_null "${data}" \
  "Value '${data}' is not null"
}

########################################
# All the check_xxx below use __check__xxx
########################################
check__bin() {
  __check__bin 'silent' "${1}"
}

check__oct() {
  __check__oct 'silent' "${1}"
}

check__int() {
  __check__int 'silent' "${1}"
}

check__float() {
  __check__float 'silent' "${1}"
}

check__number() {
  __check__number 'silent' "${1}"
}

check__digit() {
  __check__digit 'silent' "${1}"
}

check__alpha() {
  __check__alpha 'silent' "${1}"
}

check__alnum() {
  __check__alnum 'silent' "${1}"
}

check__hex() {
  __check__hex 'silent' "${1}"
}

check__negative() {
  __check__negative 'silent' "${1}"
}

check__positive() {
  __check__positive 'silent' "${1}"
}

check__base64() {
  __check__base64 'silent' "${1}"
}

check__md5() {
  __check__md5 'silent' "${1}"
}

check__sha1() {
  __check__sha1 'silent' "${1}"
}

check__sha256() {
  __check__sha256 'silent' "${1}"
}

check__sha512() {
  __check__sha512 'silent' "${1}"
}

check__date() {
  __check__date 'silent' "${1}"
}

check__epoch() {
  __check__epoch 'silent' "${1}"
}

check__wints() {
  __check__wints 'silent' "${1}"
}

check__ipv4() {
  __check__ipv4 'silent' "${1}"
}

check__cidr() {
  __check__cidr 'silent' "${1}"
}

check__prefix() {
  __check__prefix 'silent' "${1}"
}

check__port() {
  __check__port 'silent' "${1}"
}

check__socket() {
  __check__socket 'silent' "${1}"
}

check__null() {
  __check__null 'silent' "${1}"
}

########################################
# All the check__info_xxx below use __check__xxx
########################################
check__info_bin() {
  __check__bin 'info' "${1}"
}

check__info_oct() {
  __check__oct 'info' "${1}"
}

check__info_int() {
  __check__int 'info' "${1}"
}

check__info_float() {
  __check__float 'info' "${1}"
}

check__info_number() {
  __check__number 'info' "${1}"
}

check__info_digit() {
  __check__digit 'info' "${1}"
}

check__info_alpha() {
  __check__alpha 'info' "${1}"
}

check__info_alnum() {
  __check__alnum 'info' "${1}"
}

check__info_hex() {
  __check__hex 'info' "${1}"
}

check__info_negative() {
  __check__negative 'info' "${1}"
}

check__info_positive() {
  __check__positive 'info' "${1}"
}

check__info_base64() {
  __check__base64 'info' "${1}"
}

check__info_md5() {
  __check__md5 'info' "${1}"
}

check__info_sha1() {
  __check__sha1 'info' "${1}"
}

check__info_sha256() {
  __check__sha256 'info' "${1}"
}

check__info_sha512() {
  __check__sha512 'info' "${1}"
}

check__info_date() {
  __check__date 'info' "${1}"
}

check__info_epoch() {
  __check__epoch 'info' "${1}"
}

check__info_wints() {
  __check__wints 'info' "${1}"
}

check__info_ipv4() {
  __check__ipv4 'info' "${1}"
}

check__info_cidr() {
  __check__cidr 'info' "${1}"
}

check__info_prefix() {
  __check__prefix 'info' "${1}"
}

check__info_port() {
  __check__port 'info' "${1}"
}

check__info_socket() {
  __check__socket 'info' "${1}"
}

check__info_null() {
  __check__null 'info' "${1}"
}

########################################
# All the check__warning_xxx below use __check__xxx
########################################
check__warning_bin() {
  __check__bin 'warning' "${1}"
}

check__warning_oct() {
  __check__oct 'warning' "${1}"
}

check__warning_int() {
  __check__int 'warning' "${1}"
}

check__warning_float() {
  __check__float 'warning' "${1}"
}

check__warning_number() {
  __check__number 'warning' "${1}"
}

check__warning_digit() {
  __check__digit 'warning' "${1}"
}

check__warning_alpha() {
  __check__alpha 'warning' "${1}"
}

check__warning_alnum() {
  __check__alnum 'warning' "${1}"
}

check__warning_hex() {
  __check__hex 'warning' "${1}"
}

check__warning_negative() {
  __check__negative 'warning' "${1}"
}

check__warning_positive() {
  __check__positive 'warning' "${1}"
}

check__warning_base64() {
  __check__base64 'warning' "${1}"
}

check__warning_md5() {
  __check__md5 'warning' "${1}"
}

check__warning_sha1() {
  __check__sha1 'warning' "${1}"
}

check__warning_sha256() {
  __check__sha256 'warning' "${1}"
}

check__warning_sha512() {
  __check__sha512 'warning' "${1}"
}

check__warning_date() {
  __check__date 'warning' "${1}"
}

check__warning_epoch() {
  __check__epoch 'warning' "${1}"
}

check__warning_wints() {
  __check__wints 'warning' "${1}"
}

check__warning_ipv4() {
  __check__ipv4 'warning' "${1}"
}

check__warning_cidr() {
  __check__cidr 'warning' "${1}"
}

check__warning_prefix() {
  __check__prefix 'warning' "${1}"
}

check__warning_port() {
  __check__port 'warning' "${1}"
}

check__warning_socket() {
  __check__socket 'warning' "${1}"
}

check__warning_null() {
  __check__null 'warning' "${1}"
}

########################################
# All the check__error_xxx below use __check__xxx
########################################
check__error_bin() {
  __check__bin 'error' "${1}"
}

check__error_oct() {
  __check__oct 'error' "${1}"
}

check__error_int() {
  __check__int 'error' "${1}"
}

check__error_float() {
  __check__float 'error' "${1}"
}

check__error_number() {
  __check__number 'error' "${1}"
}

check__error_digit() {
  __check__digit 'error' "${1}"
}

check__error_alpha() {
  __check__alpha 'error' "${1}"
}

check__error_alnum() {
  __check__alnum 'error' "${1}"
}

check__error_hex() {
  __check__hex 'error' "${1}"
}

check__error_negative() {
  __check__negative 'error' "${1}"
}

check__error_positive() {
  __check__positive 'error' "${1}"
}

check__error_base64() {
  __check__base64 'error' "${1}"
}

check__error_md5() {
  __check__md5 'error' "${1}"
}

check__error_sha1() {
  __check__sha1 'error' "${1}"
}

check__error_sha256() {
  __check__sha256 'error' "${1}"
}

check__error_sha512() {
  __check__sha512 'error' "${1}"
}

check__error_date() {
  __check__date 'error' "${1}"
}

check__error_epoch() {
  __check__epoch 'error' "${1}"
}

check__error_wints() {
  __check__wints 'error' "${1}"
}

check__error_ipv4() {
  __check__ipv4 'error' "${1}"
}

check__error_cidr() {
  __check__cidr 'error' "${1}"
}

check__error_prefix() {
  __check__prefix 'error' "${1}"
}

check__error_port() {
  __check__port 'error' "${1}"
}

check__error_socket() {
  __check__socket 'error' "${1}"
}

check__error_null() {
  __check__null 'error' "${1}"
}

########################################
# All the check__debug_xxx below use __check__xxx
########################################
check__debug_bin() {
  __check__bin 'debug' "${1}"
}

check__debug_oct() {
  __check__oct 'debug' "${1}"
}

check__debug_int() {
  __check__int 'debug' "${1}"
}

check__debug_float() {
  __check__float 'debug' "${1}"
}

check__debug_number() {
  __check__number 'debug' "${1}"
}

check__debug_digit() {
  __check__digit 'debug' "${1}"
}

check__debug_alpha() {
  __check__alpha 'debug' "${1}"
}

check__debug_alnum() {
  __check__alnum 'debug' "${1}"
}

check__debug_hex() {
  __check__hex 'debug' "${1}"
}

check__debug_negative() {
  __check__negative 'debug' "${1}"
}

check__debug_positive() {
  __check__positive 'debug' "${1}"
}

check__debug_base64() {
  __check__base64 'debug' "${1}"
}

check__debug_md5() {
  __check__md5 'debug' "${1}"
}

check__debug_sha1() {
  __check__sha1 'debug' "${1}"
}

check__debug_sha256() {
  __check__sha256 'debug' "${1}"
}

check__debug_sha512() {
  __check__sha512 'debug' "${1}"
}

check__debug_date() {
  __check__date 'debug' "${1}"
}

check__debug_epoch() {
  __check__epoch 'debug' "${1}"
}

check__debug_wints() {
  __check__wints 'debug' "${1}"
}

check__debug_ipv4() {
  __check__ipv4 'debug' "${1}"
}

check__debug_cidr() {
  __check__cidr 'debug' "${1}"
}

check__debug_prefix() {
  __check__prefix 'debug' "${1}"
}

check__debug_port() {
  __check__port 'debug' "${1}"
}

check__debug_socket() {
  __check__socket 'debug' "${1}"
}

check__debug_null() {
  __check__null 'debug' "${1}"
}

__check__load() {
  export __SHELI_LIB__LOADING='check'

  dep__lib 'print' 'test'

  unset __SHELI_LIB__LOADING
}

__check__load "${@}" || exit "${?}"
export __SHELI_LIB_CHECK__LOADING=false
export __SHELI_LIB_CHECK__LOADED=true

