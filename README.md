# pomobar

A minimal Pomodoro timer for i3status and swaybar.

Completed rounds are shown before a running timer (`2 55m`), reset at midnight, and persist across restarts. State is stored in
`$XDG_STATE_HOME/pomobar/state` (normally `~/.local/state/pomobar/state`).

## Install

Clone and symlink the script:

```sh
git clone https://github.com/ilia-iliev/pomobar.git ~/src/pomobar
ln -s ~/src/pomobar/pomo ~/.local/bin/pomoOr install the script directly:

Or install directly:

```sh
curl -fsSL https://raw.githubusercontent.com/ilia-iliev/pomobar/main/pomo \
  -o ~/.local/bin/pomo
chmod +x ~/.local/bin/pomo
```

Verify:

```bash
pomo toggle
pomo render
```

## i3 / sway

Pipe i3status through the wrapper:

```
status_command i3status | pomo wrap
```

Add keybindings:

```
bindsym $mod+p       exec pomo toggle
```

Commands: `pomo toggle` (starts when inactive; otherwise pauses/resumes), `pomo stop`, and `pomo render`.
