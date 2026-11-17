# Gitleaks Secret Scan

This public repository provides one Gitleaks scan for repositories in Taruvi-ai and eoxvantage-com. The root [`action.yml`](action.yml) is a composite action, so a repository can call it with `uses: Taruvi-ai/secret-scan-gitleaks@main`. The workflow in [`.github/workflows/scan.yml`](.github/workflows/scan.yml) lets a Taruvi-ai organization ruleset require the same scan on pull requests without a file in each repository.

The action checks out the calling repository, scans its current files and full git history by default, and fails the job if it finds secrets. It uses Gitleaks CLI 8.30.1 and the central [`.gitleaks.toml`](.gitleaks.toml), which extends the default rules with Taruvi API key, password, and credential URL patterns. The CLI archive is checked against a pinned SHA-256 digest. No `GITLEAKS_LICENSE` Actions secret is needed.

## Run on pushes and pull requests

Add this file to **each repository** that should scan every branch push and pull request. It works in either organization and does not need an existing deploy workflow:

```yaml
# .github/workflows/secret-scan.yml
name: Secret Scan

on:
  push:
    branches: ['**']
  pull_request:

permissions:
  contents: read

jobs:
  gitleaks:
    name: Gitleaks
    runs-on: ubuntu-latest
    steps:
      - uses: Taruvi-ai/secret-scan-gitleaks@main
```

The action includes `actions/checkout`; the caller does not need a separate checkout step. For a stable rollout, replace `@main` with a reviewed commit SHA. Make sure the calling repository's Actions policy permits this public action.

## Taruvi-ai: require scans on pull requests without caller files

Taruvi-ai can select `.github/workflows/scan.yml` in an organization branch ruleset under **Settings → Repository → Rulesets → Require workflows to pass before merging**. Target the repositories and protected destination branches, test the rule on a few repositories, then activate it. A failing required scan blocks the pull request from merging.

This ruleset runs on pull requests and merge queues. It does not scan a push to a branch without an open pull request. To scan every push as well, use the caller workflow above in each repository. If the ruleset also runs on PRs, a caller with only `on: push` avoids a duplicate PR scan.

## eoxvantage-com

Add the caller workflow above to each target repository for push and PR scans. On GitHub Free, organization-wide required-workflow rulesets are unavailable. Public repositories can require the resulting `Gitleaks` check with a repository branch rule; private repositories can run the scan, but GitHub Free cannot enforce that check before merging.

## Scan modes and results

The `scan_mode` input accepts `Working tree + git history` (default), `Working tree only`, or `Git history only`. Set it on the action step if a repository needs a different mode:

```yaml
- uses: Taruvi-ai/secret-scan-gitleaks@main
  with:
    scan_mode: Working tree only
```

The `SECRET_SCAN_MODE` Actions variable is also used when no input is supplied. The run summary and annotations show locations, counts, and remediation guidance without printing secret values. A scan error or missing report fails the job rather than passing silently.

Rotate or revoke a real credential before removing it from the current files or history. Review false positives before changing the central rules or adding a fingerprint to a caller repository's `.gitleaksignore`. A passing scan is a safety net, not proof that a repository has no secrets.

## Deployment gates

A failed scan only blocks a merge when its check is required by a branch rule. A push scan runs after GitHub accepts the push. To prevent deployment when the scan fails, put the scan and deploy jobs in the same workflow and make the deploy job depend on `gitleaks` with `needs: gitleaks`.

## License

The repository is licensed under the [MIT License](LICENSE).
