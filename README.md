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
[uv](https://docs.astral.sh/uv/). The Python version is pinned in
`.python-version`, which both read. See [CONTRIBUTING.md](CONTRIBUTING.md) for
setup, commit rules and the release model, and [SECURITY.md](SECURITY.md) to
report a vulnerability.

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
`src/openshell/_proto`. `buf export` fetches the protos, the same way sdk-go
reads them, and `grpcio-tools` generates the bindings:

- Building a wheel or sdist needs neither a core checkout nor network access.
- A change of the pin shows the effect on the generated API in its diff.
- `mise run proto:check` fails when the committed bindings differ from the
  pinned protos, and `mise run conformance:check` does the same for the
  vendored test fixtures and `tests/e2e/Dockerfile.workload`.

## E2E tests

`tests/e2e` runs against a real gateway; `mise run test` skips it. CI runs it
against the published gateway of the pinned core version, with the Docker
compute driver. To run it locally, you need Docker with the compose plugin:

```shell
mise run e2e:image
scripts/e2e/start-gateway.sh "$(mise run -q core:version)" --default-image openshell/e2e-python:dev
OPENSHELL_GATEWAY=e2e mise run e2e
scripts/e2e/stop-gateway.sh
```

`e2e:image` builds the sandbox image from `tests/e2e/Dockerfile.workload`, a
copy of core's, with the Python version from `.python-version` and
`cloudpickle`, so `Sandbox.exec_python` can run the client's callables.

`start-gateway.sh` is meant for throwaway hosts. It registers `e2e` as the
active gateway, and `stop-gateway.sh` removes every sandbox container labelled
with core's default namespace. Set `XDG_CONFIG_HOME` to keep your own gateway
registrations apart.

## History

The history up to the move was imported from NVIDIA/OpenShell at `v0.1.7`.
The scripts that extracted and verified it are not on `main`. They are kept at
the `migration/v0.1.7` tag, in
[hack/migration](https://github.com/ai-openshell/sdk-python/tree/migration/v0.1.7/hack/migration).

## License

Apache-2.0. See [LICENSE](LICENSE).
