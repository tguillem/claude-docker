# claude-docker

Run [Claude Code](https://claude.ai) inside a Docker container with access to your host toolchain and working directory.

## Overview

- Isolates Claude Code from your host system (`--security-opt no-new-privileges`)
- Mounts host `/usr` ro so Claude can use your compilers, tools, and libraries
- Shares Claude config, ccache, and D-Bus session across host and container
- Container username matches host username — no path translation needed

## What gets mounted

| Host path | Container path | Mode | Why |
|---|---|---|---|
| `~/work` | `~/work` | rw | Project files Claude Code reads and edits |
| `~/.claude` | `~/.claude` | rw | Claude Code config, memory, and project settings |
| `~/.claude.json` | `~/.claude.json` | rw | Claude Code authentication and session state |
| `~/.config/ccstatusline` | `~/.config/ccstatusline` | rw | Status line tool config shared with host |
| `~/.cache/ccache` | `~/.cache/ccache` | rw | Compiler cache shared with host |
| `/usr` | `/usr` | ro | Host compilers, libraries, and tools (gcc, make, etc.) |
| `/etc/alternatives` | `/etc/alternatives` | ro | Debian alternatives symlinks required by `/usr` binaries |
| D-Bus user session socket | D-Bus user session socket | rw | Desktop notifications from inside the container |

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | Debian Trixie image with Node.js 20 and Claude Code |
| `claude-docker-build` | Build (or rebuild) the image |
| `claude-docker` | Run Claude Code in the current directory |

## Prerequisites

The `Dockerfile` uses `debian:trixie` as its base. If your host runs a different distribution or release, update the `FROM` line to match — this ensures the ro `/usr` mount provides compatible libraries.

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
claude-docker-bash     # starts bash (symlink claude-docker to claude-docker-bash)
claude-docker-npx      # starts npx  (symlink claude-docker to claude-docker-npx)
```

The entrypoint is selected based on the script name. Create symlinks for the alternate modes:

```bash
ln -s claude-docker claude-docker-bash
ln -s claude-docker claude-docker-npx
```
