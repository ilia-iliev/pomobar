# Pomodoro timer for the i3status bar — plan

A minimal pomodoro timer shown in the i3status/swaybar status line. One POSIX
shell script, one state file, two keybindings. No daemon, no polling loop of
its own: the bar already ticks on an interval, so the timer is pure state plus
arithmetic computed at render time.

## Components

### 1. State file

`$XDG_RUNTIME_DIR/pomodoro.state` — lives on tmpfs, so no disk writes and it
is cleared on reboot. Format is sourceable shell variables, so the script
loads it with `.` (dot) and needs no parser:

```sh
status=running        # idle | running | paused
end_time=1756730000   # epoch seconds; set on start/resume, meaningful while running
remaining=840         # seconds left; written only on pause
```

Key design point: elapsed time is never stored and never ticked. While
running, only the target `end_time` exists; remaining time is derived as
`end_time - now` whenever something asks. "Done" is not a stored state — it
is detected at render time (`now >= end_time` → show the tomato).

Missing file means `idle`. `toggle` recreates it when starting a timer. Writes
go through a temp-file-and-`mv` so the bar never reads a half-written file.

### 2. `pomo` script

One POSIX shell script (`#!/bin/sh`, Linux-only, no bashisms needed) with
subcommands — the only thing that touches the state file:

- `pomo toggle` — idle/done → running with the default duration; running →
  paused with `remaining` stored; paused → running with `end_time = now +
  remaining`. One key handles start, pause, and resume.
- `pomo stop` — remove the state file (back to idle, bar segment disappears).
- `pomo render` — read state, print the bar text, exit. Does not mutate
  anything.

After any mutating subcommand, the script runs `pkill -USR1 i3status` —
i3status refreshes immediately on SIGUSR1 — so a keypress updates the bar
instantly instead of waiting for the next tick.

Only external commands used: `date +%s`, `mv`, `pkill`. Everything else is
shell arithmetic and parameter expansion.

### 3. Bar integration

i3status cannot run commands per-module, so the status line is produced by a
pipe wrapper set as the bar's `status_command`:

```
status_command i3status | pomo wrap
```

`pomo wrap` is a `while read line` loop that prepends the rendered pomodoro
segment to each line i3status emits. Two variants, pick by i3status
`output_format`:

- **Plain text** (`output_format = "none"` or default under a pipe):
  trivial — `printf '%s%s\n' "$(render)" "$line"`. Recommended starting
  point; costs colors and click events for the whole bar.
- **JSON** (`output_format = "i3bar"`): keep colors by injecting a block via
  string surgery — each stream line after the header starts with `,[` (or
  `[`), so insert `{"full_text":"…"},` right after the bracket. No jq; pure
  parameter expansion.

The wrapper is one long-lived shell process that sleeps in `read` between
i3status ticks — effectively zero CPU. Since it renders in-process (a shell
function, not a `pomo render` subprocess), each tick forks nothing except
`date +%s` — and even that can be avoided with `$EPOCHSECONDS`-style
builtins if we allow bash, or accepted as one fork per interval.

### 4. Keybindings

Plain `bindsym` entries in the i3/sway config:

```
bindsym $mod+p       exec pomo toggle
```

No IPC protocol or socket — the state file is the IPC.

## State machine

```
idle/done ──toggle──▶ running ──(end_time reached, render-time)──▶ done(🍅)
                      │   ▲
                   toggle toggle
                      ▼   │
                     paused
```

## Display format

- Running: rounded-up minutes — `ceil(remaining / 60)` via
  `$(( (remaining + 59) / 60 ))`. A fresh 25-minute timer shows `25m`, the
  final minute shows `1m`, never a misleading `0m`. The displayed value
  changes only once per minute, so i3status's default 5 s interval is fine.
- Paused: distinct glyph, e.g. `⏸ 12m`.
- Done: `🍅`.
- Idle: empty string (segment absent).

Duration, glyphs, and format string live as variables at the top of the
script — no config file for a personal tool.

## Edge cases

- **Suspend/resume**: wall-clock `end_time` means the timer counts through
  suspend; waking past the interval shows 🍅. Arguably correct for pomodoro;
  a systemd sleep hook calling `pomo toggle` is a later enhancement if not.
- **Corrupt/missing state**: render treats it as idle; `toggle` starts anew.
- **Bar restart**: state survives in the file; the timer reappears intact.
- **Completion notification** (optional, later): on `toggle`, spawn a detached
  `sleep <duration> && notify-send`, which re-checks the state file before
  firing so a restart or pause invalidates the stale notification.

## Deliverables

1. `pomo` — the script (CLI subcommands + `wrap` mode in one file), installed
   on `$PATH` via this dotfiles repo.
2. Bar config change: `status_command i3status | pomo wrap`.
3. Two `bindsym` lines in the i3/sway config.
