FROM node:24-trixie-slim

# Install only what is needed at runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dnsutils \
    ffmpeg \
    iputils-ping \
    libnss3 \
    python3 \
    sqlite3 \
    tini \
    tzdata \
    zip \
    && rm -rf /var/lib/apt/lists/*

RUN npm install --global npm@latest typescript ts-node @types/node pnpm@latest

RUN pnpm config set store-dir /home/container/.pnpm-store
ENV PNPM_HOME="/home/container/.pnpm"
ENV PATH="$PNPM_HOME:$PATH"

ENV USER=container
ENV HOME=/home/container
WORKDIR /home/container

STOPSIGNAL SIGINT

COPY --chown=root:root --chmod=755 ./../entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]