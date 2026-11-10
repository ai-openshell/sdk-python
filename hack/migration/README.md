# Migration tooling

These files record how the Python SDK history was extracted from
NVIDIA/OpenShell. They follow the Go SDK's import (ai-openshell/sdk-go,
`hack/migration`), adapted to a package that is not one subdirectory in core.

| File | Purpose |
|------|---------|
| `FREEZE` | The core commit the import was taken at. |
| `paths.txt` | `git filter-repo --paths-from-file` rules: which core paths to keep and where they land here. |
| `message-rules.txt` | Rewrites bare `#N` in commit messages to `NVIDIA/OpenShell#N`. |
| `port-pr.sh` | Port a core PR (open or squash-merged) or commit that touches the SDK into this repository, with original commits and authors. |
| `port-pr-body.md` | PR body template for `port-pr.sh`. |
| `extract-history.sh` | Produces the filtered repository from a core clone at the freeze commit. |
| `verify-tree.sh` | Checks the filtered tip against core and prints commit, author, and sign-off counts. |

## Why not `--subdirectory-filter`

The Go SDK lived entirely under `sdk/go`. The Python SDK spans several core
paths:

- `python/openshell/`, and `python/navigator/` before the package was renamed
- SDK tests at `python/*_test.py`
- the repository-root `pyproject.toml`, which is the SDK's package definition
- `tasks/scripts/generate_python_proto.py` and `verify-python-wheel.py`

`paths.txt` selects those paths with filters and maps them with renames.
Filters must come before renames, because filter-repo matches a filter against
the path as renamed so far.

Tests that exercise core packaging, release tooling, or gateway config stay in
core (`release_formula`, `rpm_gateway_config_migration`,
`gateway_config_fixture`, `gateway_schema_v2_*`, `release_tooling`).

The `navigator` package keeps its tests beside it. Moving them to `tests/` too
would put a delete and an add of the same path in the commit that renamed the
package.

## Reproduce

```shell
git clone https://github.com/NVIDIA/OpenShell core
hack/migration/extract-history.sh core "$(sed -n 's/^sha=//p' hack/migration/FREEZE)" /tmp/sdk-python-history
hack/migration/verify-tree.sh core "$(sed -n 's/^sha=//p' hack/migration/FREEZE)" /tmp/sdk-python-history
```

Both scripts need `git-filter-repo` (`uv tool install git-filter-repo`).

## Port a core change

Core froze the SDK paths (`Python SDK Freeze` check), so a core PR that still edits them has to land here instead. From a clean sdk-python clone, with this tag checked out elsewhere (for example `git worktree add ../migration migration/v0.1.7`):

```shell
../migration/hack/migration/port-pr.sh <core-pr-number | core-commit>
```

The script builds `port/<id>` from `origin/main`, maps core paths to this layout, qualifies bare `#N` in commit messages as `NVIDIA/OpenShell#N`, applies the commits with `git am --3way`, runs ruff and the unit tests, and prints the PR body. Nothing is pushed until you rerun with `--continue --push`.

| Core path | Lands at |
|-----------|----------|
| `python/openshell/*_test.py`, `python/*_test.py` | `tests/` |
| `python/openshell/` | `src/openshell/` |
| `tasks/scripts/` (the two SDK scripts) | `scripts/` |
| `e2e/python/test_<x>.py` | `tests/e2e/<x>_test.py` |
| `e2e/python/conftest.py` | `tests/e2e/conftest.py` |

Not ported, and listed in the PR body so the author keeps them in core: docs, the root `pyproject.toml`, core-only tests, the rest of `e2e/python`, and `Dockerfile.workload` (vendored by `mise run conformance:check`). The bindings under `src/openshell/_proto` are generated from a core release.

On a conflict, resolve it, `git add` the files, run `git am --continue`, then rerun with `--continue`.
