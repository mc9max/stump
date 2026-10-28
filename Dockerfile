# Stump (stumpapp/stump) wrapper for Railway.
#
# Why each non-default setting exists:
# - FROM pins the upstream image by tag AND digest:
#   aaronleopold/stump 0.1.11 (latest stable, 2026-10-20), amd64 manifest
#   digest sha256:9233ee02632ee77e4c7090afa9383634c767de0d092f23571656c3ffcffdabdc
#   (verified against the Docker Hub registry API; the multi-arch index
#   digest is sha256:2d62217aaabb68466d08d8f). Never :latest: a moving
#   tag would change the comics server under existing libraries.
# - USER root is inherited from the upstream image: its own entrypoint
#   defaults PUID=0 (run as root), which is what Railway's root-owned
#   volume needs, so the server can write its SQLite database and
#   library folders without EACCES crash loops.
# - STUMP_CONFIG_DIR=/data/config is baked in: Stump stores its SQLite
#   database, thumbnails and cache under the config dir, and Railway
#   allows exactly one volume per service, so config and libraries
#   share the /data mount (/data/config, /data/libraries) instead of
#   the upstream default of separate /config and /data mounts.
# - STUMP_TRUST_PROXY_HEADERS=true is baked in: Railway terminates TLS
#   at the edge and forwards to the container over plain HTTP, so
#   Stump must trust the forwarded scheme/host or OPDS feeds and
#   absolute URLs would be built from the internal address.
# - STUMP_PORT is NOT baked: entrypoint.sh maps Railway's injected PORT
#   onto it at every boot (upstream reads STUMP_PORT via its STUMP_
#   env-prefix config loader, verified in upstream source).
# - The wrapper entrypoint chains to the upstream /entrypoint.sh, which
#   execs the server binary intact; see entrypoint.sh for the rationale.
# - No HEALTHCHECK: Railway's external healthcheckPath (/) is the check
#   that matters; the distroless base has no curl/wget for an
#   in-container check anyway.
# - No EXPOSE: the server binds Railway's injected PORT via the
#   entrypoint mapping, so a static port declaration would be a lie.
FROM aaronleopold/stump:0.1.11@sha256:9233ee02632ee77e4c7090afa9383634c767de0d092f23571656c3ffcffdabdc
ENV STUMP_CONFIG_DIR=/data/config \
    STUMP_TRUST_PROXY_HEADERS=true
COPY --chmod=755 entrypoint.sh /railway-entrypoint.sh
COPY samples/sample.cbz /app/samples/sample.cbz
ENTRYPOINT ["/railway-entrypoint.sh"]
LABEL org.opencontainers.image.source="https://github.com/mc9max/stump"
LABEL org.opencontainers.image.title="Stump"
LABEL org.opencontainers.image.description="Stump comics, manga and digital book server with OPDS support, wrapped for one-click Railway deploys"
