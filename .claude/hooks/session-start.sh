#!/bin/bash
# Installs project dependencies into .venv for Claude Code cloud sessions.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}"

PYTHON_VERSION="3.14"
VENV_DIR="$PWD/.venv"

if command -v uv >/dev/null 2>&1; then
  if [ ! -x "$VENV_DIR/bin/python" ]; then
    uv venv --python "$PYTHON_VERSION" "$VENV_DIR"
  fi
  VIRTUAL_ENV="$VENV_DIR" uv pip install -r requirements.txt -r resuirements.dev.txt
else
  if [ ! -x "$VENV_DIR/bin/python" ]; then
    "python$PYTHON_VERSION" -m venv "$VENV_DIR" 2>/dev/null || python3 -m venv "$VENV_DIR"
  fi
  "$VENV_DIR/bin/python" -m pip install -r requirements.txt -r resuirements.dev.txt
fi

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  {
    echo "export VIRTUAL_ENV=\"$VENV_DIR\""
    echo "export PATH=\"$VENV_DIR/bin:\$PATH\""
    echo "export PYTHON=\"$VENV_DIR/bin/python\""
  } >> "$CLAUDE_ENV_FILE"
fi
