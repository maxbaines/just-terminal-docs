# Contributing to JustTerminal

Help improve the work people do in a browser terminal: report a reproducible problem, clarify a guide, or fix a specific behavior. JustTerminal is developing quickly, so keep contributions easy to understand and review.

## Where to contribute

Public bug reports and proposals belong in [just-terminal-docs issues](https://github.com/maxbaines/just-terminal-docs/issues). Search existing reports first and add useful evidence to an existing issue when it describes the same problem.

The application source repository is private. Code changes require collaborator access; submit code PRs to `maxbaines/just-terminal`. The public repository contains selected documentation, not the application source. Anyone can report a documentation problem there. Collaborators should edit the original documents in the source repository because subsequent documentation syncs replace the published copies.

## Keep the change focused

Start with a concrete user problem. Bug fixes, reliability improvements, measured performance improvements, and corrections to documentation make useful starting points. Explain the workflow that improves and keep unrelated cleanup in a separate change.

For a new feature, dependency, architectural change, or broad rewrite, open a proposal issue before investing in implementation. Describe the smallest useful outcome and discuss its scope with a maintainer. An existing task assignment or agreed issue is already that discussion. A proposal or PR does not guarantee acceptance or a review deadline.

## Make reports reproducible

Use the bug report template and include:

- What you tried, the exact steps, and what you expected versus what happened.
- The JustTerminal version or commit, host OS, browser/device, and local or remote deployment setup. Include the agent CLI version when relevant.
- Whether it happens in a new workspace, after reconnecting, or with multiple clients; say how often an intermittent issue occurs.
- Relevant logs, screenshots, or a short recording for keyboard, dragging, resizing, and timing problems. Remove credentials, recovery codes, and private project content.

You do not need source access or a proposed fix to report a bug. For proposals, describe the user need, current workaround, and limits of the proposed behavior.

## Set up the source checkout

Read [AGENTS.md](AGENTS.md) first. Use macOS, Linux, or WSL2 with Go 1.24.4, Node.js 22, npm, and make. From the repository root:

```bash
make build
./bin/just-terminal
```

This builds the frontend and Go binary, then opens the local app. Agent CLIs are optional for ordinary terminal work; install and authenticate Codex on the host to verify managed agents.

The [development guide](docs/running-just-terminal.md#contributing) covers `make dev-local`, which also requires `air`. Preserve any existing app and shell sessions when starting a development or verification instance.

The main implementation areas are `web/src/` for the browser UI, `internal/server/` for the Gateway, `internal/sessiond/` for the Session Owner and real PTYs, and `internal/codex/` for Codex integration. The static website lives in `web/site/`.

The Session Owner owns terminal state and query replies. In particular, preserve the parser hooks described in AGENTS.md for `CSI 6n` and `OSC 11;?`; duplicate browser replies can become shell input.

## Verify the actual behavior

**Do not add unit tests.** This includes isolated Go and frontend tests. Keep existing test files; if a change breaks one, update it to match the behavior. The project's acceptance evidence comes from a real browser, Gateway, Session Owner, and shell.

Run the required static and build checks from the repository root:

```bash
npm --prefix web run check:fast
go build ./...
make build
```

Zero type/lint errors and successful builds are required. They do not establish that a feature works.

Use the `just-terminal-verify` skill in `.agents/skills/just-terminal-verify/SKILL.md` in the source checkout. Start the built binary on an unused loopback port with fresh `XDG_RUNTIME_DIR`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, and `XDG_STATE_HOME` directories under a unique temporary root. Record the URL, process IDs, runtime directory, and logs. Keep normal authenticated Codex configuration available when needed without copying credentials into evidence.

For example, once your isolated instance is running on port 8313:

```bash
playwright-cli -s=jt-contribution open http://127.0.0.1:8313
playwright-cli -s=jt-contribution snapshot
# Use click, type, and press to exercise the real workflow.
playwright-cli -s=jt-contribution screenshot
playwright-cli -s=jt-contribution close
```

Every run needs a fresh workspace and pane. Confirm shell input and visible output, then exercise the changed behavior. Agent changes need a real authenticated conversation. Observe relevant failure and recovery cases, and check desktop/mobile layouts when affected. Save the actual results and screenshots; list anything you could not verify.

Before a clean rerun, stop the disposable app and its Session Owner. If using `make dev-local`, restart the whole stack with its disposable runtime reset and check for stale sessiond processes from other worktrees. Do not edit source while a watcher is serving an active verification. Stop only the processes you created, preserving evidence and unrelated sessions.

## Prepare a reviewable pull request

Use the PR template to connect the problem to the resulting behavior and link the issue or prior agreement. Describe any tradeoff or remaining limitation. Include the exact verification commands, environment, observed results, and evidence paths or attachments.

For UI changes, provide before/after screenshots. Use a short recording when a still image cannot show the interaction. Report which platforms you actually checked. Update user instructions when behavior changes; avoid adding internal documents that merely restate the code.

AI-assisted contributions have the same requirements: understand the diff, inspect the output yourself, and verify the result. An agent's completion message is not verification evidence. Keep review discussion specific and respectful, and respond with concrete changes or reasoning.

## Documentation and website changes

Keep README and website claims aligned with the implementation. Preview the website with `npm --prefix web run site:preview`, inspect it with `playwright-cli` on desktop and mobile, and check links, images, and interactions. Read `web/site/README.md` for the website workflow.

For public documents, add the document and any linked local assets to `scripts/public-docs.txt`. Track new files before running `make preview-docs`, which validates the selected files and previews changes without publishing. Contribution templates are included in that file list so they can reach the public issue tracker through the same workflow. See `scripts/README.md` in the source checkout for details. Publication and website deployment are separate maintainer actions.

The scope and review guidance was informed by [T3 Code's contributing guide](https://github.com/pingdotgg/t3code/blob/main/CONTRIBUTING.md) and [PR template](https://github.com/pingdotgg/t3code/blob/main/.github/pull_request_template.md); the commands and verification requirements here are specific to JustTerminal.
