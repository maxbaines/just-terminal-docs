# Running and integrating JustTerminal

[← JustTerminal](../README.md)

Setup and reference material for running JustTerminal on your own machine or server.

## Download and run

Get the [latest public release](https://github.com/maxbaines/just-terminal-docs/releases/latest).
Downloads do not require access to the private source repository.

| Host | Archive |
|---|---|
| Linux Intel / AMD x64 | [Linux x64](https://github.com/maxbaines/just-terminal-docs/releases/latest/download/just-terminal_linux_amd64.tar.gz) |
| Linux ARM64 | [Linux ARM64](https://github.com/maxbaines/just-terminal-docs/releases/latest/download/just-terminal_linux_arm64.tar.gz) |
| macOS Intel | [macOS x64](https://github.com/maxbaines/just-terminal-docs/releases/latest/download/just-terminal_darwin_amd64.tar.gz) |
| macOS Apple silicon | [macOS ARM64](https://github.com/maxbaines/just-terminal-docs/releases/latest/download/just-terminal_darwin_arm64.tar.gz) |
| Windows with WSL2 | Use the Linux archive matching `uname -m` inside WSL2: `x86_64` → x64, `aarch64` → ARM64 |

Download the matching archive and [checksums.txt](https://github.com/maxbaines/just-terminal-docs/releases/latest/download/checksums.txt)
from the **same release**. In that download directory, verify and extract it
(replace the filename for your platform):

```bash
# Linux / WSL2
sha256sum --ignore-missing -c checksums.txt
# macOS: shasum -a 256 --ignore-missing -c checksums.txt
# Require an OK result for your archive before continuing.
tar -xzf just-terminal_linux_amd64.tar.gz
./just-terminal
```

Open http://127.0.0.1:8311. The web UI is embedded; Go, Node.js and npm are
not required to run a download. Install and sign in to Codex separately to use
agent chats. Use a normal user account for your local terminal sessions.

An optional installer verifies the archive checksum and installs to `~/.local/bin`:

```bash
curl -fL https://github.com/maxbaines/just-terminal-docs/releases/latest/download/install.sh -o install.sh
# Review install.sh, then:
bash install.sh
```

### macOS

The archives contain command-line executables, not `.app` bundles or DMGs.
They are not Developer ID signed or notarized. After verifying the checksum,
if macOS blocks the downloaded binary, follow Apple's
[Open Anyway instructions](https://support.apple.com/en-us/102445) in
System Settings → Privacy & Security. Do not disable Gatekeeper globally.
The Homebrew tap is not published; use the archive or installer.

### Windows (WSL2)

Native Windows executables are not supported: the Session Owner requires Unix
PTYs and the host filesystem integration uses Unix APIs. Use Windows 11 or a
[Windows 10 version supported by WSL](https://learn.microsoft.com/en-us/windows/wsl/install).
In an administrator PowerShell, run `wsl --install`, restart if requested, and
complete Ubuntu's first-run user setup. Confirm the distribution uses version 2
with `wsl --list --verbose`.

Download, verify and extract the **Linux** archive inside your WSL2 distribution
(or run the installer there). Run `./just-terminal serve --addr 127.0.0.1:8311`
in WSL2 and open http://127.0.0.1:8311 in your Windows browser. Browser auto-open
from WSL may be unavailable. Keep the WSL distribution running while using
JustTerminal; `wsl --shutdown` ends its shell processes. Windows/WSL2 runtime
verification is separate from the native Linux and macOS release checks.

## Build and run

The source repository is private. Building locally or deploying its Dockerfile requires collaborator access. The public documentation repository hosts release downloads but does not contain the application source.

### Requirements

- A Unix-like Host: macOS, Linux, or WSL2
- Go 1.24.4 (the version pinned by `go.mod`)
- Node.js 22 and npm

```bash
git clone https://github.com/maxbaines/just-terminal.git
cd just-terminal
make build
./bin/just-terminal
```

Running `just-terminal` without a subcommand starts the local Gateway at `http://127.0.0.1:8311` and opens it in your browser. Loopback access needs no authentication.

## Remote access

Put JustTerminal behind an HTTPS reverse proxy and give it the final public origin:

```bash
./bin/just-terminal serve \
  --addr 127.0.0.1:8080 \
  --behind-reverse-proxy \
  --public-origin https://terminal.example.com \
  --tunnel-origin 'https://{id}.apps.example.com'
```

Then create the single-use owner-enrollment link on the Host:

```bash
./bin/just-terminal auth init --origin https://terminal.example.com
```

Open the printed URL, register a passkey, enroll TOTP, and save the recovery codes. Passkeys are scoped to the configured hostname, so choose the final HTTPS origin before enrolling. The reverse proxy must forward both normal HTTP traffic and WebSocket upgrades.

See [Authentication](authentication.md) for setup, recovery, storage, and reset details.

## Docker and Coolify

The repository Dockerfile builds JustTerminal on top of the Codex universal image and includes Codex CLI, Claude Code, Playwright CLI with Chromium, zsh, GitHub CLI, Starship, delta, lazygit, and yazi. These JustTerminal-managed additions are grouped and versioned near the top of the final Docker stage, and each version can be overridden with a Docker `--build-arg`. The image listens on container port `8311`.
New terminal panes start in `/workspace` by default.

For a Coolify deployment:

1. Build from the repository `Dockerfile`.
2. Expose port `8311` through an HTTPS domain.
3. Set `JUST_TERMINAL_PUBLIC_ORIGIN` to that exact origin (for example,
   `https://terminal.example.com`).
4. To expose local apps, route a wildcard hostname to the same container and set
   `JUST_TERMINAL_TUNNEL_ORIGIN` (for example,
   `https://{id}.apps.example.com`). See [Local app tunnels](local-app-tunnels.md).
5. Add persistent storage for the paths below.

| Destination | Contents |
|---|---|
| `/var/lib/just-terminal` | JustTerminal auth/config, shell history, Git/GitHub/npm settings, SSH/GnuPG state, and other XDG state |
| `/root/.codex` | Codex configuration, file-backed login, skills/plugins, and resumable sessions |
| `/root/.claude` | Claude Code configuration, login, and sessions |
| `/workspace` | Repositories and working files |

Do not persist `/run/just-terminal`; it contains runtime-only sockets. Treat the persisted volumes as sensitive because they can contain access tokens, private keys, and shell history.

### What persistence means

The Session Owner survives Remote Client disconnects and Gateway restarts, so live shells continue through a web-server restart or binary redeploy that leaves the Session Owner running.

A Host reboot, container replacement, or Session Owner stop still terminates live PTYs and their processes. Persistent volumes preserve files, configuration, resumable agent history, and the workspace names shown in the sidebar. Restored workspaces start with fresh panes; volumes cannot preserve a running shell process.

## Expose a local web app

Web apps running on the JustTerminal Host or inside its container can be reached through the existing JustTerminal URL. Start the app on a local port, for example:

```bash
npm run dev -- --host 127.0.0.1 --port 5173
```

Register that port with JustTerminal:

```bash
curl -sS \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{"port":5173}' \
  http://localhost:8311/api/tunnels
```

The response includes a short tunnel ID and a capability URL on the configured
wildcard origin:

```json
{"id":"a7k2q","port":5173,"url":"https://a7k2q.apps.example.com/_just-terminal/connect#token=…"}
```

Open the returned URL. The app receives its own hostname root, so ordinary
`/assets`, `/api`, cookies, redirects, and WebSockets work without application
changes. No additional container port needs to be published. Tunnel
registrations last until the JustTerminal Gateway restarts.

Wildcard DNS, TLS, and reverse-proxy routing must be configured once by the
operator. See [Local app tunnels](local-app-tunnels.md) for Caddy, Apache,
Traefik, and Coolify recipes.

## Agent integration with MCP

`just-terminal mcp` exposes a [Model Context Protocol](https://modelcontextprotocol.io) server over JSON-RPC 2.0 on stdio. It connects to a running local JustTerminal instance and provides tools for:

| Area | Tools |
| --- | --- |
| Terminals | `run_command`, `send_input`, `get_screen`, `get_scrollback`, `get_pane_context` |
| Workspaces | `list_workspaces`, `create_workspace`, `switch_workspace`, `rename_workspace`, `close_workspace` |
| Panes | `create_pane`, `rename_pane`, `close_pane`, `list_panes`, `get_layout`, `move_pane_to_workspace` |
| Codex | `get_codex_status`, `launch_codex`, `list_codex_skills`, `set_codex_skill_enabled`, `auto_name_pane` |
| Host files | `read_file`, `list_files`, `create_directory` |
| S3 | `list_s3_connections`, `list_s3_objects`, `get_s3_object_info`, `list_transfer_jobs`, `start_transfer`, `transfer_job_action` |
| Tunnels and settings | `list_tunnels`, `create_tunnel`, `close_tunnel`, `get_config`, `update_config` |

Terminal and pane tools target the MCP session's selected workspace. The first
sessiond-backed call attaches to the first available workspace; use
`switch_workspace` to select another. `list_panes` and `get_layout` accept an
optional `workspace` for observation without changing that selection.
`create_pane` accepts `cwd` for a terminal's starting directory. Browser panes
are client-rendered: navigate through the browser UI; the previously advertised
but ignored `url` and `browser_port` arguments now return an explicit error.

`move_pane_to_workspace` takes the **source** `workspace_id` and `pane_id`, and
moves the live pane into a **new** workspace while preserving Codex association.
Its result includes the new `workspaceId`; switch explicitly to target it.
Codex and other Gateway tools use explicit workspace IDs where applicable.

`get_pane_context` returns the live cwd, foreground command and Git summary.
`get_scrollback` pages backward through retained history using `next_cursor`.
The `pane://<pane_id>` resources expose current terminal screens in the selected
workspace; list them again after creating, closing, moving or switching panes.
Resource subscriptions report live terminal output.

Codex tools require the host's Codex installation and provider configuration.
Skill toggles use the absolute skill path returned by `list_codex_skills`.
S3 tools use connections configured in Settings and never return credentials.
`start_transfer` supports `s3-to-host`, `host-to-s3` and `s3-to-s3`, including
batch selections and verified S3 moves. Supply the current connection revision
from `list_s3_connections`, then poll `list_transfer_jobs`. Overwrite decisions
require the job's current `decision` token in `transfer_job_action`.

The Gateway must be running for Codex, file, S3, config and tunnel tools. These
use its existing authentication boundary; reverse-proxy deployments that require
authentication also require it for these HTTP calls. `initialize` and `tools/list`
work even when the app is stopped. For an isolated instance, launch the MCP
process with the same `XDG_RUNTIME_DIR` as its Gateway and Session Owner.

### Amplifier

```bash
just-terminal amplifier install
```

### Claude Code

```bash
claude mcp add just-terminal -- just-terminal mcp
```

### OpenCode

Add this server to `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "just-terminal": {
      "type": "local",
      "command": ["just-terminal", "mcp"]
    }
  }
}
```

## CLI

| Command | Purpose |
|---|---|
| `just-terminal` | Start locally on `127.0.0.1:8311` and open a browser |
| `just-terminal serve` | Start a Gateway for local or reverse-proxied access |
| `just-terminal install` | Install systemd or launchd services |
| `just-terminal uninstall` | Remove the installed services |
| `just-terminal deploy user@host` | Copy and install the current binary over SSH |
| `just-terminal doctor` | Inspect Gateway, Session Owner, and service health |
| `just-terminal session list\|attach` | List Workspaces or inspect a Workspace's Pane composition |
| `just-terminal pane create\|close\|resize` | Script Pane lifecycle and PTY sizing |
| `just-terminal read-screen <pane>` | Read the live screen or page backward through server-side scrollback |
| `just-terminal layout get` | Print a Workspace's current layout as an ASCII diagram |
| `just-terminal auth ...` | Initialize, inspect, or reset owner authentication |
| `just-terminal mcp` | Start the local stdio MCP server |
| `just-terminal amplifier install` | Install the JustTerminal Amplifier bundle |
| `just-terminal version` | Print version information |

Run `just-terminal <command> --help` for command-specific flags.

## How it works

```text
Remote Client (browser or installed PWA)
    ↕ WebSocket
Gateway (Go HTTP server, auth, configuration, file and tunnel APIs)
    ↕ Unix socket
Session Owner (Workspace registry, PTYs, VT buffers, replay)
    ↕ PTY
shells and coding agents
```

Each terminal Pane is backed by a real PTY. The Session Owner, not the browser, owns terminal state and answers terminal queries. The Gateway can therefore restart independently, and a reconnecting Remote Client receives a fresh serialization of the current VT cell grid plus retained scrollback.

Close controls are also Session Owner-authoritative. Idle Bash and Zsh panes close immediately; panes with running commands require confirmation. Codex/driver panes are treated as busy, while browser panes and panes whose activity cannot be inspected are treated as unknown and fail safe to confirmation.

The browser renders terminals with xterm.js and arranges Pane Groups with dockview. One WebSocket carries binary Pane I/O and JSON control messages between a Remote Client and the Gateway.

## Releases and updates

[Public GitHub Releases](https://github.com/maxbaines/just-terminal-docs/releases)
provide checksummed Linux and macOS archives for x64 and ARM64, plus the installer.
Windows uses those Linux archives through WSL2. See each release's verification
notes for the platforms actually exercised. Downloads are unsigned; macOS builds
are not notarized. No native Windows executable or Homebrew tap is published.

Release tags use `vMAJOR.MINOR.PATCH`. Archives keep stable names across versions,
so `/releases/latest/download/just-terminal_linux_amd64.tar.gz` follows the latest
stable release. Use `/releases/download/vX.Y.Z/...` to pin a version. Preserve the
previous binary to roll back, and stop the Gateway and Session Owner before a
manual replacement if the release notes require it; stopping the Session Owner
ends running shells.

**About** contains update status and the native self-update controls. Container
deployments update by rebuilding or pulling and redeploying the image; the
in-app updater does not rewrite binaries in containers.

## Contributing

Start with the [contribution guidelines](../CONTRIBUTING.md) for source access, issue reports, change scope, and PR evidence. The commands below are for collaborators working in the source checkout.

Build and run the isolated local development stack:

```bash
make build
make dev-local
```

Before committing, run the required static checks:

```bash
cd web && npm run check:fast
cd .. && go build ./...
```

JustTerminal does not accept new unit tests. Changes are verified against a real Gateway, Session Owner, shell, and browser. Start every verification pass with a fresh development runtime and a newly created Workspace and Pane, then exercise the behavior with `playwright-cli`:

```bash
playwright-cli open http://127.0.0.1:8313
playwright-cli snapshot
# interact with the real UI and inspect the result
playwright-cli close
```

Read [AGENTS.md](../AGENTS.md) before contributing; it contains the full verification policy and fixture-hygiene requirements.
