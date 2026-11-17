#!/usr/bin/env bash
set -euo pipefail
case "${REQUESTED_MODE:-Working tree + git history}" in
  "Working tree + git history") mode=both ;;
  "Working tree only")          mode=working-tree-only ;;
  "Git history only")           mode=git-history-only ;;
  *)
    echo "::error title=Invalid scan option::Unknown scan option '${REQUESTED_MODE}'. Use one of: Working tree + git history, Working tree only, Git history only. If this value comes from the SECRET_SCAN_MODE variable, fix it under Settings > Secrets and variables > Actions > Variables."
    exit 1
    ;;
esac
echo "SCAN_MODE=$mode" >> "$GITHUB_ENV"
echo "Scan mode: $mode"
