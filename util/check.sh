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

  if [ -z "${CHECK__TEST_LIST##*${test}*}" ]; then
    if ! "${test}" "${data}"; then
      case "${level}" in info|warning|error|debug) "print__${level}" "${text}";; esac
      return "${EX_DATAERR}"
    fi
  fi
  return 0
}

__check__load() {
  export __SHELI_LIB__LOADING='check'

  dep__lib 'print' 'test'
  export CHECK__TEST_LIST; CHECK__TEST_LIST="$(
    grep -e '^[[:space:]]*is_[^( ]\+(' util/test.sh \
    | tr -d '() {'
    #| tr '\n' "${FS}"
  )"
  local funct_prefix='check__'
  local test check funct_name
  while IFS= read -r test; do
    check="${test#is_}"
    for level in 'silent' 'info' 'warning' 'error' 'debug'; do
      funct_name="${funct_prefix}"
      [ "${level}" != 'silent' ] && funct_name="${funct_name}${level}_"
      funct_name="${funct_name}${check}"
      funct_check="__${funct_prefix}${check}"
      eval "
${funct_check}() {
  local level=\"\${1}\"; shift
  local data=\"\${1}\"; shift
  local text=\"\${1}\"; shift
  __check \"\${level}\" ${test} \"\${data}\" \"\${text}\"
}

${funct_name}() {
  ${funct_check} '${level}' \"\${1}\" \"\${2}\"
}"
      export "${funct_name}"
    done
  done <<EOF
${CHECK__TEST_LIST%?}
EOF
  unset __SHELI_LIB__LOADING
}

__check__load "${@}" || exit "${?}"
export __SHELI_LIB_CHECK__LOADING=false
export __SHELI_LIB_CHECK__LOADED=true

