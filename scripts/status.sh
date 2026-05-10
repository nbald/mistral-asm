#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

echo "== git"
git status --short --branch
echo

if git rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "== recent commits"
  git log --oneline -8
  echo
fi

echo "== state"
if [[ -f work/STATE.md ]]; then
  sed -n '1,180p' work/STATE.md
else
  echo "missing work/STATE.md"
fi
echo

echo "== recent worklog"
if [[ -f work/WORKLOG.md ]]; then
  tail -80 work/WORKLOG.md
else
  echo "missing work/WORKLOG.md"
fi
echo

echo "== operator control"
if [[ -e work/control/PAUSE ]]; then
  echo "pause: requested"
else
  echo "pause: clear"
fi
if [[ -e work/control/STOP ]]; then
  echo "stop: requested"
else
  echo "stop: clear"
fi
if [[ -f work/runs/current.pid ]]; then
  echo "current pid: $(cat work/runs/current.pid)"
  if [[ -f work/runs/current.start ]]; then
    echo "current start: $(cat work/runs/current.start)"
  fi
else
  echo "current pid: none"
fi
if [[ -f work/control/INBOX.md ]]; then
  echo
  echo "== pending operator inbox"
  tail -60 work/control/INBOX.md
fi
echo

latest_message="$(find work/runs -maxdepth 1 -type f -name 'last-message-*.txt' 2>/dev/null | sort | tail -1 || true)"
if [[ -n "$latest_message" ]]; then
  echo "== latest codex final message ($latest_message)"
  tail -80 "$latest_message"
else
  echo "== latest codex final message"
  echo "none yet"
fi
