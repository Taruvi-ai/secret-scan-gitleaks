# Secret Scan with Gitleaks

A central GitHub Action for finding hardcoded secrets in repositories across `Taruvi-ai` and `eoxvantage-com`. It uses the rules in this repository’s `scans/.gitleaks.toml`; calling repositories do not need their own copy.

## Add the caller workflow

Create `.github/workflows/secret-scan.yml` in each repository:

```yaml
name: Secret scan

on:
  push:
    branches: ['**']
  pull_request:
  workflow_dispatch:
    inputs:
      scan_mode:
        description: What should be scanned?
        type: choice
        default: Working tree + git history
        options:
          - Working tree + git history
          - Working tree only
          - Git history only

jobs:
  scan:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: read
    env:
      GITLEAKS_LICENSE: ${{ secrets.GITLEAKS_LICENSE }}
    steps:
      - uses: Taruvi-ai/secret-scan-gitleaks/scans@main
        with:
          scan_mode: ${{ inputs.scan_mode || vars.SECRET_SCAN_MODE }}
```

The scan starts automatically for pushes to every branch and for new or updated pull requests. Tag pushes are excluded. The **Run workflow** button also provides a dropdown for a manual scan.

Each workflow has its own triggers. Adding this caller does not change when existing CI or Deploy workflows run.

## Scan modes

| Value | What it scans |
|---|---|
| `Working tree + git history` | Current files and Git history |
| `Working tree only` | Current files |
| `Git history only` | Git history |

For automatic runs, set an optional Actions variable named `SECRET_SCAN_MODE` in the calling organization or repository. Use one of the exact values above. If the variable is absent, the action scans both current files and Git history.

The manual dropdown selection takes priority over the variable. Organization variables must be configured separately in `Taruvi-ai` and `eoxvantage-com`.

## License secret

Add `GITLEAKS_LICENSE` for private repositories in an organization on GitHub Free, use a repository-level secret and variable: organization-level secrets and variables are unavailable to those repositories. GitHub also withholds Actions secrets from `pull_request` runs originating from forks. [GitHub Actions secrets](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets)

## Review findings

The action fails the scan job when it finds secrets. Open the run’s **Summary** tab for file locations and guidance. Rotate or revoke real credentials, including ones found only in Git history. Review false positives before updating the central `scans/.gitleaks.toml` or adding a `.gitleaksignore` entry.

## License

This repository is licensed under the [MIT License](LICENSE).
