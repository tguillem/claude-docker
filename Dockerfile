ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG PACKAGES="curl ca-certificates"
RUN if command -v apt-get >/dev/null; then \
      apt-get update && apt-get install -y --no-install-recommends $PACKAGES && \
      apt-get clean && rm -rf /var/lib/apt/lists/*; \
    elif command -v dnf >/dev/null; then \
      dnf install -y $PACKAGES && dnf clean all; \
    elif command -v apk >/dev/null; then \
      apk add --no-cache $PACKAGES; \
    fi

ARG USER
ARG UID=1000
RUN test -n "$USER" || { echo "ERROR: USER build arg is required"; exit 1; } && \
    existing=$(getent passwd $UID | cut -d: -f1 || true) && \
    if [ -n "$existing" ] && [ "$existing" != "$USER" ]; then userdel "$existing"; fi && \
    useradd -m -s /bin/bash -u $UID $USER && \
    mkdir -p /home/$USER/.claude /home/$USER/.local/bin /home/$USER/.config && \
    chown $USER:$USER /home/$USER/.claude /home/$USER/.local /home/$USER/.local/bin /home/$USER/.config

COPY extra-build.sh /tmp/extra-build.sh
RUN bash /tmp/extra-build.sh && rm /tmp/extra-build.sh

USER $USER

ENV PATH=/home/$USER/.local/bin:/opt/node/bin:$PATH

ARG CLAUDE_VERSION=1
RUN curl -fsSL https://claude.ai/install.sh | bash

CMD ["claude"]
