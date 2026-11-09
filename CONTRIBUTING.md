# Contributing to the OpenShell Python SDK

## Setup

Install [mise](https://mise.jdx.dev/), then install the pinned tools and the
development dependencies:

```shell
mise install
mise run sync
```

mise reads the Python version from `.python-version`, and uv manages the
virtual environment. `mise tasks` lists every task. The ones you need most:

| Task | What it does |
|------|--------------|
| `mise run ci` | Everything CI runs: checks, unit tests, build |
| `mise run check` | Format check, lint, type check, proto check, conformance check |
| `mise run format` | Format the code |
| `mise run test` | Unit tests; `UV_PYTHON=3.11` picks the interpreter |
| `mise run build` | Build the wheel and sdist, verify them, and install them on Python 3.11 |
| `mise run e2e` | E2E tests against a running gateway; see the README for setup |
| `mise run proto:gen` | Regenerate the bindings from core at the pinned ref |
| `mise run core:version` | Print the pinned core version |

CI runs the unit tests on every Python version the package supports (3.11 to
3.14).

## Commits and pull requests

- Use [Conventional Commits](https://www.conventionalcommits.org/):
  `<type>(<scope>): <description>`.
- Sign off every commit (`git commit --signoff`) for the [Developer Certificate
  of Origin](https://developercertificate.org/).
- Every change goes through a pull request with an approval from a code owner
  who did not push last.
- New files need only the license line `SPDX-License-Identifier: Apache-2.0`
  in a comment. Keep the existing headers as they are.

## Bindings and core versions

The bindings in `src/openshell/_proto` are generated from core's `proto/` at one
core ref, `OPENSHELL_CORE_REF` in `mise.toml`, and committed. Don't edit
generated files; change the pin and run `mise run proto:gen`.
`mise run proto:check` fails when the committed bindings don't match the pin.

Shared test fixtures come from core's `sdk/conformance/` and are copied into
`tests/fixtures/`. `mise run conformance:check` compares them with core at the
pinned ref.

## Releases

SDK releases follow core releases: SDK `X.Y.Z` is built from core `vX.Y.Z`, and
there are no SDK-only releases. To try unreleased changes, install from the
repository:

```shell
pip install "openshell @ git+https://github.com/ai-openshell/sdk-python@main"
```
