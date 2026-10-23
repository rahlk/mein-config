# mein-config

Personal terminal configuration for macOS and the Ubuntu SSH host.

## Terminal appearance

- Local Ghostty: bright green text on an almost-black green background.
- Ubuntu SSH profile: bright orange text on black.
- Departure Mono font, with Maple Mono NF for Nerd Font symbols.
- Blinking block cursor with smooth movement and a green halo trail.
- CRT curvature, scan lines, and text bloom that gradually builds between band passes.
- Each passing band resets the bloom to almost zero as it crosses the screen.
- Light continuous jitter and 0.5-second bursts at random 1–5 minute intervals.
- Moving bands at random 20–40 second intervals, with a 1.5-second travel time.
- Monochrome output for both profiles, including application RGB colors.

## Files

| Path | Purpose |
| --- | --- |
| `.config/ghostty/` | Ghostty settings, active shaders, palettes, and SSH launcher |
| `.config/zellij/` | Local Zellij settings and green theme |
| `.local/share/fonts/DepartureMono/` | Departure Mono 1.500 and its license |
| `macos/Services/` | Cmd+Shift+T service for the SSH window |
| `remote/.config/zellij/` | Orange SSH theme and bottom tab-bar layout |
| `remote/ssh-zellij.zsh` | Remote Zsh auto-start block for local and SSH Zellij sessions |

Only the active shader versions are included. Ghostty runs them in the order listed in its configuration.

## Restore on macOS

Copy the contents of `.config/ghostty/` into `~/.config/ghostty/`.
The repository uses the filename `config`; the current installation uses `config.ghostty`.
Use the settings from this repository in the active configuration file. Avoid keeping conflicting copies of both files.

Copy `.config/zellij/` into `~/.config/zellij/`.
Install `DepartureMono-Regular.otf` in `~/Library/Fonts/`.
Install Maple Mono NF separately for Nerd Font symbols.

Copy the workflow from `macos/Services/` into `~/Library/Services/`.
Enable its Cmd+Shift+T shortcut in macOS Keyboard settings under Services.
The launcher creates a separate SSH window because borderless windows cannot host native tabs reliably.
The service and launcher contain personal paths under `/Users/rkrsn` and the `stagger-juice` SSH destination.

Reload Ghostty after applying the files.
For shader edits, change the configured shader filename to force a rebuild in Ghostty 1.3.1.

## Restore on the Ubuntu host

Copy `remote/.config/zellij/` into `~/.config/zellij/` on the host.
Replace the existing Zellij auto-start block in `~/.zshrc` with `remote/ssh-zellij.zsh`.
Do not keep both auto-start blocks.
The SSH block preserves the client terminal palette and selects the orange Zellij theme.
The normal remote desktop session keeps its existing Zellij configuration.

Install the font in `~/.local/share/fonts/DepartureMono/`, then run `fc-cache -f`.
The configured desktop sizes are Departure Mono 11.5 for ddterm and 12 for GNOME Terminal.
The system monospace default is Departure Mono 11.

If the host reports `xterm-ghostty: unknown terminal type`, install Ghostty's terminfo from the Mac:

```sh
infocmp -x -A /Applications/Ghostty.app/Contents/Resources/terminfo xterm-ghostty |
  ssh rkrsn@stagger-juice.ddns.net 'mkdir -p ~/.terminfo && tic -x -o ~/.terminfo -'
```

## Sources

The CRT and glitch shaders derive from [hackrdotsh/ghostty-shaders](https://github.com/hackrdotsh/ghostty-shaders).
Their original source and license comments remain in the shader files.
Departure Mono includes its license beside the font file.
