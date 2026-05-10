#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
control_dir="$repo_root/work/control"
instructions_file="$control_dir/INSTRUCTIONS.md"
pause_file="$control_dir/PAUSE"
stop_file="$control_dir/STOP"
pid_file="$repo_root/work/runs/current.pid"

mkdir -p "$control_dir"

usage() {
  cat >&2 <<'USAGE'
usage:
  scripts/control.sh instruction TEXT...
  scripts/control.sh pause
  scripts/control.sh resume
  scripts/control.sh stop
  scripts/control.sh clear-stop
  scripts/control.sh interrupt

Notes:
  instruction  Appends operator instructions read by the next iteration.
  pause        Stops the loop before starting another iteration.
  resume       Removes PAUSE.
  stop         Requests loop stop and interrupts the current Codex process.
  interrupt    Sends SIGINT to the current Codex process only.
USAGE
}

cmd="${1:-}"
case "$cmd" in
  instruction)
    shift
    if [[ "$#" -eq 0 ]]; then
      echo "missing instruction text" >&2
      usage
      exit 2
    fi
    {
      printf '\n## %s\n\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      printf '%s\n' "$*"
    } >> "$instructions_file"
    echo "appended instruction to $instructions_file"
    ;;
  pause)
    printf 'pause requested at %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$pause_file"
    echo "pause requested: $pause_file"
    ;;
  resume)
    rm -f "$pause_file"
    echo "pause cleared"
    ;;
  stop)
    printf 'stop requested at %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$stop_file"
    echo "stop requested: $stop_file"
    if [[ -f "$pid_file" ]]; then
      pid="$(cat "$pid_file")"
      if kill -0 "$pid" 2>/dev/null; then
        kill -INT "$pid"
        echo "sent SIGINT to $pid"
      fi
    fi
    ;;
  clear-stop)
    rm -f "$stop_file"
    echo "stop cleared"
    ;;
  interrupt)
    if [[ ! -f "$pid_file" ]]; then
      echo "no current Codex pid file: $pid_file" >&2
      exit 1
    fi
    pid="$(cat "$pid_file")"
    if ! kill -0 "$pid" 2>/dev/null; then
      echo "Codex process is not running: $pid" >&2
      exit 1
    fi
    kill -INT "$pid"
    echo "sent SIGINT to $pid"
    ;;
  *)
    usage
    exit 2
    ;;
esac

