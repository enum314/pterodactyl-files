FROM node:24-trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		libnss3 \
		tini \
		ffmpeg \
		sqlite3 \
		tzdata \
		iproute2 \
		unzip \
		fonts-liberation \
		libasound2 \
		libatk-bridge2.0-0 \
		libatk1.0-0 \
		libatspi2.0-0 \
		libcairo2 \
		libcups2 \
		libcurl4 \
		libdbus-1-3 \
		libexpat1 \
		libgbm1 \
		libglib2.0-0 \
		libgtk-3-0 \
		libnspr4 \
		libpango-1.0-0 \
		libudev1 \
		libvulkan1 \
		libx11-6 \
		libxcb1 \
		libxcomposite1 \
		libxdamage1 \
		libxext6 \
		libxfixes3 \
		libxkbcommon0 \
		libxrandr2 \
		wget \
		xdg-utils \
    && rm -rf /var/lib/apt/lists/*

RUN npm install --global npm@latest typescript ts-node @types/node pnpm@latest

RUN pnpm config set store-dir /home/container/.pnpm-store
ENV PNPM_HOME="/home/container/.pnpm"
ENV PATH="$PNPM_HOME:$PATH"

ENV USER=container
ENV HOME=/home/container
WORKDIR /home/container

LABEL name="Node.js - 24" \
      version="24" \
      release="24"

STOPSIGNAL SIGINT

COPY --chown=root:root --chmod=755 ./../entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]