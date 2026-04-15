# [vscode-dev-setup:START]
ARG DEVCONTAINER_VERSION=trixie
ARG UV_VERSION=latest
ARG NODE_VERSION=24

FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv-src
FROM node:${NODE_VERSION}-slim AS node-src

# ── Base stage: OS packages + language runtimes ───────────────────────────────
FROM mcr.microsoft.com/devcontainers/base:${DEVCONTAINER_VERSION} AS base

USER root

# Docker BuildKit populates TARGETARCH (amd64|arm64) and TARGETOS (linux) at build time
ARG TARGETARCH=arm64
ARG TARGETOS=linux

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    just \
    git \
    cmake \
    build-essential \
    pkg-config \
    ccache \
    htop \
    sysstat \
    procps \
    pciutils \
    hyperfine \
    unzip \
    && wget -qO /usr/local/bin/yq \
        "https://github.com/mikefarah/yq/releases/latest/download/yq_${TARGETOS}_${TARGETARCH}" \
    && chmod +x /usr/local/bin/yq \
    && rm -rf /var/lib/apt/lists/*

ARG PYTHON_VERSION=3.13
COPY --from=uv-src --chown=root: /uv /uvx /bin/
RUN uv python install "${PYTHON_VERSION}" \
    && ln -sf $(uv python find "${PYTHON_VERSION}") /usr/local/bin/python3 \
    && ln -sf /usr/local/bin/python3 /usr/local/bin/python

COPY --from=node-src /usr/local/bin/node /usr/local/bin/node
COPY --from=node-src /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && ln -sf /usr/local/lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack

# ── Tools stage: optional ARG-gated tools ────────────────────────────────────
FROM base AS tools

USER root

# Redeclare platform args each stage has its own scope in Docker BuildKit
ARG TARGETARCH=arm64
ARG TARGETOS=linux

## [TOOLS] Enable or disable tools with build args
ARG CLAUDE_CLI_ENABLE=false
ARG OPENCODE_ENABLE=false
ARG OPENSPEC_ENABLE=false
ARG AWS_CLI_ENABLE=false
ARG GITHUB_COPILOT_CLI_ENABLE=false
ARG GH_CLI_ENABLE=false
ARG KIND_ENABLE=false
ARG LLAMA_CPP_ENABLE=false
ARG TERRAFORM_ENABLE=false
ARG TERRAFORM_VERSION=1.14.8

ENV CLAUDE_CLI_ENABLE=${CLAUDE_CLI_ENABLE}
ENV GITHUB_COPILOT_CLI_ENABLE=${GITHUB_COPILOT_CLI_ENABLE}
ENV OPENCODE_ENABLE=${OPENCODE_ENABLE}
ENV OPENSPEC_ENABLE=${OPENSPEC_ENABLE}
ENV AWS_CLI_ENABLE=${AWS_CLI_ENABLE}
ENV GH_CLI_ENABLE=${GH_CLI_ENABLE}
ENV KIND_ENABLE=${KIND_ENABLE}
ENV LLAMA_CPP_ENABLE=${LLAMA_CPP_ENABLE}
ENV TERRAFORM_ENABLE=${TERRAFORM_ENABLE}
ENV TFENV_ROOT=/opt/tfenv

# [INSTALL] GitHub CLI
RUN if [ "$GH_CLI_ENABLE" = "true" ]; then \
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
            | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && apt-get update \
        && apt-get install -y --no-install-recommends gh \
        && rm -rf /var/lib/apt/lists/*; \
    fi
# ---

# [INSTALL] AWS CLI
# TARGETARCH amd64→x86_64, arm64→aarch64
RUN if [ "$AWS_CLI_ENABLE" = "true" ]; then \
        case "${TARGETARCH}" in \
            amd64)  AWS_ARCH="x86_64" ;; \
            arm64)  AWS_ARCH="aarch64" ;; \
            *)      echo "[ERROR] Unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
        esac && \
        curl -fsSL "https://awscli.amazonaws.com/awscli-exe-${TARGETOS}-${AWS_ARCH}.zip" \
            -o /tmp/awscliv2.zip \
        && unzip -q /tmp/awscliv2.zip -d /tmp/awscli \
        && /tmp/awscli/aws/install \
        && rm -rf /tmp/awscliv2.zip /tmp/awscli; \
    fi
# ---

# [INSTALL] Claude CLI
RUN if [ "$CLAUDE_CLI_ENABLE" = "true" ]; then \
        for i in 1 2 3; do \
            curl -fsSL https://claude.ai/install.sh | bash && break; \
            echo "[WARN] Claude CLI install attempt ${i}/3 failed, retrying in 10s..."; \
            sleep 10; \
        done; \
        command -v claude >/dev/null 2>&1 \
            || echo "[WARN] Claude CLI not installed after 3 attempts"; \
    fi
# ---

# [INSTALL] GitHub Copilot CLI
RUN if [ "$GITHUB_COPILOT_CLI_ENABLE" = "true" ]; then \
        for i in 1 2 3; do \
            curl -fsSL https://gh.io/copilot-install | bash && break; \
            echo "[WARN] Copilot CLI install attempt ${i}/3 failed, retrying in 10s..."; \
            sleep 10; \
        done; \
        command -v copilot >/dev/null 2>&1 \
            || echo "[WARN] Copilot CLI not installed after 3 attempts"; \
    fi
# ---

# [INSTALL] OpenCode
RUN if [ "$OPENCODE_ENABLE" = "true" ]; then \
        for i in 1 2 3; do \
            curl -fsSL https://opencode.ai/install | bash && break; \
            echo "[WARN] OpenCode install attempt ${i}/3 failed, retrying in 10s..."; \
            sleep 10; \
        done; \
        command -v opencode >/dev/null 2>&1 \
            || echo "[WARN] OpenCode not installed after 3 attempts"; \
    fi
# ---

# [INSTALL] OpenSpec
ARG OPENSPEC_VERSION=latest
RUN if [ "$OPENSPEC_ENABLE" = "true" ]; then \
        npm install -g @fission-ai/openspec@${OPENSPEC_VERSION}; \
    fi
# ---

# [INSTALL] Kind
# TARGETARCH matches Kind's naming directly (amd64, arm64)
ARG KIND_VERSION="v0.31.0"
RUN if [ "$KIND_ENABLE" = "true" ]; then \
        apt-get update && apt-get install -y --no-install-recommends kubectx \
        && curl -fsSL \
            "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-${TARGETOS}-${TARGETARCH}" \
            -o /usr/local/bin/kind \
        && chmod +x /usr/local/bin/kind \
        && rm -rf /var/lib/apt/lists/*; \
    fi
# ---

# [INSTALL] LLaMA.cpp
ARG LLAMA_CPP_HOME=/opt/llama.cpp
ARG LLAMA_CPP_REF=master
ARG LLAMA_ROOT=/root/.llama
ARG LLAMA_CACHE=/root/.llama/cache
ARG LLAMA_MODELS=/root/.llama/models

ENV LLAMA_ROOT=${LLAMA_ROOT}
ENV LLAMA_CACHE=${LLAMA_CACHE}
ENV LLAMA_MODELS=${LLAMA_MODELS}

RUN if [ "$LLAMA_CPP_ENABLE" = "true" ]; then \
        git clone --depth 1 --branch "${LLAMA_CPP_REF}" \
            https://github.com/ggml-org/llama.cpp "${LLAMA_CPP_HOME}" \
        && cmake -S "${LLAMA_CPP_HOME}" -B "${LLAMA_CPP_HOME}/build" \
            -DBUILD_SHARED_LIBS=OFF -DGGML_CUDA=OFF \
        && cmake --build "${LLAMA_CPP_HOME}/build" --config Release \
            -j"$(nproc)" --target llama-cli llama-server \
        && ln -sf "${LLAMA_CPP_HOME}/build/bin/llama-cli" /usr/local/bin/llama-cli \
        && ln -sf "${LLAMA_CPP_HOME}/build/bin/llama-server" /usr/local/bin/llama-server \
        && mkdir -p "${LLAMA_ROOT}" "${LLAMA_CACHE}" "${LLAMA_MODELS}"; \
    fi
# ---

# [INSTALL] Terraform (via tfenv — allows switching versions inside the container)
RUN if [ "$TERRAFORM_ENABLE" = "true" ]; then \
        git clone --depth=1 https://github.com/tfutils/tfenv.git "${TFENV_ROOT}" \
        && ln -sf "${TFENV_ROOT}/bin/tfenv"     /usr/local/bin/tfenv \
        && ln -sf "${TFENV_ROOT}/bin/terraform" /usr/local/bin/terraform \
        && tfenv install "${TERRAFORM_VERSION}" \
        && tfenv use     "${TERRAFORM_VERSION}"; \
    fi
# ---
# [vscode-dev-setup:END]

# ── Your stage: add your own packages, tools, and configuration ───────────────
# This section is never touched by the template.
FROM tools AS vscode

USER root
