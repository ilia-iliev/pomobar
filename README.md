# pomobar

A minimal Pomodoro timer for i3status and swaybar. It stores state in
`$XDG_RUNTIME_DIR` and has no daemon.

## Install

Clone and symlink the script:

```sh
git clone https://github.com/ilia-iliev/pomobar.git ~/src/pomobar
ln -s ~/src/pomobar/pomo ~/.local/bin/pomo
```

Ensure `~/.local/bin` is on `PATH`, then verify it:

```sh
pomo start
pomo render
```

Or install the script directly:

```sh
curl -fsSL https://raw.githubusercontent.com/ilia-iliev/pomobar/main/pomo \
  -o ~/.local/bin/pomo
chmod +x ~/.local/bin/pomo
```

## i3 / sway

Pipe i3status through the wrapper:

```
status_command i3status | pomo wrap
```

Add keybindings:

```
bindsym $mod+p       exec pomo start
bindsym $mod+Shift+p exec pomo toggle
```

Commands: `pomo start [minutes]`, `pomo toggle`, `pomo stop`, and `pomo render`.
