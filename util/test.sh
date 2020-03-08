#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  printf 'This library is intended to be imported by sheli.\n' >&2
  exit 69
fi
# If we are here, we have all the sheli env

"${__SHELI_LIB_TEST__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_TEST__LOADING-false}" && exit $((EX__SOFTWARE)) # If loading, something is wrong

export __SHELI_LIB_TEST__LOADING=true

is_int() {
  printf '%i' "${1}" >/dev/null 2>&1
}

is_float() {
  printf '%f' "${1}" >/dev/null 2>&1
}

is_number() {
  is_float "${@}"
}

is_digit() {
  [ "${1##*[^0-9]*}" ]
}

is_alpha() {
  [ "${1##*[^A-Za-z]*}" ]
}

is_alnum() {
  [ "${1##*[^0-9A-Za-z]*}" ]
}

is_hex() {
  [ "${1##*[^0-9A-Fa-f]*}" ]
}

is_negative() {
  is_int "${1}" && [ "${1}" -lt 0 ]
}

is_positive() {
  is_int "${1}" && [ "${1}" -gt 0 ]
}

is_base64() {
  printf '%s' "${1}" | grep -e '^\([0-9A-Za-z+/]\{4\}\)*\([0-9A-Za-z+/]\{2\}==\|[0-9A-Za-z+/]\{3\}=\|[0-9A-Za-z+/]\{4\}\)$' >/dev/null
}

is_md5() {
  printf '%s' "${1}" | grep -e '^[0-9A-Fa-f]\{32\}$' >/dev/null
}

is_sha1() {
  printf '%s' "${1}" | grep -e '^[0-9A-Fa-f]\{40\}$' >/dev/null
}

is_sha256() {
  printf '%s' "${1}" | grep -e '^[0-9A-Fa-f]\{64\}$' >/dev/null
}

is_sha512() {
  printf '%s' "${1}" | grep -e '^[0-9A-Fa-f]\{128\}$' >/dev/null
}

is_date() {
  date --date "${1}" >/dev/null 2>/&1
}

is_epoch() {
  date --date "@${1}" >/dev/null 2>/&1
}

is_w32ts() {
  is_epoch $((${1} / 10000000 - 11644473600))
}

is_ipv4() {
  printf '%s' "${1}" | grep -e '^\(\(2\(5[0-5]\|[0-4][0-9]\)\|1[0-9][0-9]\|[1-9]\?[0-9]\)\.\)\{3\}\(2\(5[0-5]\|[0-4][0-9]\)\|1[0-9][0-9]\|[1-9]\?[0-9]\)$' >/dev/null
}

is_cidr() {
  printf '%s' "${1}" | grep -e '^\(3[0-2]\|[12]\?[0-9]\)$' >/dev/null
}

is_prefix() {
  is_ipv4 "${1%/*}" \
  && is_cidr "${1#*/}"
}

is_port() {
  is_int "${1}" && [ "${1}" -ge 0 ] && [ "${1}" -lt 65536 ]
}

is_socket() {
  is_ipv4 "${1%/*}" \
  && is_port "${1#*/}"
}

is_null() {
  [ "${1}" = "${NULL}" ]
}

__test__load() {
  export __SHELI_LIB__LOADING='test'

  dep__pkg 'date' 'printf'

  unset __SHELI_LIB__LOADING
}

__test__load "${@}" || exit "${?}"
export __SHELI_LIB_TEST__LOADING=false
export __SHELI_LIB_TEST__LOADED=true

