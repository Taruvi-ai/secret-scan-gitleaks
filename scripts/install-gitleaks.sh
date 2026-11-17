#!/usr/bin/env bash
set -euo pipefail

command -v jq >/dev/null || { echo "::error title=jq is required::Install jq on this runner."; exit 1; }

version=8.30.1
case "$(uname -m)" in
  x86_64)
    arch=x64
    checksum=551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb
    ;;
  aarch64|arm64)
    arch=arm64
    checksum=e4a487ee7ccd7d3a7f7ec08657610aa3606637dab924210b3aee62570fb4b080
    ;;
  *)
    echo "::error title=Unsupported runner architecture::Gitleaks is pinned for Linux x64 and arm64 runners."
    exit 1
    ;;
esac

install_dir="$RUNNER_TEMP/gitleaks-$version"
mkdir -p "$install_dir"
archive="$install_dir/gitleaks_${version}_linux_${arch}.tar.gz"
curl --fail --silent --show-error --location --retry 3 \
  "https://github.com/gitleaks/gitleaks/releases/download/v${version}/gitleaks_${version}_linux_${arch}.tar.gz" \
  --output "$archive"
printf '%s  %s\n' "$checksum" "$archive" | sha256sum --check --status
tar -xzf "$archive" -C "$install_dir" gitleaks
chmod +x "$install_dir/gitleaks"
"$install_dir/gitleaks" version
printf '%s\n' "$install_dir" >> "$GITHUB_PATH"
