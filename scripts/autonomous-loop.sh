#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
prompt_file="${CODEX_PROMPT_FILE:-$repo_root/work/prompts/continue.md}"
iterations="${1:-1}"
mode="${CODEX_LOOP_MODE:-new}"
model="${CODEX_MODEL:-}"
out_dir="$repo_root/work/runs"

mkdir -p "$out_dir"

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
)

if [[ -n "$model" ]]; then
  common_flags+=("-m" "$model")
fi

for ((i = 1; i <= iterations; i++)); do
  stamp="$(date -u +%Y%m%dT%H%M%SZ)"
  output_file="$out_dir/last-message-$stamp.txt"

  echo "== mistral-asm autonomous iteration $i/$iterations ($mode, $stamp)"

  case "$mode" in
    new)
      codex exec \
        --cd "$repo_root" \
        "${common_flags[@]}" \
        -o "$output_file" \
        - < "$prompt_file"
      ;;
    resume)
      (
        cd "$repo_root"
        codex exec resume \
          --last \
          "${common_flags[@]}" \
          -o "$output_file" \
          - < "$prompt_file"
      )
      ;;
    *)
      echo "CODEX_LOOP_MODE must be 'new' or 'resume'" >&2
      exit 2
      ;;
  esac

  echo "== last message: $output_file"
done

