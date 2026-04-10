set dotenv-load := true
set dotenv-path := ".env"

import? 'justfile.local'

default:
  @just --list

help:
  @just --list

# ── Setup ─────────────────────────────────────────────────────────────────────

[group('setup')]
setup:
  @echo "[INFO] Setup"
  @just setup-devcontainer
  @just load-env

[group('setup')]
setup-devcontainer:
  @.devcontainer/scripts/setup-devcontainer.sh

[group('setup')]
load-env:
  @.devcontainer/scripts/load-env.sh

[group('setup')]
setup-template *args:
  @./cli.sh {{ args }}

# ── Auth ──────────────────────────────────────────────────────────────────────

[group('auth')]
gh-login:
  @gh auth login

[group('auth')]
claude-login:
  @claude auth login

[group('auth')]
opencode-login:
  @opencode auth login

[group('auth')]
aws-login:
  @aws login

[group('auth')]
aws-login-sso session_name:
  @aws sso login --sso-session {{session_name}}

# ── Tools ─────────────────────────────────────────────────────────────────────

[group('tools')]
pre-commit-run:
  @pre-commit run --all-files

[group('tools')]
scaffold-ai-cli *args:
  @curl -fsSL https://raw.githubusercontent.com/FabrizioCafolla/scaffold-ai/main/cli.sh | bash -s -- {{args}}
