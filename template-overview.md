[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/stump?utm_campaign=stump)

# Deploy and Host

Stump is a free, open-source comics, manga and digital book server with
OPDS support and built-in readers for EPUB, PDF, CBZ/ZIP and CBR/RAR.
Deploy it on Railway in one click: one service, one volume, no
companion databases, and a zero-field deploy form. Register the first
account in the web UI (it becomes the server owner automatically), create
a library pointing at `/data/libraries/sample`, and the scan finds the
seeded sample comic immediately — proving the library → scan → reader
cycle before you add real collections.

## About Hosting

Hosting Stump on Railway means a single Rust process with a SQLite
database under `/data/config` and comic libraries under `/data/libraries`
on a persistent volume. The wrapper maps Railway's injected `PORT` to
Stump's port on every boot and trusts the Railway edge proxy for
scheme/host, so OPDS feeds and absolute URLs are built from the public
domain. Restarts and redeploys keep every library, reading position,
and account. Railway terminates TLS at the edge; Stump's plain HTTP
listener serves the full UI, GraphQL API, and OPDS feeds.

## Why Deploy

- **Your books, your server.** No store lock-in and no reading-history
  telemetry: library, progress, and annotations live in your database.
- **Every format in one place.** EPUB, PDF, CBZ/ZIP and CBR/RAR with
  built-in readers, plus OPDS v1.2 and v2.0 feeds for third-party apps.
- **Multi-user done right.** Per-user permissions, age restrictions,
  and reading progress, so one server serves a household.
- **Light and always on.** A single Rust binary with SQLite — no
  Postgres to tune, no workers to feed.

## Common Use Cases

- A personal comics/manga library readable from phone, tablet, and
  desktop browsers.
- An OPDS feed for Kobo, KOReader, Panels, or any OPDS-compatible
  reader app.
- A household book server with separate accounts and reading progress
  per reader.
- A digital-book archive with annotations and highlights on EPUBs.

## Dependencies for

- Railway Hobby plan or higher; a single lightweight Rust process
  (well under 512 MB at rest) plus scan-time spikes while generating
  thumbnails.
- One persistent volume (`/data`): config/SQLite database, thumbnails,
  and libraries.

### Deployment Dependencies

- No companion services, no email provider, no external database.
- Env reference (all optional; deploy form is zero-field):
  `PORT` (Railway-injected, mapped to `STUMP_PORT` by the entrypoint),
  `STUMP_CONFIG_DIR=/data/config` (baked), `STUMP_TRUST_PROXY_HEADERS=true`
  (baked), `STUMP_VERBOSITY` (default 1), `STUMP_ENABLE_UPLOAD` (default
  false), `STUMP_ENABLE_KOREADER_SYNC` / `STUMP_ENABLE_KOBO_SYNC`
  (default false), `STUMP_ENABLE_OPDS_PROGRESSION` (default false),
  `STUMP_ENABLE_PLAYGROUND` (default false), `STUMP_SESSION_TTL`,
  `STUMP_PASSWORD_HASH_COST` (default 12),
  `STUMP_PARALLELISM_MULTIPLIER` (default 2), `STUMP_PDF_RENDER_DPI`
  (default 150), `STUMP_PDF_MAX_DIMENSION` (default 1200),
  `STUMP_PDF_RENDER_FORMAT` (default webp), `STUMP_ALLOWED_ORIGINS`,
  `PUID`/`PGID` (default 0/root — leave alone on Railway).
- Upstream is pre-1.0 (v0.1.11 at packaging time) beta software; the
  volume keeps your data across updates.
