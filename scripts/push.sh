#!/usr/bin/env bash
set -euo pipefail

message="${1:-Update app}"

git add .

if git diff --cached --quiet; then
  echo "没有需要提交的改动。"
  exit 0
fi

git commit -m "$message"
git push origin main
