# claude-docker

Run [Claude Code](https://claude.ai) inside a Docker container with access to your host toolchain and working directory.

## Overview

- Isolates Claude Code from your host system (`--security-opt no-new-privileges`)
- Mounts host `/usr` ro so Claude can use your compilers, tools, and libraries
- Shares Claude config across host and container
- Optional extras: Node.js/ccstatusline, ccache, D-Bus (via `extra-build.sh` and `config`)

## What gets mounted

Always mounted by the script:

| Host path | Container path | Mode | Why |
|---|---|---|---|
| `$WORK_ROOT` | `$WORK_ROOT` | rw | Project files Claude Code reads and edits |
| `~/.claude` | `~/.claude` | rw | Claude Code config, memory, and project settings |
| `~/.claude.json` | `~/.claude.json` | rw | Claude Code authentication and session state |
| `/usr` | `/usr` | ro | Host compilers, libraries, and tools (gcc, make, etc.) |
| `/etc/alternatives` | `/etc/alternatives` | ro | Debian alternatives symlinks (auto-detected) |

The default `config.in` also mounts ccstatusline, D-Bus session socket, and ccache. See [Configuration](#configuration) to customise.

## Extra build steps

To add packages or tools to the image, copy the template and uncomment what you need:

```bash
cp extra-build.sh.in extra-build.sh
vi extra-build.sh
./claude-docker-build
```

For example, uncomment the Node.js lines to install Node.js 20 and ccstatusline. 

## Configuration

Copy the template and edit to taste:

```bash
cp config.in config
vi config
```

`config` lets you set `WORK_ROOT` and `EXTRA_DOCKER_ARGS` (an array of extra `docker run` flags). The defaults in `config.in` include mounts for ccstatusline, D-Bus, and ccache. If no `config` file exists, `config.in` is used as-is.

## Setup

```bash
# Build the image (uses your username automatically)
./claude-docker-build

# Full rebuild (no cache)
./claude-docker-build --full

# Setup ccstatusline (tmux/screen status bar integration)
./claude-docker-npx ccstatusline@latest
```

## Usage

Run from anywhere under `~/work`:

```bash
cd ~/work/my-project
claude-docker          # starts claude
```
