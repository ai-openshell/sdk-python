# SPDX-FileCopyrightText: Copyright (c) 2025-2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

"""OpenShell - Agent execution and management SDK."""

from __future__ import annotations

from openshell.errors import ErrorInfo, FieldViolation, GatewayError, from_grpc_error
from openshell.mutations import DeletionOutcome, DeletionResult
from openshell.providers import ProviderClient, ProviderCredentialValue
from openshell.sandbox import (
    ClientCredentialsAuth,
    ExecChunk,
    ExecResult,
    Page,
    Pager,
    Sandbox,
    SandboxClient,
    SandboxConditionRef,
    SandboxError,
    SandboxRef,
    SandboxSession,
    SandboxStatusRef,
    SandboxTemplateClient,
    SandboxWorkloadTemplateProvenanceRef,
    ServiceAuthorizationMode,
    ServiceExposure,
    TlsConfig,
    WorkspaceClient,
    WorkspaceRef,
)

try:
    from importlib.metadata import version

    __version__ = version("openshell")
except Exception:
    __version__ = "0.0.0"

__all__ = [
    "ClientCredentialsAuth",
    "DeletionOutcome",
    "DeletionResult",
    "ErrorInfo",
    "ExecChunk",
    "ExecResult",
    "FieldViolation",
    "GatewayError",
    "Page",
    "Pager",
    "ProviderClient",
    "ProviderCredentialValue",
    "Sandbox",
    "SandboxClient",
    "SandboxConditionRef",
    "SandboxError",
    "SandboxRef",
    "SandboxSession",
    "SandboxStatusRef",
    "SandboxTemplateClient",
    "SandboxWorkloadTemplateProvenanceRef",
    "ServiceAuthorizationMode",
    "ServiceExposure",
    "TlsConfig",
    "WorkspaceClient",
    "WorkspaceRef",
    "__version__",
    "from_grpc_error",
]
