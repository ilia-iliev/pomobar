#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
export POMO_STATE_FILE="$tmp/state"
today=$(date +%F)
now=$(date +%s)

state() {
    printf 'status=%s\nstart_time=%s\nend_time=%s\nremaining=120\ncompleted=%s\nstate_date=%s\n' \
        "$1" "$((now - 120))" "$((now + 120))" "$2" "$today" >"$POMO_STATE_FILE"
}

check() {
    actual=$($repo/pomo render)
    if [ "$actual" != "$1" ]; then
        printf 'expected <%s>, got <%s>\n' "$1" "$actual" >&2
        exit 1
    fi
}

state running 0
check '6 2m'
state running 4
check '2 2m'
state running 6
check '0 2m'
state running 7
check '0✅2m'
state running 9
check '2✅2m'
state paused 4
check '2 ⏸️ 2m'
state paused 6
check '0 ⏸️ 2m'
state paused 7
check '0✅⏸️ 2m'
state done 7
check '0✅🍅🍅🍅'

state running 7
actual=$(printf '%s\n' '{"version":1}' '[' '[{"full_text":"clock"}]' | "$repo/pomo" wrap)
case $actual in
    *'"full_text":"0✅2m"'*) ;;
    *) printf 'missing tick at target: %s\n' "$actual" >&2; exit 1 ;;
esac

state running 9
actual=$(printf '%s\n' '{"version":1}' '[' ',[{"full_text":"clock"}]' | "$repo/pomo" wrap)
case $actual in
    *',[{"full_text":"2✅2m"},{"full_text":"clock"}]'*) ;;
    *) printf 'missing tick for extra rounds: %s\n' "$actual" >&2; exit 1 ;;
esac

state running 6
actual=$(printf '%s\n' '{"version":1}' '[' '[{"full_text":"clock"}]' | "$repo/pomo" wrap)
case $actual in
    *'"full_text":"0 2m"'*) ;;
    *) printf 'missing active last round: %s\n' "$actual" >&2; exit 1 ;;
esac
case $actual in
    *'✅'*|*'"color"'*) printf 'premature tick or color: %s\n' "$actual" >&2; exit 1 ;;
esac

state running 6
# Expiration credits a round and reaches the target.
printf 'end_time=%s\n' "$((now - 1))" >>"$POMO_STATE_FILE"
check '0✅🍅🍅🍅'
grep -q '^completed=7$' "$POMO_STATE_FILE"

"$repo/pomo" reset
state running 0
check '6 2m'

printf 'countdown tests passed\n'
