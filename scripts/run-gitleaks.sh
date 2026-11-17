#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$RUNNER_TEMP/secret-scan"
# findings do not fail this step (exit-code 0); the last step decides
if [ "$SCAN_MODE" = "both" ] || [ "$SCAN_MODE" = "working-tree-only" ]; then
  gitleaks dir . --config "$GITLEAKS_CONFIG_PATH" --redact --no-banner --log-level error \
    --exit-code 0 --report-format json --report-path "$RUNNER_TEMP/secret-scan/working-tree.json"
fi
if [ "$SCAN_MODE" = "both" ] || [ "$SCAN_MODE" = "git-history-only" ]; then
  gitleaks git . --config "$GITLEAKS_CONFIG_PATH" --redact --no-banner --log-level error \
    --exit-code 0 --report-format json --report-path "$RUNNER_TEMP/secret-scan/git-history.json"
fi
