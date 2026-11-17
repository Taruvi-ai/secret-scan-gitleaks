# Secret Scan with Gitleaks

A central GitHub Action for scanning repositories for hardcoded secrets. Repositories in `Taruvi-ai` and `eoxvantage-com` can call the same action on pushes and pull requests.

## Add the caller workflow

Create `.github/workflows/secret-scan.yml` in each repository:

```yaml
name: Secret scan

on:
  push:
  pull_request:

jobs:
  scan:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: read
    env:
      GITHUB_TOKEN: ${{ github.token }}
      GITLEAKS_LICENSE: ${{ secrets.GITLEAKS_LICENSE }}
    steps:
      - uses: Taruvi-ai/secret-scan-gitleaks/scans@main
```

## Central configuration

The scanning rules are maintained in this repository’s `scans/.gitleaks.toml`. Calling repositories do not need a copy. 

The action checks the calling repository and fails the job when it finds secrets. Review the run’s summary and annotations for the locations of findings. Rotate any real credential that has been committed, even if it was later removed from a file.

## Handling findings

1. Revoke or rotate any real exposed credential.
2. Remove secrets from current files and use an appropriate secret store or environment variable.
3. Review historical findings even if the value has been deleted from the latest version.

## License

This repository is licensed under the [MIT License](LICENSE).
