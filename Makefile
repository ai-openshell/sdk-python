# SPDX-FileCopyrightText: Copyright (c) 2025-2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

# Python SDK tasks. `make help` lists them and `make ci` runs the full
# pipeline. uv is the only prerequisite: every tool, buf included, is pinned in
# the dev dependency group and locked in uv.lock. Bindings are generated from
# core's proto/ at OPENSHELL_CORE_REF and committed under src/openshell/_proto,
# so building the package needs no core checkout and no network.

# The single core pin: a release tag or a full commit SHA.
OPENSHELL_CORE_REF := v0.1.7

SHELL := bash
PYTHON_PATHS := src/ tests/ scripts/
UV_RUN := uv run --frozen
# A marker in proto/ records which ref was exported, so a pin change refetches.
PROTO_STAMP := proto/.core-ref-$(OPENSHELL_CORE_REF)

export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_OPENSHELL ?= 0.0.0

.DEFAULT_GOAL := help
.PHONY: help core-version sync proto-fetch proto-gen proto-check \
	conformance-check lint format format-check typecheck check test build ci

help: ## List the targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | sed -E 's/:.*## /\t/' | expand -t 20

core-version: ## Print the pinned core ref
	@echo $(OPENSHELL_CORE_REF)

sync: ## Install the SDK and its development tools
	uv sync --frozen --group dev

# buf follows the imports of the two root files, so proto/ holds exactly the
# files the SDK compiles.
$(PROTO_STAMP): | sync
	rm -rf proto
	$(UV_RUN) buf export "https://github.com/NVIDIA/OpenShell.git#ref=$(OPENSHELL_CORE_REF),depth=1,subdir=proto" \
		--path openshell.proto --path credential_driver.proto --output proto
	touch $@

proto-fetch: $(PROTO_STAMP) ## Export the SDK's protos from core at the pin into proto/

proto-gen: proto-fetch ## Generate the bindings into src/openshell/_proto
	$(UV_RUN) python scripts/generate_python_proto.py

proto-check: proto-gen ## Fail if the committed bindings differ from the pinned protos
	@if ! git diff --exit-code --stat -- src/openshell/_proto \
		|| [ -n "$$(git ls-files --others --exclude-standard -- src/openshell/_proto)" ]; then \
		echo "ERROR: src/openshell/_proto is stale; run 'make proto-gen' and commit." >&2; \
		exit 1; \
	fi

conformance-check: ## Fail if vendored fixtures differ from core at the pin
	set -euo pipefail; \
	core=$$(mktemp -d); \
	trap 'rm -rf "$$core"' EXIT; \
	scripts/fetch-core.sh "$(OPENSHELL_CORE_REF)" "$$core" sdk/conformance; \
	for fixture in oauth-client-credentials.json oauth-client-credentials.json.license; do \
		diff -u "$$core/sdk/conformance/$$fixture" "tests/fixtures/$$fixture"; \
	done

lint: sync ## Lint with ruff
	$(UV_RUN) ruff check $(PYTHON_PATHS)

format: sync ## Format with ruff
	$(UV_RUN) ruff format $(PYTHON_PATHS)

format-check: sync ## Check formatting with ruff
	$(UV_RUN) ruff format --check $(PYTHON_PATHS)

typecheck: sync ## Type check with ty
	$(UV_RUN) ty check $(PYTHON_PATHS)

check: format-check lint typecheck proto-check conformance-check ## Formatting, lint, type, and drift checks

test: sync proto-fetch ## Run unit tests (UV_PYTHON picks the interpreter)
	$(UV_RUN) pytest -n auto

# Installs each artifact into a clean environment on the oldest supported
# Python and imports the public API and the generated bindings.
build: sync ## Build the wheel and sdist, verify the wheel, and install both
	set -euo pipefail; \
	rm -rf dist; \
	uv build --out-dir dist; \
	uv run --no-project python scripts/verify-python-wheel.py dist \
		--expected-version "$$SETUPTOOLS_SCM_PRETEND_VERSION_FOR_OPENSHELL"; \
	smoke=$$(mktemp -d); \
	trap 'rm -rf "$$smoke"' EXIT; \
	for artifact in dist/*.whl dist/*.tar.gz; do \
		uv venv --quiet --clear --python "$${SMOKE_PYTHON:-3.11}" "$$smoke/venv"; \
		uv pip install --quiet --python "$$smoke/venv/bin/python" "$$artifact"; \
		"$$smoke/venv/bin/python" -I -c 'import openshell, openshell._proto.openshell_pb2_grpc; print(openshell.__version__, len(openshell.__all__))'; \
	done

ci: check test build ## Run the full pipeline
