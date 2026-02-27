#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Local update helper for FreeClaw.

Usage:
  ./scripts/update-local.sh [--no-pull] [--no-restart]

Options:
  --no-pull      Skip `git pull --ff-only`
  --no-restart   Skip `freeclaw service restart`
  -h, --help     Show help
USAGE
}

DO_PULL=true
DO_RESTART=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-pull)
      DO_PULL=false
      ;;
    --no-restart)
      DO_RESTART=false
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)"

if ! command -v cargo >/dev/null 2>&1; then
  echo "error: cargo not found in PATH" >&2
  exit 1
fi

if [[ "$DO_PULL" == true ]]; then
  echo "==> git pull --ff-only"
  git -C "$REPO_DIR" pull --ff-only
fi

echo "==> cargo build --release --locked"
cargo build --release --locked --manifest-path "$REPO_DIR/Cargo.toml"

BIN_SRC="$REPO_DIR/target/release/freeclaw"
BIN_DST="$HOME/.cargo/bin/freeclaw"

if [[ ! -x "$BIN_SRC" ]]; then
  echo "error: built binary not found: $BIN_SRC" >&2
  exit 1
fi

echo "==> install freeclaw to $BIN_DST"
mkdir -p "$HOME/.cargo/bin"
install -m 0755 "$BIN_SRC" "$BIN_DST"

if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
  echo "warning: $HOME/.cargo/bin is not in PATH for this shell" >&2
  echo "         run: export PATH=\"$HOME/.cargo/bin:\$PATH\"" >&2
fi

if [[ "$DO_RESTART" == true ]]; then
  echo "==> freeclaw service restart"
  "$BIN_DST" service restart
fi

echo "==> freeclaw version"
"$BIN_DST" --version
