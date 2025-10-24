# ----------------------------------
# Environment: Postgres DB
# ----------------------------------
FROM --platform=$TARGETOS/$TARGETARCH postgres:17-alpine

LABEL author="AOME" maintainer="iommi.fuentes@zhyporium.com"
    
RUN adduser -D -h /home/container container
    
RUN apk add --no-cache curl iproute2 ca-certificates fontconfig git openssl sqlite tar tzdata pgbouncer
USER container
ENV HOME /home/container
WORKDIR /home/container
    
    
COPY --chmod=755 --chown=root:root entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]