#!/usr/bin/env bash
# Build the Brigid image and, when GHCR_TOKEN is set, push it to ghcr.io.
# Used by .github/workflows/image.yml; also runs locally (build only):
#   GITHUB_REPOSITORY=owner/brigid .github/build-image.sh
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")/.."

repo="${GITHUB_REPOSITORY:?set GITHUB_REPOSITORY, e.g. owner/brigid}"
# ghcr.io refuses upper-case in image names.
image="ghcr.io/${repo,,}"
sha="$(git rev-parse --short=12 HEAD)"

podman build \
  --label "org.opencontainers.image.source=https://github.com/${repo}" \
  --label "org.opencontainers.image.revision=$(git rev-parse HEAD)" \
  -t "${image}:latest" -t "${image}:${sha}" \
  -f Containerfile .

if [[ -z "${GHCR_TOKEN:-}" ]]; then
  echo "GHCR_TOKEN not set: image built, not pushed."
  exit 0
fi

printf '%s' "$GHCR_TOKEN" |
  podman login ghcr.io -u "${GITHUB_ACTOR:?set GITHUB_ACTOR}" --password-stdin
podman push "${image}:${sha}"
podman push "${image}:latest"
