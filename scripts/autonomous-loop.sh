#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
prompt_file="${CODEX_PROMPT_FILE:-$repo_root/work/prompts/continue.md}"
iterations="${1:-1}"
mode="${CODEX_LOOP_MODE:-new}"
model="${CODEX_MODEL:-gpt-5.5}"
reasoning_effort="${CODEX_REASONING_EFFORT:-xhigh}"
out_dir="$repo_root/work/runs"
control_dir="$repo_root/work/control"
pause_file="$control_dir/PAUSE"
stop_file="$control_dir/STOP"
pid_file="$out_dir/current.pid"
start_file="$out_dir/current.start"

mkdir -p "$out_dir" "$control_dir"
trap 'rm -f "$pid_file" "$start_file"' EXIT

if [[ ! "$iterations" =~ ^[0-9]+$ ]] || [[ "$iterations" -lt 1 ]]; then
  echo "usage: $0 [iterations]" >&2
  echo "iterations must be a positive integer" >&2
  exit 2
fi

if [[ ! -f "$prompt_file" ]]; then
  echo "missing prompt file: $prompt_file" >&2
  exit 2
fi

common_flags=(
  "--dangerously-bypass-approvals-and-sandbox"
  "-m" "$model"
  "-c" "model_reasoning_effort=\"$reasoning_effort\""
)

start_codex() {
  if command -v setsid >/dev/null 2>&1; then
    setsid "$@" &
  else
    "$@" &
  fi

  codex_pid="$!"
  printf '%s\n' "$codex_pid" > "$pid_file"
  awk '{ print $22 }' "/proc/$codex_pid/stat" > "$start_file" 2>/dev/null || true

  if wait "$codex_pid"; then
    codex_status=0
  else
    codex_status="$?"
  fi

  rm -f "$pid_file" "$start_file"
  return "$codex_status"
}

for ((i = 1; i <= iterations; i++)); do
  stamp="$(date -u +%Y%m%dT%H%M%S%NZ)"
  output_file="$out_dir/last-message-${stamp}-iter${i}.txt"

  if [[ -e "$stop_file" ]]; then
    echo "== stop requested by $stop_file"
    exit 0
  fi

  while [[ -e "$pause_file" ]]; do
    echo "== paused by $pause_file; remove it or run scripts/control.sh resume"
    sleep 5
    if [[ -e "$stop_file" ]]; then
      echo "== stop requested by $stop_file"
      exit 0
    fi
  done

  echo "== mistral-asm autonomous iteration $i/$iterations ($mode, $stamp, $model/$reasoning_effort)"

  case "$mode" in
    new)
      if start_codex codex exec \
        --cd "$repo_root" \
        "${common_flags[@]}" \
        -o "$output_file" \
        - < "$prompt_file"; then
        codex_status=0
      else
        codex_status="$?"
      fi
      ;;
    resume)
      if (
        cd "$repo_root"
        start_codex codex exec resume \
          --last \
          "${common_flags[@]}" \
          -o "$output_file" \
          - < "$prompt_file"
      ); then
        codex_status=0
      else
        codex_status="$?"
      fi
      ;;
    *)
      echo "CODEX_LOOP_MODE must be 'new' or 'resume'" >&2
      exit 2
      ;;
  esac

  if [[ "$codex_status" -ne 0 ]]; then
    if [[ -e "$stop_file" ]]; then
      echo "== codex exited with status $codex_status after stop request"
      exit "$codex_status"
    fi

    if [[ "$i" -lt "$iterations" && -s "$control_dir/INBOX.md" ]]; then
      echo "== codex exited with status $codex_status and inbox is pending; continuing to next iteration"
    else
      exit "$codex_status"
    fi
  fi

  echo "== last message: $output_file"
done
