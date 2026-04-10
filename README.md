# vscode-dev-setup

A GitHub template repository for consistent, fast, and modular DevContainer environments with AI tooling built in.

> **Opinionated by design.** This template reflects a personal setup and preferences. Use it as a starting point, then adapt it to your needs once you clone it, it's yours to modify.

---

## What's included

### DevContainer

| Component       | Details                                                           |
| --------------- | ----------------------------------------------------------------- |
| Base image      | `mcr.microsoft.com/devcontainers/base:trixie`                     |
| Python          | 3.13 via [uv](https://github.com/astral-sh/uv) (multi-stage COPY) |
| Node.js         | 24 via multi-stage COPY                                           |
| Terraform       | 1.14 via multi-stage COPY                                         |
| AWS CLI         | via Dockerfile (ARG-gated)                                        |
| GitHub CLI      | via devcontainer feature                                          |
| just            | task runner                                                       |
| pre-commit      | code quality hooks                                                |
| zsh + Oh My Zsh | with autosuggestions and syntax highlighting                      |

### AI tools (optional, ARG-gated)

| Tool                                                              | Default  | Build ARG                        |
| ----------------------------------------------------------------- | -------- | -------------------------------- |
| [AWS CLI](https://aws.amazon.com/cli/)                            | disabled | `AWS_CLI_ENABLE=true`            |
| [Claude Code CLI](https://claude.ai/code)                         | disabled | `CLAUDE_CLI_ENABLE=true`         |
| [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli) | disabled | `GITHUB_COPILOT_CLI_ENABLE=true` |
| [OpenSpec](https://github.com/fission-ai/openspec)                | disabled | `OPENSPEC_ENABLE=true`           |
| [OpenCode](https://opencode.ai/)                                  | disabled | `OPENCODE_ENABLE=true`           |
| [Kind](https://kind.sigs.k8s.io/)                                 | disabled | `KIND_ENABLE=true`               |
| [LLaMA.cpp](https://github.com/ggml-org/llama.cpp)                | disabled | `LLAMA_CPP_ENABLE=true`          |

### VSCode

Pre-configured `.vscode/` with settings, recommended extensions, MCP config, and tasks.

---

## Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [Visual Studio Code](https://code.visualstudio.com/) + [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

---

## Usage

### 1. Create from template

Click **Use this template** on GitHub, or:

```bash
gh repo create my-project --template FabrizioCafolla/vscode-dev-setup
```

### 2. Open in DevContainer

Open the folder in VSCode and click **Reopen in Container** when prompted, or run:

```
Dev Containers: Reopen in Container
```

The container builds and `just setup` runs automatically on start.

### 3. Authenticate tools

```bash
just gh-login        # GitHub CLI
just claude-login    # Claude Code
just aws-login-sso <session>  # AWS SSO (if needed)
```

---

## Architecture: composition model

The template uses a layered model. A **base layer** (template-managed) and a **local layer** (project-managed) merge at runtime via Docker Compose.

```
docker-compose.yml          ← base (REPLACE on update)
docker-compose.local.yml    ← project overrides (NEVER-TOUCH)
         │
         └─ Compose merge → running DevContainer
```

### File contract

| Category        | Files                                                                                                  | Behavior                                                                                  |
| --------------- | ------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| **REPLACE**     | `Dockerfile`, `docker-compose.yml`, `setup-devcontainer.sh`, `.zshrc`, `justfile`                      | Overwritten on `update`                                                                   |
| **MARKER**      | `AGENTS.md`, `.pre-commit-config.yaml`                                                                 | Only the block between `[vscode-dev-setup:START]` and `[vscode-dev-setup:END]` is updated |
| **DIFF-ONLY**   | `devcontainer.json`                                                                                    | Diff shown, not applied automatically; use `--force` to override                          |
| **NEVER-TOUCH** | `docker-compose.local.yml`, `setup-devcontainer.local.sh`, `justfile.local`, `.gitignore`, `README.md` | Created once, never overwritten                                                           |

---

## Customization

### Enable optional tools

Edit `.devcontainer/docker-compose.local.yml`:

```yaml
services:
  devcontainer:
    build:
      args:
        KIND_ENABLE: true
        LLAMA_CPP_ENABLE: true
        OPENCODE_ENABLE: true
```

### Add extra volumes

```yaml
services:
  devcontainer:
    volumes:
      - /path/to/extra:/workspace/extra:cached
```

### Add project-specific post-start setup

Edit `.devcontainer/scripts/setup-devcontainer.local.sh`:

```bash
# Install project dependencies
uv pip install -r requirements.txt

# Start local services
docker compose -f docker-compose.dev.yml up -d
```

### Add project-specific just commands

Edit `justfile.local`:

```just
[group('dev')]
run:
  @python -m myapp
```

---

## Updating from template

Check what changed upstream (no modifications):

```bash
bash cli.sh check
# or via curl:
curl -fsSL https://raw.githubusercontent.com/FabrizioCafolla/vscode-dev-setup/main/cli.sh | bash -s -- check
```

Apply updates:

```bash
bash cli.sh update
# or via curl:
curl -fsSL https://raw.githubusercontent.com/FabrizioCafolla/vscode-dev-setup/main/cli.sh | bash -s -- update
```

Options:

```
--ref REF      Use a specific git ref (default: main)
--force        Force-replace devcontainer.json (DIFF-ONLY file)
--workspace    Target directory (default: current dir)
```

---

## scaffold-ai

[scaffold-ai](https://github.com/FabrizioCafolla/scaffold-ai) is managed at runtime not tracked in the repository.

```bash
just scaffold-ai-cli -h  # run with args
```

---

## Available commands

```bash
just help
```
