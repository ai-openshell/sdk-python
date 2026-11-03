# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

import shutil
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory

from hatchling.builders.hooks.plugin.interface import BuildHookInterface


class CustomBuildHook(BuildHookInterface):
    def initialize(self, version, build_data):
        self._generated = TemporaryDirectory(prefix="openshell-proto-")
        subprocess.run(
            ["buf", "generate", "--output", self._generated.name],
            cwd=self.root,
            check=True,
        )
        proto_dir = Path(self._generated.name) / "src/openshell/proto"
        destination = "openshell/proto"
        if self.target_name == "sdist":
            raise Exception("Please builds wheels for openshell")
        for path in proto_dir.rglob("*.py"):
            relative = path.relative_to(proto_dir)
            if version == "editable":
                target = Path(self.root) / "src/openshell/proto" / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)
            else:
                build_data["force_include"][str(path)] = (
                    f"{destination}/{relative.as_posix()}"
                )

    def finalize(self, _version, _build_data, _artifact_path):
        self._generated.cleanup()
