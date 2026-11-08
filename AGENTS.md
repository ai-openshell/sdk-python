# Agent Instructions

The OpenShell Python SDK: package `openshell` on PyPI, a client for the
OpenShell gateway. See [CONTRIBUTING.md](CONTRIBUTING.md) for tasks and the
release model.

## Commands

- `mise run ci` runs the full pipeline (format check, lint, type check, proto
  check, conformance check, unit tests, build).
- `mise run proto:gen` regenerates `src/openshell/_proto` from core at the ref
  pinned in `OPENSHELL_CORE_REF` (`mise.toml`). Never edit generated files by
  hand.
- Use `uv` for Python commands (`uv run`, `uv sync`), never `pip` directly.

## Code conventions

- The SDK supports Python 3.11 and newer. Don't use syntax or standard library
  features from later versions.
- The public API is what `openshell/__init__.py` exports in `__all__`. Users
  also import `openshell._proto` directly, so keep its module paths stable.
- Unit tests live in `tests/` and are named `*_test.py`; fixtures go in
  `tests/fixtures/`.
- Files copied from core must stay identical to core at the pin;
  `mise run conformance:check` compares them.
- New files need only the license line `SPDX-License-Identifier: Apache-2.0`
  in a comment. Keep the existing headers as they are.

## Commits

- Use Conventional Commits and sign off every commit (`--signoff`).
- Never mention Claude or any AI agent in commits, pull request descriptions, or
  issues (no author attribution, no Co-Authored-By, no "Generated with"
  footers).
