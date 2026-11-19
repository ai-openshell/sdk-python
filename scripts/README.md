# Scripts

The workflows under `.github/workflows/` run these scripts, most through a mise task, so each job can be run locally first. Scripts that write to GitHub take `--dry-run` and print what they would do instead.

## Core sync and release tagging (shared)

The core-sync scripts and the `core-watch` and `core-drift` workflows are shared with the other SDKs through [ai-openshell/workflows](https://github.com/ai-openshell/workflows/tree/main/core-sync), which documents them and the contract this repository implements. The workflows (`core-watch.yml`, `core-drift.yml`, and the tag job of `release.yml`) call the shared workflows at one commit, and the shared workflows run that commit's scripts. Locally, `core-sync.sh` runs the scripts of the commit in `core-drift.yml`'s `uses:` line, downloaded once into `~/.cache/openshell-core-sync/`.

| mise task | Runs |
|-----------|------|
| `core:tags`, `core:bump`, `core:drift`, `core:drift-issue`, `core:report-failure`, `release:tag` | The shared scripts, through `core-sync.sh`. |
| `proto:fetch`, `proto:gen`, `proto:buf`, `check`, `test` | This repository's parts of the contract. |
| `core:uncovered-rpcs` | `uncovered-rpcs.sh`: RPCs in `src/openshell/_proto` the SDK doesn't call, for the drift report. |

| Workflow | Runs |
|----------|------|
| `core-watch.yml` (hourly) | `core:tags`, then `core:bump` per tag |
| `core-drift.yml` (nightly) | `core:drift`, then `core:drift-issue` |
| `release.yml` (push to `main`) | `release:tag`; when it prints a tag, builds and publishes the release |

The shared workflows use a GitHub App token from the `sdk-bot` environment (secrets `SDK_BOT_CLIENT_ID` and `SDK_BOT_PRIVATE_KEY`), which only `main` can deploy to.

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
| `vendored-core-files.txt` | `vendored:check` | Files copied from core. `vendored:check` compares them with core at the pin; `core:bump` refreshes them. |
| `fetch-core.sh <ref> <dir> <path>...` | `vendored:check` | Copy files from core at a ref. |
