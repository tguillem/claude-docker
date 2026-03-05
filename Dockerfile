# Use Debian Trixie as base to match host toolchain
FROM debian:trixie

# Install curl for installers
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates xz-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install self-contained Node.js binary to /opt/node (survives /usr mount)
RUN curl -fsSL https://nodejs.org/dist/v20.19.0/node-v20.19.0-linux-x64.tar.xz -o /tmp/node.tar.xz && \
    echo "b4e336584d62abefad31baecff7af167268be9bb7dd11f1297112e6eed3ca0d5  /tmp/node.tar.xz" | sha256sum -c - && \
    tar -xJ -C /opt --transform='s/^node-v20.19.0-linux-x64/node/' -f /tmp/node.tar.xz && \
    rm /tmp/node.tar.xz

# Create non-root user and directories
ARG USER
RUN test -n "$USER" || { echo "ERROR: USER build arg is required"; exit 1; } && \
    useradd -m -s /bin/bash $USER && \
    mkdir -p /home/$USER/.claude /home/$USER/.local/bin /home/$USER/.npm-global /home/$USER/.config && \
    chown $USER:$USER /home/$USER/.claude /home/$USER/.local /home/$USER/.local/bin /home/$USER/.npm-global /home/$USER/.config

USER $USER

ENV NPM_CONFIG_PREFIX=/home/$USER/.npm-global
ENV PATH=/home/$USER/.local/bin:/home/$USER/.npm-global/bin:/opt/node/bin:$PATH

# Pre-install ccstatusline so npx doesn't need to fetch it at runtime
RUN npm install -g ccstatusline@latest

# Install Claude Code via native installer (bump CLAUDE_VERSION to force update)
ARG CLAUDE_VERSION=1
RUN curl -fsSL https://claude.ai/install.sh | bash

# Set the default command to start an interactive session
CMD ["claude"]
