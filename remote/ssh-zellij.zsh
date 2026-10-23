# --- Zellij auto-start ---
# Keep ZELLIJ_AUTO_ATTACH=false so auto-start runs plain `zellij`, which honors
# session_name + attach_to_session in config.kdl. Setting it to true runs
# `zellij attach -c`, which ignores session_name and creates a random name.
export ZELLIJ_AUTO_ATTACH=false
export ZELLIJ_AUTO_EXIT=true
# Over SSH, use a separate session with the bottom tab bar layout
# (~/.config/zellij/layouts/ssh.kdl). Layouts are per-session, so this can't
# share the LOCAL session. Otherwise use Zellij's own auto-start, which honors
# ZELLIJ_AUTO_ATTACH / ZELLIJ_AUTO_EXIT and the session name in config.kdl.
# Skip auto-start in shells that apps spawn only to read the environment
# (Claude Desktop, VS Code) and in shells without a terminal. Those shells
# have no XDG_RUNTIME_DIR, so Zellij would start a stray LOCAL server under
# /tmp/zellij-1000 that real terminals (which use /run/user/1000/zellij) can't see.
if [[ -n "$CLAUDE_DESKTOP_RESOLVING_ENVIRONMENT" || -n "$VSCODE_RESOLVING_ENVIRONMENT" \
      || ! -t 0 || ! -t 1 ]]; then
    :
elif [[ -n "$SSH_CONNECTION" ]]; then
    if [[ -z "$ZELLIJ" ]]; then
        # Inherit the SSH client palette; do not override its terminal colours.
        # copy_command can't reach the SSH client's clipboard (no tty on the
        # server side), so the SSH session runs with a copy of config.kdl that
        # has copy_command removed, making zellij use its built-in OSC 52.
        _zellij_ssh_cfg="${XDG_RUNTIME_DIR:-/tmp}/zellij-ssh-config.kdl"
        sed -e 's|^copy_command |// copy_command |' -e 's|^theme .*|theme "retro-orange"|' ~/.config/zellij/config.kdl > "$_zellij_ssh_cfg"
        ZELLIJ_CONFIG_FILE="$_zellij_ssh_cfg" zellij attach -c "rkrsn@stagger-juice-SSH" options --default-layout ssh
        unset _zellij_ssh_cfg
        [[ "$ZELLIJ_AUTO_EXIT" == "true" ]] && exit
    fi
else
    eval "$(zellij setup --generate-auto-start zsh)"
fi
