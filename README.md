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

[uv](https://docs.astral.sh/uv/) is the only prerequisite. It installs Python
and every development tool, buf included, at the versions locked in `uv.lock`.
`make` wraps the common tasks:

```shell
make ci          # checks, tests, build, and install smoke test
make check       # format, lint, typecheck, proto and fixture drift
make test        # unit tests; UV_PYTHON=3.11 picks the interpreter
make proto-gen   # regenerate src/openshell/_proto from the pinned protos
make core-version
make help        # list every target
```

## Core version and generated bindings

The bindings are generated from `proto/` in NVIDIA/OpenShell at the ref in
`OPENSHELL_CORE_REF` (`Makefile`, currently `v0.1.7`) and committed under
`src/openshell/_proto`. `buf export` fetches the protos, the same way sdk-go
reads them, and `grpcio-tools` generates the bindings:

- Building a wheel or sdist needs neither a core checkout nor network access.
- A change of the pin shows the effect on the generated API in its diff.
- `make proto-check` fails when the committed bindings differ from the
  pinned protos, and `make conformance-check` does the same for the
  vendored test fixtures.

## History

The history up to the move was imported from NVIDIA/OpenShell at `v0.1.7`. See
[hack/migration](hack/migration/README.md) for how it was extracted and
verified.

## License

Apache-2.0. See [LICENSE](LICENSE).
