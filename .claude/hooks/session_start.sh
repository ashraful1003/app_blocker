#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter &>/dev/null; then
  echo "Flutter not found. Running setup_cloud.sh..."
  bash scripts/setup_cloud.sh
fi
