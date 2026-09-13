# Working in JustTerminal

[← JustTerminal](../README.md) · [Installation and self-hosting](running-just-terminal.md)

JustTerminal brings agent conversations, real shells, and file previews into a
browser workspace on your own machine or server. This guide covers everyday use;
the [running guide](running-just-terminal.md) covers installation, remote access,
Docker, and integrations.

## Your first workspace

1. Start JustTerminal and open its URL in your browser.
2. Choose **New workspace**, name your project, and `cd` into its directory.
3. Start your usual commands, editor, or coding agent in the terminal.
4. Add a terminal tab or split, and open files from the sidebar beside your work.
5. With Codex installed and signed in on the host, choose **JT** or **New agent**
   to give an agent a task.

Each project can have its own workspace. Split terminals to watch commands side
by side, stack tabs, or drag a pane into the sidebar to create another workspace.
The sidebar shows the current directory, Git branch, and change count.

## JT and independent agents

Choose **JT** in the agents list to work with the assistant that can operate
JustTerminal. Ask it to create a workspace, inspect a terminal, or recruit agents
for a project. For example:

> Start an agent in this project to review the README against the implemented features.

Or choose **New agent**, enter a project folder and task, and send it. Each agent
runs an independent Codex conversation with normal tools and project permissions.
Managed agents require Codex installed and signed in on the machine running
JustTerminal.

Click an agent's name to speak directly to it, including while it works. Its card
shows current activity and requests for attention. Answer supported questions and
approvals in chat; use the terminal for requests that need it. Other agents keep
working while you talk to one.

### Chat and terminal views

On desktop, each agent has its own workspace with chat and terminal views grouped
under its sidebar card. Dock chat beside a file or terminal, or keep it in a tab.
**Show terminal** opens the same conversation. Closing a chat or terminal view
leaves the agent running.

Replies can include local file links and images: click a file to open it in the
workspace viewer, or open an image at full size. Tool activity stays collapsed
until you expand it.

### Share context

Type `/` in chat to autocomplete files and folders on the JustTerminal host, or
use `/files` to browse from the agent's project folder. Keep typing a path such as
`/workspace/just-terminal/` to narrow the suggestions. Use the arrow keys to
choose, **Enter** to insert a path, **Tab** to browse into a folder, or **Escape**
to dismiss the suggestions. You can also click a suggestion. Selecting a path
adds it to your draft; send the message when you're ready.

**Use current pane** includes the current pane context when sending to JT or
starting an agent. **Add selection** attaches highlighted terminal text, useful
for asking about a command's output or an error.

You can also paste an image or screenshot into a terminal. JustTerminal saves it
on the host and inserts its path for the CLI or agent to use.

### Stop, start fresh, and clear finished work

- **Stop** interrupts the selected agent's current Codex turn. **Stop all** also
  interrupts the other agents. Normal Codex interrupt behavior applies to shell
  processes the agents have already started.
- **New chat** starts a fresh JT conversation when JT is idle; previous history
  stays saved.
- Close an inactive agent, or choose **Clear inactive**, to close its Codex views
  and empty workspace without deleting saved history. Shells and browser panes
  you added stay accessible as a normal workspace.

## Terminal agents and skills

Run Codex, Claude Code, or another CLI agent in an ordinary terminal pane. For
Codex, **New Codex session** starts a session in a chosen project folder. Codex
sidebar cards show its current task, remaining context, and requests for answers
or approval. The sidebar footer shows account and usage limits when the provider
reports them.

Open **Skills** in the file sidebar to search the skills available to the selected
terminal's project. Read instructions in a Markdown tab, enable or disable a
skill, or toggle them all. Settings are saved in Codex; restart existing Codex
sessions to apply changes.

**Use skill** adds the skill's `$name` reference to the active Codex terminal
prompt. Add your task and send it when ready.

The [built-in MCP server](running-just-terminal.md#agent-integration-with-mcp)
also lets compatible agents manage workspaces and Codex sessions, inspect
terminals and files, manage S3 transfers, and expose local apps.

## Files beside your work

The file sidebar follows your active terminal as you `cd`, with Git change badges
beside files. Open a file from the tree or click a detected path in terminal output
to read it in a tab.

Source code has syntax highlighting; Markdown renders as a document; images open
as previews. HTML files have preview and source views. These viewers are
read-only. Keep editing with your terminal editor or agent, and use the previews
to review changes, read plans, or inspect logs.

## S3 files and transfers

Add a connection in **Settings → S3**, then switch the sidebar from **Local** to
**S3** to browse buckets and folders. AWS S3 and compatible services with custom
endpoints are supported. Saved credentials stay on the JustTerminal host.

- Upload from your computer or download to your browser.
- Copy between the host and S3, or between buckets and connections.
- Select several files or copy a whole folder.
- Follow progress in **Transfers**, resolve overwrites, cancel jobs, and retry
  failures.
- Delete objects and folders with confirmation.

“Local” means the machine running JustTerminal. Browser uploads and downloads
reach the device you're browsing from. Copies between the host and S3, or between
S3 connections, run on the server and continue after you close the browser tab.
Job history survives server restarts; interrupted jobs can be retried.

## Preview a running app

Start a web app in a terminal and add its port in **Settings → Local apps**. Open
the resulting URL to try it. Each app gets its own hostname, with assets,
redirects, cookies, and WebSockets forwarded through the tunnel.

For remote deployments, configure wildcard DNS, TLS, and proxy routing using the
[local app guide](local-app-tunnels.md). Once configured, you do not need a
separate published container port for every development server.

## Desktop, iPad, and phone

On desktop and iPad, arrange panes around the work you're doing. On a phone,
switch between **Chat**, **Files**, **Console**, and **Agents** using the workspace
controls. Activity indicators show working agents and requests for attention.
Extra keys are available for terminal input and agent chat, with touch controls
and voice input where supported. You can install JustTerminal as a PWA.

Choose from nine themes and configure fonts, backgrounds, and keyboard shortcuts
in settings.

## What stays when you leave

Your terminal sessions live on the host. Close the browser or lose your connection,
then reconnect to the current screen and scrollback. Sessions also survive a
restart of the web server while the process that owns the shells keeps running.

A host reboot or container replacement ends running shells. Persistent storage
keeps your files, settings, workspace names, and resumable agent history; it does
not keep processes alive. See [what persistence means](running-just-terminal.md#what-persistence-means)
for deployment details.
