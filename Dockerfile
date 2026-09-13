# syntax=docker/dockerfile:1
# Generated for the public repository by scripts/publish-docs.py.
# Runtime instructions and assets are shared with the source Dockerfile.

FROM --platform=$BUILDPLATFORM debian:bookworm-slim AS go-build
ARG TARGETARCH
ARG JUST_TERMINAL_VERSION=v0.1.1
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /download
RUN set -eu; \
    case "$TARGETARCH" in amd64|arm64) ;; *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; esac; \
    printf '%s\n' "$JUST_TERMINAL_VERSION" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$'; \
    release_url="https://github.com/maxbaines/just-terminal-docs/releases/download/${JUST_TERMINAL_VERSION}"; \
    archive="just-terminal_linux_${TARGETARCH}.tar.gz"; \
    curl -fsSL --retry 3 "$release_url/$archive" -o "$archive"; \
    curl -fsSL --retry 3 "$release_url/checksums.txt" -o checksums.txt; \
    awk -v archive="$archive" '$2 == archive { print }' checksums.txt > selected-checksum.txt; \
    test "$(wc -l < selected-checksum.txt)" -eq 1; \
    sha256sum --check --strict selected-checksum.txt; \
    mkdir /out; \
    tar -xzf "$archive" -C /out just-terminal; \
    chmod 0755 /out/just-terminal

FROM ghcr.io/openai/codex-universal:47f4f0eb5337083e2f610db0d15558932cb4901d

# JustTerminal-managed additions to the upstream Codex Universal image.
# CLI versions can be overridden with --build-arg. Shell-tool version changes
# also require updating both architecture checksums in docker/install-shell-tools.
ARG CODEX_VERSION=0.153.2
ARG CLAUDE_CODE_VERSION=2.1.260
ARG PLAYWRIGHT_CLI_VERSION=0.1.19
ARG STARSHIP_VERSION=1.24.2
ARG DELTA_VERSION=0.19.2
ARG LAZYGIT_VERSION=0.61.0
ARG YAZI_VERSION=26.1.22

ENV PLAYWRIGHT_BROWSERS_PATH=/var/cache/just-terminal/ms-playwright
ENV PLAYWRIGHT_MCP_CONFIG=/etc/just-terminal/playwright-cli.config.json

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gh \
        procps \
        unzip \
        zsh \
    && rm -rf /var/lib/apt/lists/*

COPY docker/install-shell-tools /tmp/install-shell-tools
RUN chmod 0755 /tmp/install-shell-tools \
    && STARSHIP_VERSION="$STARSHIP_VERSION" \
       DELTA_VERSION="$DELTA_VERSION" \
       LAZYGIT_VERSION="$LAZYGIT_VERSION" \
       YAZI_VERSION="$YAZI_VERSION" \
       /tmp/install-shell-tools \
    && rm /tmp/install-shell-tools

COPY docker/zsh/ /root/.config/zsh/
COPY .playwright/cli.config.json /etc/just-terminal/playwright-cli.config.json
RUN ln -sf /root/.config/zsh/zshrc /root/.zshrc \
    && git config --system core.pager delta \
    && git config --system interactive.diffFilter 'delta --color-only' \
    && git config --system delta.navigate true \
    && git config --system merge.conflictStyle zdiff3

# Keep the image self-contained so routine restarts do not depend on npm or the
# Playwright browser CDN being reachable. The startup wrapper below repairs an
# npm CLI if a mounted volume or image change ever leaves it unavailable.
RUN bash -lc "npm install --global \
        @openai/codex@${CODEX_VERSION} \
        @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
        @playwright/cli@${PLAYWRIGHT_CLI_VERSION} \
    && codex --version \
    && claude --version \
    && playwright-cli --version \
    && playwright-cli install-browser chromium --with-deps \
    && for tool_name in node npm npx corepack pnpm yarn codex claude playwright-cli; do \
         ln -sf \"\$(command -v \"\$tool_name\")\" \"/usr/local/bin/\$tool_name\"; \
       done \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/*"

ENV XDG_RUNTIME_DIR=/run/just-terminal
ENV XDG_CONFIG_HOME=/var/lib/just-terminal/config
ENV XDG_DATA_HOME=/var/lib/just-terminal/data
ENV XDG_STATE_HOME=/var/lib/just-terminal/state
ENV XDG_CACHE_HOME=/var/cache/just-terminal
ENV SHELL=/usr/bin/zsh
ENV CODEX_HOME=/root/.codex
ENV CLAUDE_CONFIG_DIR=/root/.claude
ENV GH_CONFIG_DIR=/var/lib/just-terminal/config/gh
ENV GIT_CONFIG_GLOBAL=/var/lib/just-terminal/config/gitconfig
ENV NPM_CONFIG_USERCONFIG=/var/lib/just-terminal/config/npmrc
ENV NODE_REPL_HISTORY=/var/lib/just-terminal/state/node/repl_history
ENV PYTHON_HISTORY=/var/lib/just-terminal/state/python/history
ENV JUST_TERMINAL_CODEX_VERSION=${CODEX_VERSION}
ENV JUST_TERMINAL_CLAUDE_CODE_VERSION=${CLAUDE_CODE_VERSION}
ENV JUST_TERMINAL_PLAYWRIGHT_CLI_VERSION=${PLAYWRIGHT_CLI_VERSION}
ENV JUST_TERMINAL_CODEX_SANDBOX_MODE=danger-full-access
ENV JUST_TERMINAL_DEFAULT_CWD=/workspace
# Runtime binaries in containers are immutable deployment artifacts. Updating
# means pulling and redeploying an image, never rewriting the live container.
ENV JUST_TERMINAL_UPDATE_METHOD=container

RUN mkdir -p \
    "$XDG_RUNTIME_DIR" \
    "$XDG_CONFIG_HOME" \
    "$XDG_DATA_HOME" \
    "$XDG_STATE_HOME" \
    "$XDG_CACHE_HOME" \
    "$CODEX_HOME" \
    "$CLAUDE_CONFIG_DIR" \
    /workspace

COPY --from=go-build /out/just-terminal /usr/local/bin/just-terminal
COPY docker/just-terminal-start /usr/local/bin/just-terminal-start

RUN chmod 0755 /usr/local/bin/just-terminal-start

WORKDIR /workspace

EXPOSE 8311

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=10 \
    CMD curl -fsS http://127.0.0.1:8311/api/health || exit 1

ENTRYPOINT ["/opt/entrypoint.sh", "/usr/local/bin/just-terminal-start"]
