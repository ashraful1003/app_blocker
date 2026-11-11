#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-}"
if [ -z "$FILE" ]; then
  exit 0
fi

case "$FILE" in
  *.g.dart|*.freezed.dart)
    echo "BLOCKED: $FILE is generated. Run scripts/gen.sh instead." >&2
    exit 1
    ;;
  */pigeons/*.pigeon.dart|*/.dart_tool/*)
    echo "BLOCKED: $FILE is generated. Run scripts/gen.sh instead." >&2
    exit 1
    ;;
  docs/product/*)
    echo "BLOCKED: $FILE belongs to the client. Do not edit." >&2
    exit 1
    ;;
esac
