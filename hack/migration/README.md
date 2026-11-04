# History import

These files record how the Python SDK history was extracted from
NVIDIA/OpenShell. They follow the Go SDK's import (ai-openshell/sdk-go,
`hack/migration`), adapted to a package that is not one subdirectory in core.

| File | Purpose |
|------|---------|
| `FREEZE` | The core commit the import was taken at. |
| `paths.txt` | `git filter-repo --paths-from-file` rules: which core paths to keep and where they land here. |
| `message-rules.txt` | Rewrites bare `#N` in commit messages to `NVIDIA/OpenShell#N`. |
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
