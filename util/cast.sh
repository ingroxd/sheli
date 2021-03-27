#!/bin/bash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  BIN_NAME="$(readlink -f "${0}")"
  printf '%s: error: This library is intended to be imported by sheli.\n' "${BIN_NAME##*/}" >&2
  exit 69
fi
# From now on, the sheli env is available

"${__SHELI_LIB_CAST__LOADED-false}" && return                 # If loaded, do nothing
"${__SHELI_LIB_CAST__LOADING-false}" && exit "${EX_SOFTWARE}" # If loading, something is wrong

export __SHELI_LIB_CAST__LOADING=true

cast__set_scale() {
  export CAST__SCALE=$((${1}))
}

int2float() {
  local int="${1}"; shift
  if ! is_int "${int}"; then
    print__warning '%s is not a valid integer number' "'${int}'"
    int=0
  fi
  printf '%.*f' "${SCALE}" "${int}" >&9
} 9>&1 >&8

float2int() {
  local float="${1}"; shift
  if ! is_float "${float}"; then
    print__warning '%s is not a valid float number' "'${float}'"
    float=0
  fi
  printf '%s' "${float%.*}" >&9
} 9>&1 >&8

bin2oct() {
  local bin="${1}"; shift
  if ! is_bin "${bin}"; then
    print__warning '%s is not a valid binary number' "${bin}"
    bin=0
  fi
  local oct
  if command -v 'bc' >/dev/null; then
    oct="$(printf 'ibase=2; obase=8; %s\n' "${bin}" | bc)"
  else
    oct="$(printf '%o' "$(bin2dec "${bin}")")"
  fi
  local pad; pad=$((CAST__PAD_OCT + (${#oct} -1) / CAST__PAD_OCT * CAST__PAD_OCT))
  printf '%*s' "${pad}" "${oct}" | tr ' ' 0 >&9
} 9>&1 >&8

bin2dec() {
  local bin="${1}"; shift
  if ! is_bin "${bin}"; then
    print__warning '%s is not a valid binary number' "${bin}"
    bin=0
  fi
  local dec
  if command -v 'bc' >/dev/null; then
    dec="$(printf 'ibase=2; %s\n' "${bin}" | bc)"
  else
    dec=0
    while [ "${#bin}" -gt 0 ]; do
      bit="${bin%"${bin#?}"}"
      bin="${bin#"${bit}"}"
      [ "${bit}" -eq 1 ] && dec="$((dec + $(pow 2 ${#bin})))"
    done
  fi
  printf '%s' "${dec}" >&9
} 9>&1 >&8

bin2hex() {
  local bin="${1}"; shift
  if ! is_bin "${bin}"; then
    print__warning '%s is not a valid binary number' "${bin}"
    bin=0
  fi
  local hex
  if command -v 'bc' >/dev/null; then
    hex="$(printf 'obase=16; ibase=2; %s\n' "${bin}" | bc)"
  else
    hex="$(dec2hex "$(bin2dec "${bin}")")"
  fi
  local pad; pad=$((CAST__PAD_HEX + (${#hex} -1) / CAST__PAD_HEX * CAST__PAD_HEX))
  printf '%*s' "${pad}" "${hex}" | tr ' ' 0 >&9
} 9>&1 >&8

oct2bin() {
  local oct="${1}"; shift
  if ! is_oct "${oct}"; then
    print__warning '%s is not a valid octal number' "${oct}"
    oct=0
  fi
  local bin
  if command -v 'bc' >/dev/null; then
    bin="$(printf 'obase=2; ibase=8; %s\n' "${oct}" | bc)"
  else
    bin="$(dec2bin "$(oct2dec "${oct}")")"
  fi
  local pad; pad=$((CAST__PAD_BIN + (${#bin} -1) / CAST__PAD_BIN * CAST__PAD_BIN))
  printf '%*s' "${pad}" "${bin}" | tr ' ' 0 >&9
} 9>&1 >&8

oct2dec() {
  local oct="${1}"; shift
  if ! is_oct "${oct}"; then
    print__warning '%s is not a valid octal number' "${oct}"
    oct=0
  fi
  local dec
  if command -v 'bc' >/dev/null; then
    dec="$(printf 'ibase=8; %s\n' "${oct}" | bc)"
  else
    dec=0
    count=0
    while [ -n "${oct}" ]; do
      digit="${oct#"${oct%?}"}"
      oct="${oct%?}"
      dec="$((dec + $(pow 8 "${count}") * digit))"
      count="$((count + 1))"
    done
  fi
  printf '%s' "${dec}" >&9
} 9>&1 >&8

oct2hex() {
  local oct="${1}"; shift
  if ! is_oct "${oct}"; then
    print__warning '%s is not a valid octal number' "${oct}"
    oct=0
  fi
  local hex
  if command -v 'bc' >/dev/null; then
    hex="$(printf 'obase=16; ibase=8; %s\n' "${oct}" | bc)"
  else
    hex="$(dec2hex "$(oct2dec "${oct}")")"
  fi
  local pad; pad=$((CAST__PAD_HEX + (${#hex} -1) / CAST__PAD_HEX * CAST__PAD_HEX))
  printf '%*s' "${pad}" "${hex}" | tr ' ' 0 >&9
} 9>&1 >&8

dec2bin() {
  local dec="${1}"; shift
  if ! is_int "${dec}"; then
    print__warning '%s is not a valid integer number' "'${dec}'"
    dec=0
  fi
  local bin=''
  if command -v 'bc' >/dev/null; then
    bin="$(printf 'obase=2; %s\n' "${dec}" | bc)"
  else
    while [ "${dec}" -gt 0 ]; do
      bit="$((dec % 2))"
      dec="$((dec >> 1))"
      bin="${bit}${bin}"
    done
  fi
  local pad; pad=$((CAST__PAD_BIN + (${#bin} -1) / CAST__PAD_BIN * CAST__PAD_BIN))
  printf '%*s' "${pad}" "${bin}" | tr ' ' 0 >&9
} 9>&1 >&8

dec2oct() {
  local dec="${1}"; shift
  if ! is_int "${dec}"; then
    print__warning '%s is not a valid integer number' "'${dec}'"
    dec=0
  fi
  local oct
  if command -v 'bc' >/dev/null; then
    oct="$(printf 'obase=8; %s\n' "${dec}" | bc)"
  else
    oct="$(printf '%o' "${dec}")"
  fi
  local pad; pad=$((CAST__PAD_OCT + (${#oct} -1) / CAST__PAD_OCT * CAST__PAD_OCT))
  printf '%*s' "${pad}" "${oct}" | tr ' ' 0 >&9
} 9>&1 >&8

dec2hex() {
  local dec="${1}"; shift
  if ! is_int "${dec}"; then
    print__warning '%s is not a valid integer number' "'${dec}'"
    dec=0
  fi
  local hex
  if command -v 'bc' >/dev/null; then
    hex="$(printf 'obase=16; %s\n' "${dec}" | bc)"
  else
    hex="$(printf '%X' "${dec}")"
  fi
  local pad; pad=$((CAST__PAD_HEX + (${#hex} -1) / CAST__PAD_HEX * CAST__PAD_HEX))
  printf '%*s' "${pad}" "${hex}" | tr ' ' 0 >&9
} 9>&1 >&8

hex2bin() {
  local hex="${1}"; shift
  if ! is_hex "${hex}"; then
    print__warning '%s is not a valid hexadecimal number' "'${hex}'"
    hex=0
  fi
  local bin
  if command -v 'bc' >/dev/null; then
    bin="$(printf 'obase=2; ibase=16; %s\n' "${hex}" | bc)"
  else
    bin="$(dec2bin "$(hex2dec "${hex}")")"
  fi
  local pad; pad=$((CAST__PAD_BIN + (${#bin} -1 ) / CAST__PAD_BIN * CAST__PAD_BIN))
  printf '%*s' "${pad}" "${bin}" | tr ' ' 0 >&9
} 9>&1 >&8

hex2oct() {
  local hex="${1}"; shift
  if ! is_hex "${hex}"; then
    print__warning '%s is not a valid hexadecimal number' "'${hex}'"
    hex=0
  fi
  local oct
  if command -v 'bc' >/dev/null; then
    oct="$(printf 'obase=8; ibase=16; %s\n' "${hex}" | bc)"
  else
    oct="$(printf '%o' "0x${hex}")"
  fi
  local pad; pad=$((CAST__PAD_OCT + (${#oct} -1) / CAST__PAD_OCT * CAST__PAD_OCT))
  printf '%*s' "${pad}" "${oct}" | tr ' ' 0 >&9
} 9>&1 >&8

hex2dec() {
  local hex="${1}"; shift
  if ! is_hex "${hex}"; then
    print__warning '%s is not a valid hexadecimal number' "'${hex}'"
    hex=0
  fi
  local dec
  if command -v 'bc' >/dev/null; then
    dec="$(printf 'ibase=16; %s\n' "${hex}" | bc)"
  else
    dec="$(printf '%i' "0x${hex}")"
  fi
  printf '%s' "${dec}" >&9
} 9>&1 >&8

date2epoch() {
  local date="${1}"; shift
  if ! is_date "${date}"; then
    print__warning '%s is not a valid date' "'${date}'"
    date=0
  fi
  date --date "${date}" +'%s' >&9
} 9>&1 >&8

epoch2date() {
  local epoch="${1}"; shift
  if ! is_epoch "${epoch}"; then
    print__warning '%s is not a valid epoch' "'${epoch}'"
    epoch=0
  fi
  date --date "@${epoch}" >&9
} 9>&1 >&8

epoch2wints() {
  local epoch="${1}"; shift
  if ! is_epoch "${epoch}"; then
    print__warning '%s is not a valid epoch' "'${epoch}'"
    epoch=0
  fi
  local wints
  if command -v 'bc' >/dev/null; then
    wints="$(printf '(%s + 11644473600) * 10000000\n' "${wints}" | bc)"
  else
    wints="$(((epoch + 11644473600) * 10000000))"
  fi
  printf '%s' "${wints}" >&9
} 9>&1 >&8

wints2epoch() {
    local wints="${1}"; shift
    if ! is_wints "${wints}"; then
      print__warning '%s is not a valid wints' "'${wints}'"
      wints=0
    fi
    local epoch
    if command -v 'bc' >/dev/null; then
      epoch="$(printf '%s / 10000000 - 11644473600\n' "${wints}" | bc)"
    else
      epoch="$((wints / 10000000 - 11644473600))"
    fi
    printf '%s' "${epoch}" >&9
} 9>&1 >&8

ip2int() {
  local ip="${1}"; shift
  if ! is_ipv4 "${ip}"; then
    print__warning '%s is not a valid ipv4' "'${ip}'"
    ip='0.0.0.0'
  fi
  hex2dec "$(printf '%.2X' $(printf '%s' "${ip}" | tr '.' ' '))" >&9
} 9>&1 >&8

int2ip() {
  local int="${1}"; shift
  if ! is_int "${int}"; then
    print__warning '%s is not a valid integer number' "'${int}'"
    int=0
  fi
  local ip='' mask='' byte
  for byte in 3 2 1 0; do
    mask="$((255 << (8 * byte)))"
    byte="$(((int & mask) >> (8 * byte)))"
    ip="${ip}${byte}."
  done
  printf '%s' "${ip%?}" >&9
} 9>&1 >&8

cidr2netmask() {
  local cidr="${1}"; shift
  if ! is_cidr "${cidr}"; then
    print__warning '%s is not a valid cidr' "${cidr}"
    cidr=0
  fi
  local bin="$(printf '%*s' "$((cidr))" '' | tr ' ' 1; printf '%*s' "$((32 - cidr))" '' | tr ' ' 0)"
  int2ip "$(bin2dec "${bin}")" >&9
} 9>&1 >&8

str2chars() {
  printf '%s' "${1}" | sed -e 's/./& /' >&9
} 9>&1 >&8

__cast__load() {
  export __SHELI_LIB__LOADING='cast'

  dep__lib 'test' 'math'
  dep__pkg_opt 'bc'

  cast__set_scale 2
  export CAST__PAD_BIN=8
  export CAST__PAD_DEC=0
  export CAST__PAD_OCT=3
  export CAST__PAD_HEX=2

  unset __SHELI_LIB__LOADING
}

__cast__load "${@}" || exit "${?}"
export __SHELI_LIB_CAST__LOADING=false
export __SHELI_LIB_CAST__LOADED=true

