FROM node:25-trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		libnss3 \
		tini \
		ffmpeg \
		sqlite3 \
		tzdata \
		iproute2 \
    && rm -rf /var/lib/apt/lists/*

RUN npm install --global npm@latest typescript ts-node @types/node pnpm@latest

RUN pnpm config set store-dir /home/container/.pnpm-store
ENV PNPM_HOME="/home/container/.pnpm"
ENV PATH="$PNPM_HOME:$PATH"

ENV USER=container
ENV HOME=/home/container
WORKDIR /home/container

LABEL name="Node.js" \
      version="25" \
      release="25"

STOPSIGNAL SIGINT

COPY --chown=root:root --chmod=755 ./../entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]