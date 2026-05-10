#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
interval="${1:-5}"

if [[ ! "$interval" =~ ^[0-9]+$ ]] || [[ "$interval" -lt 1 ]]; then
  echo "usage: $0 [positive-integer-seconds]" >&2
  exit 2
fi

if command -v watch >/dev/null 2>&1; then
  exec watch -n "$interval" "$repo_root/scripts/status.sh"
fi

while true; do
  clear
  "$repo_root/scripts/status.sh"
  sleep "$interval"
done
