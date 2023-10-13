#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later

declare _Blue
declare _creset

themes.help(){
    cat <<EOF
themes.:
  all       : build all themes
  live      : to get live builds of CSS & JS use 'LIVE_THEME=simple make run'
  simple.:
    build   : build simple theme
    test    : test simple theme
  custom.:
    build   : build custom theme
    test    : test custom theme
EOF
}

themes.all() {
    (   set -e
        pygments.less
        node.env
        themes.simple
        themes.custom
    )
    dump_return $?
}

themes.live() {
    local LIVE_THEME="${LIVE_THEME:-${1}}"
    case "${LIVE_THEME}" in
        simple)
            theme="searx/static/themes/${LIVE_THEME}"
            ;;
        '')
            die_caller 42 "missing theme argument"
            ;;
        *)
            die_caller 42 "unknown theme '${LIVE_THEME}' // [simple, custom]'"
            ;;
    esac
    build_msg GRUNT "theme: $1 (live build)"
    nodejs.ensure
    cd "${theme}"
    {
        npm install
        npm run watch
    } 2>&1 \
        | prefix_stdout "${_Blue}THEME ${1} ${_creset}  " \
        | grep -E --ignore-case --color 'error[s]?[:]? |warning[s]?[:]? |'
}

themes.simple() {
    (   set -e
        build_msg GRUNT "theme: simple"
        npm --prefix searx/static/themes/simple run build
    )
    dump_return $?
}

themes.simple.test() {
    build_msg TEST "theme: simple"
    nodejs.ensure
    npm --prefix searx/static/themes/simple install
    npm --prefix searx/static/themes/simple run test
    dump_return $?
}

themes.custom() {
    (   set -e
        build_msg GRUNT "theme: custom"
        npm --prefix searx/static/themes/custom run build
    )
    dump_return $?
}

themes.simple.test() {
    build_msg TEST "theme: cystom"
    nodejs.ensure
    npm --prefix searx/static/themes/custom install
    npm --prefix searx/static/themes/custom run test
    dump_return $?
}
