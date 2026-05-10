ARG BUILD_ARCH
ARG BUILD_FROM=ghcr.io/home-assistant/${BUILD_ARCH}-base:latest


FROM $BUILD_FROM AS fetch_source  
RUN apk add --no-cache git
WORKDIR /ne_src
RUN git clone https://github.com/nxzai/NextExplorer .


FROM $BUILD_FROM AS base
WORKDIR /app
RUN apk add --no-cache nodejs npm
RUN apk add --no-cache bash jq


# ---------------------------------------------------------------------------
# Stage 1: Backend production dependencies
#
# Native modules (node-pty, better-sqlite3) need compilation on Alpine musl.
# Build tools are installed here and NOT carried into the final image.
# ---------------------------------------------------------------------------
FROM base AS backend_deps
ENV NODE_ENV=production
WORKDIR /app

# Build toolchain for native modules — only lives in this stage.
RUN apk add --no-cache python3 make g++ linux-headers

COPY --from=fetch_source /ne_src/package.json /ne_src/package-lock.json ./
COPY --from=fetch_source /ne_src/backend/package.json backend/package.json
COPY --from=fetch_source /ne_src/frontend/package.json frontend/package.json
COPY --from=fetch_source /ne_src/docs/package.json docs/package.json
RUN npm ci --omit=dev --workspace backend && npm cache clean --force



# ---------------------------------------------------------------------------
# Stage 2: Frontend build (dev dependencies, discarded after build)
# ---------------------------------------------------------------------------
FROM base AS frontend_build
ENV NODE_ENV=development
WORKDIR /app
COPY --from=fetch_source /ne_src/package.json /ne_src/package-lock.json ./
COPY --from=fetch_source /ne_src/backend/package.json backend/package.json
COPY --from=fetch_source /ne_src/frontend/package.json frontend/package.json
COPY --from=fetch_source /ne_src/docs/package.json docs/package.json

RUN npm ci --workspace frontend
COPY --from=fetch_source /ne_src/frontend/ ./frontend/
RUN npm run -w frontend build -- --sourcemap false



# ---------------------------------------------------------------------------
# Stage 3: Final runtime image — no compilers, no build tools
# ---------------------------------------------------------------------------
FROM base AS runtime
  
ENV NODE_ENV=production
ENV CONFIG_DIR=/config
ENV CACHE_DIR=/cache
ENV VOLUME_ROOT=/storage

RUN apk add --no-cache \
      ffmpeg \
      gosu \
      ripgrep \
      imagemagick \
      openssh-client \
      unzip \
      bash \
      shadow \
      perl \
      libva \
      mesa-va-gallium \
      curl \
  && rm -rf /tmp/* /var/cache/apk/*

RUN apk add --no-cache autofs cifs-utils

WORKDIR /app

# Make git metadata available at runtime for backend /api/features endpoint.
ARG GIT_COMMIT=""
ARG GIT_BRANCH=""
ARG REPO_URL=""
ENV GIT_COMMIT=${GIT_COMMIT}
ENV GIT_BRANCH=${GIT_BRANCH}
ENV REPO_URL=${REPO_URL}

# Bring in backend production node_modules (pre-compiled for Alpine musl).
# Build tools from backend_deps stage are NOT included — only the output.
COPY --from=backend_deps /app/node_modules ./node_modules
COPY --from=backend_deps /app/package.json ./
COPY --from=fetch_source /ne_src/backend/src ./src
COPY --from=fetch_source /ne_src/docker/healthcheck.js ./healthcheck.js


#RUN apk add --no-cache nginx
#RUN mkdir -p /run/nginx

# Copy built frontend assets.
RUN mkdir -p src/public
COPY --from=frontend_build /app/frontend/dist/ ./src/public/

# Ensure the runtime user can read/traverse the app source tree
# (host checkouts may have restrictive umasks like 077).
RUN chmod -R a+rX /app/src

# Add rootfs
COPY rootfs/ /
RUN find /etc -type f \( -name "*.sh" -o -name "run" -o -name "finish" \) -print -exec chmod +x {} \;