#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_TEST__LOADED-false}" && return                   # If loaded, do nothing
"${__SHELI_LIB_TEST__LOADING-false}" && exit "${EX__SOFTWARE}"  # If loading, something is wrong

export __SHELI_LIB_TEST__LOADING=true

########################################
# is_bin()
# Check if binary number
########################################
is_bin() {
  [ -n "${1##*[^01]*}" ]
}

########################################
# is_oct()
# Check if octal number
########################################
is_oct() {
  [ -n "${1##*[^0-7]*}" ]
}

########################################
# is_int()
# Check if integer number
########################################
is_int() {
  printf '%i' "${1}" >/dev/null 2>&1
}

########################################
# is_float()
# Check if decimal number
########################################
is_float() {
  printf '%f' "${1}" >/dev/null 2>&1
}

########################################
# is_number()
# Alias for is_float()
########################################
is_number() {
  is_float "${@}"
}

########################################
# is_digit()
# Check if digits text
########################################
is_digit() {
  [ -n "${1##*[^0-9]*}" ]
}

########################################
# is_alpha()
# Check if alphabetic text
########################################
is_alpha() {
  [ -n "${1##*[^A-Za-z]*}" ]
}

########################################
# is_alnum()
# Check if alphanumeric text
########################################
is_alnum() {
  [ -n "${1##*[^0-9A-Za-z]*}" ]
}

########################################
# is_hex()
# Check if hexadecimal number
########################################
is_hex() {
  [ -n "${1##*[^0-9A-Fa-f]*}" ]
}

########################################
# is_negative()
# Check if negative integer number (0 excluded)
########################################
is_negative() {
  is_int "${1}" && [ "${1}" -lt 0 ]
}

########################################
# is_positive()
# Check if positive integer number (0 excluded)
########################################
is_positive() {
  is_int "${1}" && [ "${1}" -gt 0 ]
}

########################################
# is_base64()
# Check if base64 text
########################################
is_base64() {
  printf '%s' "${1}" | grep -e '^\([0-9A-Za-z+/]\{4\}\)*\([0-9A-Za-z+/]\{2\}==\|[0-9A-Za-z+/]\{3\}=\|[0-9A-Za-z+/]\{4\}\)$' >/dev/null
}

########################################
# is_md5()
# Check if md5 hash
########################################
is_md5() {
  printf '%s' "${1}" | grep -e '^[0-9A-Fa-f]\{32\}$' >/dev/null
}

########################################
# is_sha1()
# Check if sha1 hash
########################################
is_sha1() {
  printf '%s' "${1}" | grep -e '^[0-9A-Fa-f]\{40\}$' >/dev/null
}

########################################
# is_sha256()
# Check if sha256 hash
########################################
is_sha256() {
  printf '%s' "${1}" | grep -e '^[0-9A-Fa-f]\{64\}$' >/dev/null
}

########################################
# is_sha512()
# Check if sha512 hash
########################################
is_sha512() {
  printf '%s' "${1}" | grep -e '^[0-9A-Fa-f]\{128\}$' >/dev/null
}

########################################
# is_date()
# Check if date format text
########################################
is_date() {
  date --date "${*}" >/dev/null 2>&1
}

########################################
# is_epoch()
# Check if epoch number
########################################
is_epoch() {
  is_date "@${1}"
}

########################################
# is_wints()
# Check if windows epoch number
########################################
is_wints() {
  is_epoch $((${1} / 10000000 - 11644473600))
}

########################################
# is_wints()
# Check if ipv4 address
########################################
is_ipv4() {
  printf '%s' "${1}" | grep -e '^\(\(2\(5[0-5]\|[0-4][0-9]\)\|1[0-9][0-9]\|[1-9]\?[0-9]\)\.\)\{3\}\(2\(5[0-5]\|[0-4][0-9]\)\|1[0-9][0-9]\|[1-9]\?[0-9]\)$' >/dev/null
}

########################################
# is_cidr()
# Check if Classless Inter-Domain Routing netmask
########################################
is_cidr() {
  printf '%s' "${1}" | grep -e '^\(3[0-2]\|[12]\?[0-9]\)$' >/dev/null
}

########################################
# is_prefix()
# Check if ipv4/cidr
########################################
is_prefix() {
  is_ipv4 "${1%/*}" \
  && is_cidr "${1#*/}"
}

########################################
# is_port()
# Check if tcp/udp port number
########################################
is_port() {
  is_int "${1}" && [ "${1}" -ge 0 ] && [ "${1}" -lt 65536 ]
}

########################################
# is_socket()
# Check if ipv4:port
########################################
is_socket() {
  is_ipv4 "${1%:*}" \
  && is_port "${1#*:}"
}

########################################
# is_socket()
# Check if $NULL
########################################
is_null() {
  [ "${1}" = "${NULL}" ]
}

__test__load() {
  export __SHELI_LIB__LOADING='test'

  unset __SHELI_LIB__LOADING
}

__test__load "${@}" || exit "${?}"
export __SHELI_LIB_TEST__LOADING=false
export __SHELI_LIB_TEST__LOADED=true

