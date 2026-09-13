# [JustTerminal](https://justterminal.com)

**Your terminal, with room for the whole project.**

Give an agent a task, keep your dev server running, and open the files you're reviewing beside the conversation. Agents can work without terminal panes. When you need to leave, close the tab. Your shells keep running, ready for you to reconnect from your laptop or phone.

JustTerminal runs on your own machine or server and opens in a browser. Use the shell, editor, and command-line tools you already know.

[Try it](#try-it) · [Self-hosting guide](docs/running-just-terminal.md) · [Report an issue](https://github.com/maxbaines/just-terminal-docs/issues)

![JustTerminal with Codex, rendered Markdown, highlighted TypeScript, and an expanded project file tree arranged side by side](docs/visual-reference/just-terminal-desktop-v1.png)

## A workspace for each project

Give a project a workspace, then arrange it around what you're doing. Split terminals to watch commands side by side, keep extra shells in tabs, or drag a pane into the sidebar to start a separate workspace.

The sidebar shows each workspace's current directory, Git branch, and change count. When you come back to a project, there's enough context to find your place.

## See which agent needs you

Run Codex, Claude Code, or another terminal agent in a pane. For Codex, there's also a **New Codex session** button: choose a project folder and start from there.

Codex's sidebar cards show its current task, remaining context, and requests for answers or approval. Leave several sessions working and see which one needs your attention without checking them all. The sidebar footer shows Codex account and usage limits when the provider reports them.

## Give agents a task, then keep working

Choose **JT** in the agents list to control the app in plain language: “create a workspace called API” or “start an agent to review this project.” Ask JT to recruit agents, or choose **New agent** and give it a task and project folder. Each agent runs an independent Codex conversation with normal tools and project permissions. Codex must be installed and signed in on the host.

Click an agent's name to talk directly, including while it works. Its card shows activity and when it needs your attention. Answer supported questions and approvals in chat; other requests can be answered in the terminal. Tool activity stays collapsed until you expand it.

On desktop, each agent opens in its own workspace, with chat and terminal views grouped under its card. Dock the chat beside files or a terminal, or keep it in a tab. **Show terminal** opens the same conversation. Closing a chat or terminal view leaves the agent running.

**Use current pane** includes the current pane context when sending to JT or starting an agent. **Add selection** attaches highlighted terminal text. Shared images appear in chat with full-size previews, and local file links open in the workspace viewer.

Start a fresh JT conversation with **New chat** when it is idle; previous history stays saved. Closing an inactive agent or using **Clear inactive** closes its Codex terminal views and empty workspace without deleting saved history. Any shells or browser panes you added remain accessible as a normal workspace. **Stop** interrupts the selected agent's Codex turn; **Stop all** interrupts the other agents too. Normal Codex interrupt behavior applies to shell processes already started.

Agents can use the [built-in MCP server](docs/running-just-terminal.md#agent-integration-with-mcp) to manage workspaces and Codex sessions, inspect terminals and files, manage S3 transfers, and expose local apps, too.

## Choose the skills available to Codex

Open **Skills** in the file sidebar to search the skills available to the selected terminal's project. Read a skill's instructions in a Markdown tab, enable or disable it, or toggle all skills at once. Settings are saved in Codex; restart existing Codex sessions to apply changes.

**Use skill** adds its `$name` reference to the active Codex terminal prompt. Add your task and send it when you're ready.

## Read the files beside the terminal

The file sidebar follows your active terminal as you `cd` through a project, with Git change badges beside the files. Open a file from the tree or click a detected path in terminal output to read it in a tab.

Source code gets syntax highlighting, Markdown is rendered, and images open as previews. HTML files have both preview and source views. The viewers are read-only: use them to check an agent's changes, read a plan, or inspect a log while keeping your editor in the terminal.

Copy an image or screenshot and paste it into a terminal. JustTerminal saves it on the host and inserts its path for your CLI or agent to use.

## Work with S3 alongside local files

Switch the sidebar from **Local** to **S3** to browse buckets and folders. Save connections to AWS S3 or compatible services with custom endpoints; credentials stay on the JustTerminal host.

- Upload from your computer and download to your browser.
- Copy between the host and S3, or between buckets and connections.
- Select several files or copy a whole folder at once.
- Follow progress in **Transfers**, resolve overwrites, cancel jobs, or retry them.
- Delete objects and folders with confirmation.

Copies between the host and S3, or between S3 connections, run in the background on the server. They keep going when you close the tab. Job history survives a server restart, with interrupted jobs available to retry.

Add a connection in **Settings → S3**. “Local” refers to the machine running JustTerminal; uploads and downloads reach the computer you're browsing from.

## Open what you're building

Start a web app in a terminal and add its port in **Settings → Local apps**. Open the resulting URL to try it out. Assets, redirects, cookies, and WebSockets work through the tunnel.

Each app gets its own hostname, so a remote deployment doesn't need another published container port for every dev server. Set up wildcard DNS, TLS, and proxy routing once using the [local app guide](docs/local-app-tunnels.md).

## Come back from another device

Your terminal sessions live on the host. Close the browser or lose your connection, then reconnect to the current screen and scrollback. Sessions also survive a restart of the web server while the process that owns the shells keeps running.

Use JustTerminal in a browser or install it as a PWA. On a phone, switch between **Chat**, **Files**, **Console**, and **Agents** from the workspace controls, with indicators for working agents and requests for attention. Extra keys are available for terminal input and agent chat, alongside touch controls and voice input where supported. On any screen, choose from nine themes and configure your keyboard shortcuts.

A host reboot or container replacement still ends running shells. Persistent storage keeps your files, settings, workspace names, and resumable agent history. See [what survives a restart](docs/running-just-terminal.md#what-persistence-means).

## Try it

JustTerminal is under active development. The source repository is private; the build instructions below require collaborator access. Public documentation and issue reports live in [just-terminal-docs](https://github.com/maxbaines/just-terminal-docs).

With source access, start with a local build on **macOS, Linux, or WSL2**, using **Go 1.24.4**, **Node.js 22**, npm, and make:

```bash
git clone https://github.com/maxbaines/just-terminal.git
cd just-terminal
make build
./bin/just-terminal
```

Your browser opens at **http://127.0.0.1:8311**. Local access needs no account setup. Agent CLIs are optional; install and sign in to the ones you want to use on the host.

For a first look:

1. Click **New workspace** and give your project a name.
2. `cd` into your project and start your usual shell tools or coding agent.
3. Add a terminal tab or split, then open the file sidebar to inspect your project alongside it.
4. With Codex installed and signed in, choose **JT** or **New agent** to give it a task. Open its chat, inspect shared files, or add guidance while it works.
5. Close the browser tab and reopen JustTerminal. Your session is still there.

Download checksummed Linux and macOS builds for x64 or ARM64 from [public GitHub Releases](https://github.com/maxbaines/just-terminal-docs/releases/latest). Windows uses the Linux builds through WSL2; there is no native Windows executable. See [download and installation instructions](docs/running-just-terminal.md#download-and-run), including the unsigned macOS build notes. The repository also includes a Dockerfile with Codex CLI, Claude Code, Playwright with Chromium, and a shell toolbox; see [Docker and Coolify setup](docs/running-just-terminal.md#docker-and-coolify).

## Run it on your own terms

Keep it local, or put it behind HTTPS to reach it from other devices. Remote sign-in uses passkeys, TOTP, and recovery codes. Authentication lives on your host; there's no external identity service or database to set up.

- [Remote access and deployment](docs/running-just-terminal.md#remote-access)
- [Authentication and recovery](docs/authentication.md)
- [CLI reference and agent integrations](docs/running-just-terminal.md#cli)
- [Releases and updates](docs/running-just-terminal.md#releases-and-updates)

## Help shape JustTerminal

If something gets in your way, [open an issue](https://github.com/maxbaines/just-terminal-docs/issues) and tell us what you were trying to do. Read the [contribution guidelines](CONTRIBUTING.md) for useful bug reports, focused proposals, and PR expectations. Discuss substantial changes before implementing them. Source contributions require repository access and real browser verification; collaborators should also read [AGENTS.md](AGENTS.md).

JustTerminal builds on [muxterm](https://github.com/kenotron-ms/muxterm). See [fork provenance](docs/fork-provenance.md) for its origins and upstream policy.

Licensed under [AGPL-3.0-or-later](LICENSE).
