# pomobar

A minimal Pomodoro timer for i3status/swaybar.

The counter shows rounds remaining after the current timer: with 3 rounds left, a running timer displays `2 24m`. Starting a timer toward the default goal of 7 shows `6 60m`; when the last timer is running, it shows `0 60m`. A green tick appears only after completing the goal (`0✅🍅🍅🍅`), and extra completed rounds count up (`1✅🍅🍅🍅`). The count resets at midnight and persists across restarts. `pomo reset` clears
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
