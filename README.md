# vscode-dev-setup

Opinionated GitHub template for fast, reproducible DevContainer environments with optional AI tooling.

> **Opinionated by design.** Reflects a personal setup — use it as a starting point and adapt it once cloned.

---

## Why

Standard devcontainer features compile tools from source (slow, non-deterministic). This template uses multi-stage Docker builds with pre-built runtimes: Python and Node.js are copied from their official images. First build takes ~30s instead of minutes.

Configuration is split into three layers:

- **BASE** — template-managed files (`Dockerfile`, `docker-compose.yml`, `justfile`, etc.), updated via `vscode-dev-setup-cli.sh`
- **PROJECT** — `*.project` files committed to git, shared across the team
- **LOCAL** — `*.local` files gitignored, personal dev overrides

## What's included

| | Tool | Notes |
|--|------|-------|
| Runtime | Python 3.13 | via [uv](https://github.com/astral-sh/uv), multi-stage COPY |
| Runtime | Node.js 24 | multi-stage COPY |
| Shell | zsh + Oh My Zsh | autosuggestions, syntax-highlighting, completions |
| Tasks | [just](https://github.com/casey/just) | see `just help` |
| Hooks | pre-commit | installed on first `just setup` |

**Optional tools** (disabled by default, enable via build args):

| Tool | Build ARG |
|------|-----------|
| [Claude Code CLI](https://claude.ai/code) | `CLAUDE_CLI_ENABLE=true` |
| [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli) | `GITHUB_COPILOT_CLI_ENABLE=true` |
| [AWS CLI](https://aws.amazon.com/cli/) | `AWS_CLI_ENABLE=true` |
| [OpenSpec](https://github.com/fission-ai/openspec) | `OPENSPEC_ENABLE=true` |
| [OpenCode](https://opencode.ai/) | `OPENCODE_ENABLE=true` |
| [Kind](https://kind.sigs.k8s.io/) | `KIND_ENABLE=true` |
| [LLaMA.cpp](https://github.com/ggml-org/llama.cpp) | `LLAMA_CPP_ENABLE=true` |
| [Terraform](https://www.terraform.io/) (via [tfenv](https://github.com/tfutils/tfenv)) | `TERRAFORM_ENABLE=true` |

## Getting started

**Requirements:** Docker, VSCode + [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

```bash
gh repo create my-project --template FabrizioCafolla/vscode-dev-setup
# Open in VSCode → "Reopen in Container"
```

The container builds and `just setup` runs automatically on start.

```bash
just help                        # list all commands
just gh-login                    # authenticate GitHub CLI
just claude-login                # authenticate Claude Code
just aws-login-sso <session>     # authenticate AWS SSO
```

## Customization

### Enable optional tools

Edit `.devcontainer/docker-compose.project.yml` for team-wide settings:

```yaml
services:
  devcontainer:
    build:
      args:
        CLAUDE_CLI_ENABLE: "true"
        AWS_CLI_ENABLE: "true"
```

Or `.devcontainer/docker-compose.local.yml` for local-only overrides (gitignored).

### Post-start setup

- `.devcontainer/scripts/setup-devcontainer.project.sh` — team-wide, committed
- `.devcontainer/scripts/setup-devcontainer.local.sh` — local dev, gitignored

### Just commands

- `justfile.project` — team commands, committed
- `justfile.local` — local commands, gitignored

### Environment variables

- `.env.project` — shared env vars, committed
- `.env` — local overrides, gitignored

Both are sourced automatically in each shell via `.zshrc`.

## Updating from template

```bash
bash vscode-dev-setup-cli.sh check     # see what changed upstream
bash vscode-dev-setup-cli.sh update    # apply updates
```

Or via curl (no local clone needed):

```bash
curl -fsSL https://raw.githubusercontent.com/FabrizioCafolla/vscode-dev-setup/main/vscode-dev-setup-cli.sh | bash -s -- check
curl -fsSL https://raw.githubusercontent.com/FabrizioCafolla/vscode-dev-setup/main/vscode-dev-setup-cli.sh | bash -s -- update
```

Options: `--ref REF`, `--force`, `--workspace DIR`

### File contract

| Category | Files | Behavior |
|----------|-------|----------|
| REPLACE | `Dockerfile`, `docker-compose.yml`, `setup-devcontainer.sh`, `justfile`, `.zshrc`, `vscode-dev-setup-cli.sh` | Overwritten on `update` |
| MARKER | `AGENTS.md`, `.pre-commit-config.yaml` | Only the `[vscode-dev-setup:START/END]` block is updated |
| DIFF-ONLY | `devcontainer.json` | Diff shown, not auto-applied (`--force` to override) |
| NEVER-TOUCH | `*.project`, `*.local`, `.gitignore`, `README.md` | Created once if missing, never overwritten |

On `update`, deprecated files from previous releases are removed automatically.

## Project structure

```
.devcontainer/
├── Dockerfile                              # REPLACE
├── docker-compose.yml                      # REPLACE
├── docker-compose.project.yml              # NEVER-TOUCH (team overrides)
├── docker-compose.local.yml                # NEVER-TOUCH (local overrides, gitignored)
├── devcontainer.json                       # DIFF-ONLY
├── configs/
│   ├── .zshrc                              # REPLACE
│   └── .aws/
├── cache/                                  # mounted volumes (.claude, .copilot, .llama)
└── scripts/
    ├── setup-devcontainer.sh               # REPLACE
    ├── setup-devcontainer.project.sh       # NEVER-TOUCH
    └── setup-devcontainer.local.sh         # NEVER-TOUCH (gitignored)
justfile                                    # REPLACE
justfile.project                            # NEVER-TOUCH
justfile.local                              # NEVER-TOUCH (gitignored)
.env.project                                # NEVER-TOUCH
.env                                        # gitignored
vscode-dev-setup-cli.sh                                      # REPLACE (template update script)
AGENTS.md                                   # MARKER
.pre-commit-config.yaml                     # MARKER
```
