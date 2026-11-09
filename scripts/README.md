# Scripts

The workflows under `.github/workflows/` run these scripts, most through a mise task, so each job can be run locally first. Scripts that write to GitHub take `--dry-run` and print what they would do instead.

## `core-sync/`: keeping up with core

Move the core pin (`OPENSHELL_CORE_REF` in `mise.toml`) to new core releases, and watch core `main` for changes that will break the SDK.

The workflows use a GitHub App token from the `sdk-bot` environment (secrets `SDK_BOT_CLIENT_ID` and `SDK_BOT_PRIVATE_KEY`), which only `main` can deploy to. They never use `GITHUB_TOKEN`, because pushes and PRs made with it don't trigger CI.

| File | mise task | Purpose |
|------|-----------|---------|
| `core-tags.sh [--all]` | `core:tags` | List NVIDIA/OpenShell release tags newer than the pin: every stable tag, plus the newest pre-release when it is newer than all of them. |
| `open-bump-pr.sh <tag> [--dry-run]` | `core:bump` | Open the update proposal for one core tag: branch `core/<tag>`, pin change, regenerated bindings, refreshed copies of core files, proto diff in the body, labels `core-bump` plus `stable` or `prerelease`. Closes older pre-release proposals. |
| `bump-pr-body.md` | | PR body template for `open-bump-pr.sh`. |
| `drift-check.sh --out <file>` | `core:drift` | Compare core `main` with the pin: `buf breaking`, regenerate and run the unit tests, list the RPCs the SDK doesn't call. Writes the markdown report. |
| `update-drift-issue.sh <report.md> [--dry-run]` | | Create, update, or close the single `Core main drift` issue from a report. |
| `report-failure.sh <job> <run-url> [--dry-run]` | | Append a dated failure line to the drift issue. Called from `if: failure()` steps. |
| `drift-issue.sh` | | Shared helpers for the two drift issue scripts (sourced, not run). |

| Workflow | Runs |
|----------|------|
| `core-watch.yml` (hourly) | `core-tags.sh`, then `open-bump-pr.sh` per tag |
| `core-drift.yml` (nightly) | `drift-check.sh`, then `update-drift-issue.sh` |

Bump PRs run E2E against their own pin, because `e2e.yml` defaults to `OPENSHELL_CORE_REF` on the PR branch.

## `e2e/`: the E2E gateway

| File | Purpose |
|------|---------|
| `start-gateway.sh <core-version>` | Run the published gateway of a core version with the Docker driver for the E2E lane, and register it as `e2e`. |
| `stop-gateway.sh` | Stop it, collect its log, and remove its sandboxes. |

`e2e.yml` (reusable, called from `ci.yml`) runs `start-gateway.sh`, `mise run e2e`, then `stop-gateway.sh`.

## Build and checks

| File | mise task | Purpose |
|------|-----------|---------|
| `generate_python_proto.py` | `proto:gen` | Generate `src/openshell/_proto` from `proto/`. |
| `verify-python-wheel.py` | `build` | Check the wheel's contents and version. |
| `vendored-core-files.txt` | `conformance:check` | Files copied from core. `conformance:check` compares them with core at the pin; `core-sync/open-bump-pr.sh` refreshes them. |
| `fetch-core.sh <ref> <dir> <path>...` | `conformance:check` | Copy files from core at a ref. |
