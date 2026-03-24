#!/usr/bin/env bash
# Zellij wrapper: on SIGTERM/SIGINT/SIGHUP, quit and wipe session cache.
# On SIGKILL (uncatchable), session data persists on disk for resurrection.

_cache_dir() {
    if [[ -n "${XDG_CACHE_HOME}" ]]; then
        echo "${XDG_CACHE_HOME}/zellij"
    elif [[ "$(uname)" == "Darwin" ]]; then
        echo "${HOME}/Library/Caches/org.Zellij-Contributors.Zellij"
    else
        echo "${HOME}/.cache/zellij"
    fi
}

_cleanup() {
    rm -rf "$(_cache_dir)" 2>/dev/null
}

_handle_term() {
    [[ -n "${_ZELLIJ_PID}" ]] && kill -TERM "${_ZELLIJ_PID}" 2>/dev/null
    wait "${_ZELLIJ_PID}" 2>/dev/null
    _cleanup
    exit 0
}

trap _handle_term SIGTERM SIGINT SIGHUP

zellij "$@" &
_ZELLIJ_PID=$!
wait "${_ZELLIJ_PID}"
exit $?
