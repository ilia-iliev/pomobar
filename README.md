# pomobar

A minimal Pomodoro timer for i3status/swaybar.

The round counter starts at 7 and counts down with each completed timer (`7 60m`, then `6 60m`). At 0 it turns green in i3bar and counts up for extra rounds. The count resets at midnight and persists across restarts. `pomo reset` clears
the count and the current timer to start the day over. Set `TARGET_ROUNDS` in the script to change the goal. State is stored in
`$XDG_STATE_HOME/pomobar/state` (normally `~/.local/state/pomobar/state`).

## Install

Clone and symlink the script:

```sh
git clone https://github.com/ilia-iliev/pomobar.git ~/src/pomobar
ln -s ~/src/pomobar/pomo ~/.local/bin/pomo
```

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

Add keybinding:

```
bindsym $mod+p       exec pomo toggle
```
