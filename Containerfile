# Brigid container image. Build: podman build -t brigid -f Containerfile .
# Single stage on purpose: the server runs its TypeScript through tsx at
# runtime, so the dependencies installed here are the ones it needs to start.
# Database backups are not made by this image (no pg_dump): a dedicated
# container handles them.
FROM docker.io/library/node:22-trixie-slim@sha256:8658a93ea0778be81c513e04eba758202973b91f8c83144f5a41efbb5d2bf0a9

ENV NODE_ENV=production \
    PNPM_HOME=/pnpm \
    PATH=/pnpm:$PATH
RUN corepack enable && corepack prepare pnpm@9.12.0 --activate

WORKDIR /app

# Manifests first so the dependency layer is reused when only sources change.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY apps/server/package.json apps/server/
COPY apps/web/package.json apps/web/
COPY packages/db/package.json packages/db/
COPY packages/shared/package.json packages/shared/
# NODE_ENV=production would skip devDependencies, and vite needs them to build.
RUN NODE_ENV=development pnpm install --frozen-lockfile

COPY . .
RUN pnpm build:web \
    && mkdir -p /app/data \
    && chown -R node:node /app/data

USER node
VOLUME /app/data
EXPOSE 8090

# No HEALTHCHECK here: podman builds OCI images, which drop it. See compose.yml.
CMD ["pnpm", "start"]
