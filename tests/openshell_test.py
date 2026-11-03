# SPDX-FileCopyrightText: Copyright (c) 2025-2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

"""Basic tests for the openshell package."""

import openshell


def test_version() -> None:
    """Test that version is defined."""
    assert openshell.__version__


def test_sandbox_template_client_exported() -> None:
    assert openshell.SandboxTemplateClient


def test_public_messages_can_be_built_without_private_imports() -> None:
    from openshell.proto.datamodel_pb import ObjectMeta
    from openshell.proto.openshell_pb import (
        HealthResponse,
        SandboxSpec,
        SandboxTemplate,
        SandboxWorkloadConfig,
        SandboxWorkloadTemplate,
        SandboxWorkloadTemplateSpec,
        ServiceStatus,
    )

    spec = SandboxSpec(template=SandboxTemplate(image="python:3.14"))
    template = SandboxWorkloadTemplate(
        metadata=ObjectMeta(name="python"),
        spec=SandboxWorkloadTemplateSpec(
            workload=SandboxWorkloadConfig(image="python:3.14")
        ),
    )
    health = HealthResponse(status=ServiceStatus.HEALTHY, version="1.0")
    for message in (spec, template, health):
        assert type(message).from_binary(message.to_binary()) == message
