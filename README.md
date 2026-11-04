# OpenShell Python SDK

The `openshell` package is the Python client for the
[OpenShell](https://github.com/NVIDIA/OpenShell) gateway: sandbox lifecycle,
templates, workspaces, exec, and provider credentials, plus the generated gRPC
bindings under `openshell._proto`.

```shell
pip install openshell
```

The SDK moved here from NVIDIA/OpenShell. The package name, import paths, and
API are unchanged, including `openshell._proto`. Releases published from
NVIDIA/OpenShell stay on PyPI.

## Development

Tools are managed by [mise](https://mise.jdx.dev/) and dependencies by
[uv](https://docs.astral.sh/uv/).

```shell
mise run ci          # checks, tests, build, and install smoke test
mise run check       # format, lint, typecheck, proto and fixture drift
mise run test        # unit tests; UV_PYTHON=3.11 picks the interpreter
mise run proto:gen   # regenerate src/openshell/_proto from the pinned protos
mise run core:version
```

## Core version and generated bindings

The bindings are generated from `proto/` in NVIDIA/OpenShell at the ref in
`OPENSHELL_CORE_REF` (`mise.toml`, currently `v0.1.7`) and committed under
`src/openshell/_proto`:

- Building a wheel or sdist needs neither a core checkout nor network access.
- A change of the pin shows the effect on the generated API in its diff.
- `mise run proto:check` fails when the committed bindings differ from the
  pinned protos, and `mise run conformance:check` does the same for the
  vendored test fixtures.

## History

The history up to the move was imported from NVIDIA/OpenShell at `v0.1.7`.
The scripts that extracted and verified it are not on `main`. They are kept at
the `migration/v0.1.7` tag, in
[hack/migration](https://github.com/ai-openshell/sdk-python/tree/migration/v0.1.7/hack/migration).

## License

Apache-2.0. See [LICENSE](LICENSE).
