# syntax=docker/dockerfile:1.7

FROM denoland/deno:alpine-2.6.0

WORKDIR /app

# Copy only the files needed to resolve and cache dependencies first so
# subsequent source-only changes don't bust the dep cache layer.
COPY deno.json deno.lock ./
COPY packages/plex/deno.json ./packages/plex/deno.json
COPY packages/radarr/deno.json ./packages/radarr/deno.json
COPY packages/sonarr/deno.json ./packages/sonarr/deno.json
COPY packages/tmdb/deno.json ./packages/tmdb/deno.json
COPY packages/media-server-mcp/deno.json ./packages/media-server-mcp/deno.json

# Copy sources for all workspace packages.
COPY packages/ ./packages/

# Warm the module cache so cold starts don't pay the resolution cost.
RUN deno cache packages/media-server-mcp/src/index.ts

EXPOSE 3000

# Streamable HTTP transport, bound to all interfaces inside the container.
# Reverse-proxy / Tailscale serve sidecar is expected to terminate TLS.
ENTRYPOINT ["deno", "run", \
  "--allow-read", "--allow-write", "--allow-env", "--allow-run", "--allow-net", \
  "packages/media-server-mcp/src/index.ts"]
CMD ["--http", "--host", "0.0.0.0", "--port", "3000"]
