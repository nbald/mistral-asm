#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
control_dir="$repo_root/work/control"
inbox_file="$control_dir/INBOX.md"
pause_file="$control_dir/PAUSE"
stop_file="$control_dir/STOP"
pid_file="$repo_root/work/runs/current.pid"

mkdir -p "$control_dir"

usage() {
  cat >&2 <<'USAGE'
usage:
  scripts/control.sh instruction TEXT...
  scripts/control.sh interrupt-instruction TEXT...
  scripts/control.sh clear-instructions
  scripts/control.sh pause
  scripts/control.sh resume
  scripts/control.sh stop
  scripts/control.sh clear-stop
  scripts/control.sh interrupt

Notes:
  instruction             Appends operator instructions for the next iteration.
  interrupt-instruction   Appends instructions and interrupts current Codex.
  clear-instructions      Removes the transient operator inbox.
  pause                   Stops the loop before starting another iteration.
  resume                  Removes PAUSE.
  stop                    Requests loop stop and interrupts current Codex.
  clear-stop              Removes STOP without changing PAUSE.
  interrupt               Sends SIGINT to the current Codex process group.
USAGE
}

append_instruction() {
  if [[ "$#" -eq 0 ]]; then
    echo "missing instruction text" >&2
    usage
    exit 2
  fi
  {
    printf '\n## %s\n\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '%s\n' "$*"
  } >> "$inbox_file"
  echo "appended instruction to $inbox_file"
}

interrupt_current() {
  if [[ ! -f "$pid_file" ]]; then
    echo "no current Codex pid file: $pid_file" >&2
    return 1
  fi

  pid="$(cat "$pid_file")"
  if [[ ! "$pid" =~ ^[0-9]+$ ]]; then
    echo "invalid Codex pid file: $pid_file" >&2
    return 1
  fi

  if kill -0 "-$pid" 2>/dev/null; then
    kill -INT "-$pid"
    echo "sent SIGINT to process group $pid"
    return 0
  fi

  if kill -0 "$pid" 2>/dev/null; then
    kill -INT "$pid"
    echo "sent SIGINT to process $pid"
    return 0
  fi

  echo "Codex process is not running: $pid" >&2
  return 1
}

cmd="${1:-}"
case "$cmd" in
  instruction)
    shift
    append_instruction "$@"
    ;;
  interrupt-instruction)
    shift
    append_instruction "$@"
    interrupt_current || true
    ;;
  clear-instructions)
    rm -f "$inbox_file"
    echo "operator inbox cleared"
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
    interrupt_current || true
    ;;
  clear-stop)
    rm -f "$stop_file"
    echo "stop cleared"
    ;;
  interrupt)
    interrupt_current
    ;;
  *)
    usage
    exit 2
    ;;
esac
