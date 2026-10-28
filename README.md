# Stump

Stump is a free, open-source comics, manga and digital book server with
OPDS support, built-in readers for EPUB, PDF, CBZ/ZIP and CBR/RAR, and
multi-user accounts with permissions. Deploy it on Railway in one click
and read your collection from any browser, e-reader app, or OPDS client.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/stump?utm_campaign=stump)

## Deploy and Host

One service, one volume, no companion databases. Stump runs as a single
Rust process with a SQLite database under `/data/config` and your comic
libraries under `/data/libraries` on a persistent volume, so restarts
and redeploys keep every library, reading position, and account. The
deploy form has zero fields: the wrapper maps Railway's injected `PORT`
to Stump's port on every boot and trusts the Railway edge proxy for
scheme/host, so the public URL just works.

First run, in order:

1. Open the public URL and register the first account — on a fresh
   server that account automatically becomes the server owner. There is
   no email step; Stump accounts are local username/password accounts.
2. Create a library pointing at `/data/libraries/sample` and let it
   scan: the deploy seeds one sample comic there, so the scan finds a
   book immediately and proves the library → scan → reader cycle.
3. Point more libraries at folders under `/data/libraries` (add files
   via Stump's upload feature if you enable it, or through any future
   volume tooling) and read from the built-in readers or any OPDS
   client (Kobo and KOReader sync are supported).

## Why Deploy

- **Your books, your server.** No store lock-in, no reading-history
  telemetry: the library, progress, and annotations live in your
  database.
- **Every format in one place.** EPUB, PDF, CBZ/ZIP and CBR/RAR with
  built-in readers, plus OPDS v1.2 and v2.0 feeds for third-party
  reading apps.
- **Multi-user done right.** Per-user permissions, age restrictions,
  and reading progress, so one server serves a household.
- **Light and always on.** A single Rust binary with SQLite — no
  Postgres to tune, no workers to feed, no Java heap to babysit.

## Common Use Cases

- A personal comics/manga library readable from phone, tablet, and
  desktop browsers.
- An OPDS feed for Kobo, KOReader, Panels, or any OPDS-compatible
  reader app.
- A household book server with separate accounts and reading progress
  per reader.
- A digital-book archive with annotations and highlights on EPUBs.

## Configuration

Every setting below is read from the environment at boot (upstream
`STUMP_` prefix). Baked wrapper values are marked; the rest are
optional service variables — the deploy form stays zero-field because
none of them are required.

| Variable | Default | What it does |
| --- | --- | --- |
| `PORT` | (Railway-injected) | Public port; entrypoint.sh maps it to `STUMP_PORT` on every boot. |
| `STUMP_CONFIG_DIR` | `/data/config` (baked) | Config root: SQLite database, thumbnails, cache. On the volume. |
| `STUMP_TRUST_PROXY_HEADERS` | `true` (baked) | Trust Railway edge `X-Forwarded-*` for scheme/host (OPDS URLs). |
| `STUMP_PORT` | from `PORT` | Server port. Set by the entrypoint; do not set directly. |
| `STUMP_VERBOSITY` | `1` | Log verbosity: 0 none, 1 info, 2 debug, 3 trace. |
| `STUMP_ENABLE_UPLOAD` | `false` | Allow users with permission to upload books/series via the web UI. |
| `STUMP_ENABLE_KOREADER_SYNC` | `false` | Enable KOReader sync support. |
| `STUMP_ENABLE_KOBO_SYNC` | `false` | Enable Kobo sync support. |
| `STUMP_ENABLE_OPDS_PROGRESSION` | `false` | Track reading progress from OPDS page loads. |
| `STUMP_ENABLE_PLAYGROUND` | `false` | Serve the GraphQL playground on GET to the GraphQL endpoint. |
| `STUMP_SESSION_TTL` | `86400` | Login session lifetime in seconds. |
| `STUMP_ACCESS_TOKEN_TTL` | (upstream default) | API access token lifetime in seconds. |
| `STUMP_REFRESH_TOKEN_TTL` | (upstream default) | Refresh token lifetime in seconds. |
| `STUMP_PASSWORD_HASH_COST` | `12` | Cost for password hashing. |
| `STUMP_PARALLELISM_MULTIPLIER` | `2` | Multiplier on logical CPUs for scanner concurrency. |
| `STUMP_PDF_RENDER_DPI` | `150` | DPI for rendering PDF pages as images. |
| `STUMP_PDF_MAX_DIMENSION` | `1200` | Max width/height for rendered PDF pages. |
| `STUMP_PDF_RENDER_FORMAT` | `webp` | Image format for rendered PDF pages. |
| `STUMP_ALLOWED_ORIGINS` | (none) | Comma-separated CORS origins. |
| `PUID` / `PGID` | `0` (root) | Upstream entrypoint user/group. Leave at root on Railway: the volume is root-owned. |

Upstream values baked into the base image and left untouched:
`STUMP_CLIENT_DIR=/app/client`, `STUMP_PROFILE=release`,
`STUMP_IN_DOCKER=true`, `PDFIUM_PATH` (PDF rendering support).

### Deployment Dependencies

- Railway Hobby plan or higher; the server is a single lightweight
  Rust process (well under 512 MB at rest) plus scan-time spikes while
  generating thumbnails.
- One persistent volume (`/data`): config/SQLite database, thumbnails,
  and libraries. A second volume is not supported by Railway and is
  not needed — everything lives under `/data`.
- No companion services, no email provider, no external database.
- Upstream status: Stump is pre-1.0 (v0.1.11 at packaging time) and
  describes itself as beta software. Libraries and reading progress
  persist on the volume across updates, but treat major-version
  upgrades as you would any beta: the volume keeps your data, and
  upstream release notes are worth a skim before updating the pin.

## Source

Wrapper: [mc9max/stump](https://github.com/mc9max/stump) — a thin
Dockerfile around the pinned upstream image
`aaronleopold/stump:0.1.11` (digest-pinned, see the Dockerfile).
Upstream: [stumpapp/stump](https://github.com/stumpapp/stump) (MIT).
