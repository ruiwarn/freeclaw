# syntax=docker/dockerfile:1.7

# ── Stage 1: Build ────────────────────────────────────────────
FROM rust:1.93-slim@sha256:9663b80a1621253d30b146454f903de48f0af925c967be48c84745537cd35d8b AS builder

WORKDIR /app

# Install build dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

# 1. Copy manifests to cache dependencies
COPY Cargo.toml Cargo.lock ./
COPY crates/robot-kit/Cargo.toml crates/robot-kit/Cargo.toml
# Create dummy targets declared in Cargo.toml so manifest parsing succeeds.
RUN mkdir -p src benches crates/robot-kit/src \
    && echo "fn main() {}" > src/main.rs \
    && echo "fn main() {}" > benches/agent_benchmarks.rs \
    && echo "pub fn placeholder() {}" > crates/robot-kit/src/lib.rs
RUN --mount=type=cache,id=freeclaw-cargo-registry,target=/usr/local/cargo/registry,sharing=locked \
    --mount=type=cache,id=freeclaw-cargo-git,target=/usr/local/cargo/git,sharing=locked \
    --mount=type=cache,id=freeclaw-target,target=/app/target,sharing=locked \
    cargo build --release --locked
RUN rm -rf src benches crates/robot-kit/src

# 2. Copy only build-relevant source paths (avoid cache-busting on docs/tests/scripts)
COPY src/ src/
COPY benches/ benches/
COPY crates/ crates/
COPY firmware/ firmware/
COPY web/ web/
# Keep release builds resilient when frontend dist assets are not prebuilt in Git.
RUN mkdir -p web/dist && \
    if [ ! -f web/dist/index.html ]; then \
      printf '%s\n' \
        '<!doctype html>' \
        '<html lang="en">' \
        '  <head>' \
        '    <meta charset="utf-8" />' \
        '    <meta name="viewport" content="width=device-width,initial-scale=1" />' \
        '    <title>FreeClaw Dashboard</title>' \
        '  </head>' \
        '  <body>' \
        '    <h1>FreeClaw Dashboard Unavailable</h1>' \
        '    <p>Frontend assets are not bundled in this build. Build the web UI to populate <code>web/dist</code>.</p>' \
        '  </body>' \
        '</html>' > web/dist/index.html; \
    fi
RUN --mount=type=cache,id=freeclaw-cargo-registry,target=/usr/local/cargo/registry,sharing=locked \
    --mount=type=cache,id=freeclaw-cargo-git,target=/usr/local/cargo/git,sharing=locked \
    --mount=type=cache,id=freeclaw-target,target=/app/target,sharing=locked \
    cargo build --release --locked && \
    cp target/release/freeclaw /app/freeclaw && \
    strip /app/freeclaw

# Prepare runtime directory structure and default config inline (no extra stage)
RUN mkdir -p /freeclaw-data/.freeclaw /freeclaw-data/workspace && \
    cat > /freeclaw-data/.freeclaw/config.toml <<EOF && \
    chown -R 65534:65534 /freeclaw-data
workspace_dir = "/freeclaw-data/workspace"
config_path = "/freeclaw-data/.freeclaw/config.toml"
api_key = ""
default_provider = "openrouter"
default_model = "anthropic/claude-sonnet-4-20250514"
default_temperature = 0.7

[gateway]
port = 42617
host = "[::]"
allow_public_bind = true
EOF

# ── Stage 2: Development Runtime (Debian) ────────────────────
FROM debian:trixie-slim@sha256:f6e2cfac5cf956ea044b4bd75e6397b4372ad88fe00908045e9a0d21712ae3ba AS dev

# Install essential runtime dependencies only (use docker-compose.override.yml for dev tools)
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /freeclaw-data /freeclaw-data
COPY --from=builder /app/freeclaw /usr/local/bin/freeclaw

# Overwrite minimal config with DEV template (Ollama defaults)
COPY dev/config.template.toml /freeclaw-data/.freeclaw/config.toml
RUN chown 65534:65534 /freeclaw-data/.freeclaw/config.toml

# Environment setup
# Use consistent workspace path
ENV FREECLAW_WORKSPACE=/freeclaw-data/workspace
ENV HOME=/freeclaw-data
# Defaults for local dev (Ollama) - matches config.template.toml
ENV PROVIDER="ollama"
ENV FREECLAW_MODEL="llama3.2"
ENV FREECLAW_GATEWAY_PORT=42617

# Note: API_KEY is intentionally NOT set here to avoid confusion.
# It is set in config.toml as the Ollama URL.

WORKDIR /freeclaw-data
USER 65534:65534
EXPOSE 42617
ENTRYPOINT ["freeclaw"]
CMD ["gateway"]

# ── Stage 3: Production Runtime (Distroless) ─────────────────
FROM gcr.io/distroless/cc-debian13:nonroot@sha256:84fcd3c223b144b0cb6edc5ecc75641819842a9679a3a58fd6294bec47532bf7 AS release

COPY --from=builder /app/freeclaw /usr/local/bin/freeclaw
COPY --from=builder /freeclaw-data /freeclaw-data

# Environment setup
ENV FREECLAW_WORKSPACE=/freeclaw-data/workspace
ENV HOME=/freeclaw-data
# Default provider and model are set in config.toml, not here,
# so config file edits are not silently overridden
#ENV PROVIDER=
ENV FREECLAW_GATEWAY_PORT=42617

# API_KEY must be provided at runtime!

WORKDIR /freeclaw-data
USER 65534:65534
EXPOSE 42617
ENTRYPOINT ["freeclaw"]
CMD ["gateway"]
