#!/bin/dash

# Check if loaded by sheli
if ! "${__SHELI__LOADING-false}"; then
  printf 'This library is intended to be imported by sheli.\n' >&2
  exit 69
fi
# If we are here, we have all the sheli env

"${__SHELI_LIB_CAST__LOADED-false}" && return                  # If loaded, do nothing
"${__SHELI_LIB_CAST__LOADING-false}" && exit $((EX__SOFTWARE)) # If loading, something is wrong

export __SHELI_LIB_CAST__LOADING=true

cast__set_scale() {
  export SCALE="$((${1}))"
}

int2float() {
  local int="${1}"; shift
  if ! is_int "${int}"; then
    print_warning '%s is not a valid integer number' "${int}"
    int=0
  fi
  printf '%.*f' $((SCALE)) "${int}"
}

bin2oct() {
  local bin="${1}"; shift
  if ! is_bin "${bin}"; then
    print_warning '%s is not a valid binary number' "${bin}"
    bin=0
  fi
  local oct; oct="$(printf 'ibase=2; obase=8; %s\n' "${bin}" | bc)"
  local pad=$((PAD_OCT - ${#oct} % PAD_OCT))
  [ $((pad)) -ne $((PAD_OCT)) ] && printf '%*s' $((pad)) '' | tr ' ' 0
  printf '%s' "${oct}"
}

bin2dec() {
  local bin="${1}"; shift
  if ! is_bin "${bin}"; then
    print_warning '%s is not a valid binary number' "${bin}"
    bin=0
  fi
  local dec; dec="$(printf 'ibase=2; %s\n' "${bin}" | bc)"
  printf '%s' "${dec}"
}

bin2hex() {
  local bin="${1}"; shift
  local dec; dec="$(bin2dec "${bin}")"
  local hex; hex="$(printf 'obase=16; %s\n' "${dec}" | bc)"
  local pad=$((PAD_HEX - ${#hex} % PAD_HEX))
  [ $((pad)) -ne $((PAD_HEX)) ] && printf '%*s' $((pad)) '' | tr ' ' 0
  printf '%s' "${hex}"
}

oct2bin() {
  local oct="${1}"; shift
  if ! is_oct "${oct}"; then
    print_warning '%s is not a valid octal number' "${oct}"
    oct=0
  fi
  local bin; bin="$(printf 'ibase=8; obase=2; %s\n' "${oct}" | bc)"
  local pad=$((PAD_BIN - ${#bin} % PAD_BIN))
  [ $((pad)) -ne $((PAD_BIN)) ] && printf '%*s' $((pad)) '' | tr ' ' 0
  printf '%s' "${bin}"
}

oct2dec() {
  local oct="${1}"; shift
  if ! is_oct "${oct}"; then
    print_warning '%s is not a valid octal number' "${oct}"
    oct=0
  fi
  local dec; dec="$(printf 'ibase=8; %s\n' "${oct}" | bc)"
  printf '%s' "${dec}"
}

oct2hex() {
  local oct="${1}"; shift
  local dec; dec="$(oct2dec "${oct}")"
  local hex; hex="$(printf 'obase=16; %s\n' "${dec}" | bc)"
  local pad=$((PAD_HEX - ${#hex} % PAD_HEX))
  [ $((pad)) -ne $((PAD_HEX)) ] && printf '%*s' $((pad)) '' | tr ' ' 0
  printf '%s' "${hex}"
}

dec2bin() {
  local dec="${1}"; shift
  if ! is_int "${dec}"; then
    print_warning '%s is not a valid decimal number' "${dec}"
    dec=0
  fi
  local bin; bin="$(printf 'obase=2; %s\n' "${dec}" | bc)"
  local pad=$((PAD_BIN - ${#bin} % PAD_BIN))
  [ $((pad)) -ne $((PAD_BIN)) ] && printf '%*s' $((pad)) '' | tr ' ' 0
  printf '%s' "${bin}"
}

dec2oct() {
  local dec="${1}"; shift
  if ! is_int "${dec}"; then
    print_warning '%s is not a valid decimal number' "${dec}"
    dec=0
  fi
  local oct; oct="$(printf 'obase=8; %s\n' "${dec}" | bc)"
  local pad=$((PAD_OCT - ${#oct} % PAD_OCT))
  [ $((pad)) -ne $((PAD_OCT)) ] && printf '%*s' $((pad)) '' | tr ' ' 0
  printf '%s' "${oct}"
}

dec2hex() {
  local dec="${1}"; shift
  if ! is_int "${dec}"; then
    print_warning '%s is not a valid decimal number' "${dec}"
    dec=0
  fi
  local hex; hex="$(printf 'obase=16; %s\n' "${dec}" | bc)"
  local pad=$((PAD_HEX - ${#hex} % PAD_HEX))
  [ $((pad)) -ne $((PAD_HEX)) ] && printf '%*s' $((pad)) '' | tr ' ' 0
  printf '%s' "${hex}"
}

hex2bin() {
  local hex="${1}"; shift
  if ! is_hex "${hex}"; then
    print_warning '%s is not a valid hexadecimal number' "${hex}"
    hex=0
  fi
  hex="$(printf '%s' "${hex}" | tr '[a-z]' '[A-Z]')"
  local bin; bin="$(printf 'ibase=16; obase=2; %s\n' "${hex}" | bc)"
  local pad=$((PAD_BIN - ${#bin} % PAD_BIN))
  [ $((pad)) -ne $((PAD_BIN)) ] && printf '%*s' $((pad)) '' | tr ' ' 0
  printf '%s' "${bin}"
}

hex2oct() {
  local hex="${1}"; shift
  if ! is_hex "${hex}"; then
    print_warning '%s is not a valid hexadecimal number' "${hex}"
    hex=0
  fi
  hex="$(printf '%s' "${hex}" | tr '[a-z]' '[A-Z]')"
  local oct; oct="$(printf 'ibase=16; obase=8; %s\n' "${hex}" | bc)"
  local pad=$((PAD_OCT - ${#oct} % PAD_OCT))
  [ $((pad)) -ne $((PAD_OCT)) ] && printf '%*s' $((pad)) '' | tr ' ' 0
  printf '%s' "${oct}"
}

hex2dec() {
  local hex="${1}"; shift
  if ! is_hex "${hex}"; then
    print_warning '%s is not a valid hexadecimal number' "${hex}"
    hex=0
  fi
  hex="$(printf '%s' "${hex}" | tr '[a-z]' '[A-Z]')"
  local dec; dec="$(printf 'ibase=16; %s\n' "${hex}" | bc)"
  printf '%s' "${dec}"
}

date2epoch() {
  local date="${1}"; shift
  if ! is_date "${date}"; then
    print_warning '%s is not a valid date' "${date}"
    date=0
  fi
  date --date "${date}" +'%s'
}

epoch2date() {
  local epoch="${1}"; shift
  if ! is_epoch "${epoch}"; then
    print_warning '%s is not a valid epoch' "${epoch}"
    epoch=0
  fi
  date --date "@${epoch}"
}

epoch2wints() {
  local epoch="${1}"; shift
  if ! is_epoch "${epoch}"; then
    print_warning '%s is not a valid epoch' "${epoch}"
    epoch=0
  fi
  printf '(%s + 11644473600) * 10000000\n' "${epoch}" | bc
}

wints2epoch() {
  local wints="${1}"; shift
  if ! is_wints "${wints}"; then
    print_warning '%s is not a valid Windows Timestamp' "${wints}"
    wints=0
  fi
  printf '%s / 10000000 - 11644473600\n' "${wints}" | bc
}

ip2int() {
  local ip="${1}"; shift
  if ! is_ipv4 "${ip}"; then
    print_warning '%s is not a valid ipv4' "${ip}"
    ip='0.0.0.0'
  fi
  hex2dec "$(printf '%.2X' $(printf '%s' "${ip}" | sed -e 's/\./ /g'))"
}

int2ip() {
  local int="${1}"; shift
  if ! is_int "${int}"; then
    print_warning '%s is not a valid integer number' "${int}"
    int=0
  fi
  local ip=''
  for byte in $(printf '%.8X' "${int}" | sed -e 's/../& /g'); do
    byte="$(hex2dec "${byte}")"
    ip="${ip}${byte}."
  done
  printf '%s' "${ip%?}"
}

cidr2netmask() {
  local cidr="${1}"; shift
  if ! is_cidr "${cidr}"; then
    print_warning '%s is not a valid cidr' "${cidr}"
    cidr=0
  fi
  local bin="$(printf '%32s' '' | tr ' ' 1 | sed -e "s/1/0/$((cidr + 1))g")"
  int2ip "$(bin2dec "${bin}")"
}

str2chars() {
  printf '%s' "${1}" | sed -e 's/./& /g'
}

__cast__load() {
  export __SHELI_LIB__LOADING='cast'

  dep__pkg 'bc'
  export SCALE=2
  export PAD_BIN=8
  export PAD_DEC=0
  export PAD_OCT=3
  export PAD_HEX=2

  unset __SHELI_LIB__LOADING
}

__cast__load "${@}" || exit "${?}"
export __SHELI_LIB_CAST__LOADING=false
export __SHELI_LIB_CAST__LOADED=true

