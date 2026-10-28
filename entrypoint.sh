#!/bin/sh
# Stump entrypoint for Railway.
#
# Why this script exists (read before changing it):
# - Stump does NOT read Railway's injected PORT. It binds STUMP_PORT
#   (upstream default 10801, loaded from the STUMP_ env prefix).
#   This script maps PORT -> STUMP_PORT on every boot, so Railway's
#   edge always has something to reach, on whatever port Railway
#   assigns.
# - Railway allows exactly one volume per service, so the server
#   config/SQLite database and the comic libraries share the single
#   /data mount: /data/config (STUMP_CONFIG_DIR, baked in the
#   Dockerfile) and /data/libraries. The upstream default of separate
#   /config and /data mounts cannot be expressed on Railway.
# - The sample comic is seeded only when missing, so restarts never
#   overwrite user files. It exists so a fresh deploy has something
#   to scan: create a library pointing at /data/libraries/sample and
#   the scan finds the seeded book immediately, proving the full
#   library -> scan -> reader cycle before adding real collections.
# - First-run login is created in the web UI, not from a template
#   variable: on a fresh server the first registered account becomes
#   the server owner (verified in upstream source). There is no
#   email step: Stump accounts are local username/password accounts.
# - The upstream entrypoint is exec'd intact so its PUID/PGID handling
#   and the server binary invocation stay as upstream intended; this
#   script only adds the Railway mappings above.
set -e

PORT="${PORT:-10801}"
export STUMP_PORT="${PORT}"

mkdir -p /data/config /data/libraries/sample

if [ ! -f /data/libraries/sample/sample.cbz ]; then
  cp /app/samples/sample.cbz /data/libraries/sample/sample.cbz
fi

echo "[stump] listening on 0.0.0.0:${PORT}, config=/data/config, libraries=/data/libraries"
exec /entrypoint.sh "$@"
