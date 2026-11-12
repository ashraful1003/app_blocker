#!/usr/bin/env bash
set -euo pipefail

CMD="${1:-}"
if [ -z "$CMD" ]; then
  exit 0
fi

if echo "$CMD" | grep -qE 'git\s+push\s+--force'; then
  echo "BLOCKED: force-push is not allowed." >&2
  exit 1
fi

if echo "$CMD" | grep -qE 'git\s+push\s+.*\bmain\b'; then
  echo "BLOCKED: pushing to main is not allowed." >&2
  exit 1
fi

if echo "$CMD" | grep -qE 'rm\s+-rf\s+(?!build)'; then
  if ! echo "$CMD" | grep -qE 'rm\s+-rf\s+build'; then
    echo "BLOCKED: rm -rf outside build/ is not allowed." >&2
    exit 1
  fi
fi
