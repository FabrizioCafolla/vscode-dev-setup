# AGENTS.md

<!-- [vscode-dev-setup:START] managed by vscode-dev-setup template, do not edit manually -->

This repository was bootstrapped from the [vscode-dev-setup](https://github.com/FabrizioCafolla/vscode-dev-setup) template.

The `cli.sh` script is used to keep the template-managed files in sync with the upstream template. Run `./cli.sh check` to see what changed, and `./cli.sh update` to apply updates whenever the template is updated.

Instructions and context for AI agents (Claude Code, GitHub Copilot, etc.) working in this repository.

## How to behave

Before anything else: you do not know everything, and you should not act like you do.

- **Search before you answer.** If a request touches something you are not certain about a tool, a convention, a file, a decision already made look it up first. Read the relevant files. Check the actual state of the project. Do not reconstruct from memory what you can verify directly.
- **Put yourself in doubt.** Before returning an answer, ask yourself: is this actually correct, or does it just sound correct? If you are not sure, say so explicitly and explain what you are uncertain about.
- **Do not agree by default.** If something Fabrizio says is wrong, incomplete, or heading in a bad direction, say so directly. Explain why. Propose something better. Agreement that is not earned is noise.
- **Behave like a professional in a discussion, not a tool executing commands.** Push back, ask follow-up questions, surface implications he may not have considered. The goal is to reach the best outcome, not to validate whatever was said.
- **Ask when the task is unclear.** Many requests will be generic or underspecified. Before producing output, assess whether you have enough context to do it well. If not, ask specifically, not generically. One focused question is better than a wrong answer.

## Tech stack

The development environment is DevContainer-based. The `.devcontainer/Dockerfile` uses a multi-stage build. The first stage (`base`) installs the core runtimes that are **always available**: Python 3.13 (managed by `uv`), Node.js 24, and Terraform 1.14. These are not optional they are copied from upstream images and always present in the final container. The same stage also installs OS-level tools like `just` (task runner) and system utilities. `pre-commit` is configured at the project level (`.pre-commit-config.yaml`) and always available. GitHub CLI (`gh`) is installed separately as a devcontainer feature defined in `devcontainer.json`.

The second stage (`tools`) is where all **optional tools** live. Each tool is gated behind a build arg (e.g. `AWS_CLI_ENABLE`, `CLAUDE_CLI_ENABLE`, `KIND_ENABLE`). The Dockerfile defines defaults for these args, but **the actual values used in this project are determined by `.devcontainer/docker-compose.local.yml`**, which overrides them at build time. To know which tools are actually installed, always check `docker-compose.local.yml` that file is the source of truth, not the Dockerfile defaults.

## Development environment

All work happens inside the DevContainer. Do not assume tools are installed on the host machine. The container starts via `just setup`, which is triggered automatically by `postStartCommand`. SSH keys are mounted read-only from the host. AWS configuration lives in `.devcontainer/configs/.aws/`, and AI tool caches (Claude, Copilot) are persisted in `.devcontainer/cache/`.

### Template files vs `.local` overrides

This project follows a strict separation between **template-managed files** and **project-specific `.local` files**. Template files are updated automatically by the upstream `vscode-dev-setup` template and must not be edited manually. Project-specific customizations go exclusively in the `.local` counterparts, which are never overwritten by template updates.

`justfile` defines the base commands (`setup`, `pre-commit-run`, auth helpers, etc.) and uses `import? 'justfile.local'` to optionally load `justfile.local`. Any project-specific commands must go in `justfile.local` never modify `justfile` directly.

`.devcontainer/docker-compose.yml` defines the service configuration, volumes, and base build context. `.devcontainer/docker-compose.local.yml` is merged on top of it (as declared in `devcontainer.json`) and is where build args are overridden to enable or disable optional tools. It can also add project-specific volumes or services.

`.devcontainer/scripts/setup-devcontainer.sh` runs the base post-start initialization and sources `.devcontainer/scripts/setup-devcontainer.local.sh` at the end. Any project-specific initialization (installing packages, starting services, downloading data) should go in the `.local` script.

**Discover available commands with:**

```bash
just help
```

## What agents should avoid

- Do not modify `.devcontainer/` base files (Dockerfile, docker-compose.yml, setup-devcontainer.sh) unless asked.
- Do not install packages globally inside the container without updating the Dockerfile or devcontainer features

- <!-- [vscode-dev-setup:END] -->

## Project-specific context

<!-- TODO: Add anything specific to this project that an AI agent should know.
     This is the most important section to fill in when using this template.

Suggested content:
- Architecture overview or diagram reference
- Key files and their purpose
- Known limitations or areas to avoid
- External dependencies (APIs, databases, services)
- Links to internal documentation or runbooks
- Ongoing work or areas under active development
-->
