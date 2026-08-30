# ── Stage 1: install dependencies ────────────────────────────────────────
# Node 22.6+ required: Next.js 16.3's Turbopack filesystem cache uses node:sqlite
FROM node:22-alpine AS deps
WORKDIR /app

RUN corepack enable

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# ── Stage 2: build ────────────────────────────────────────────────────────
FROM node:22-alpine AS builder
WORKDIR /app

RUN corepack enable

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build-time env vars (resolved by Next.js at compile time)
ARG NEXT_BASE_PATH
ARG NEXT_PUBLIC_BASE_PATH
ENV NEXT_BASE_PATH=$NEXT_BASE_PATH
ENV NEXT_PUBLIC_BASE_PATH=$NEXT_PUBLIC_BASE_PATH

RUN pnpm build

# ── Stage 3: lean production image ───────────────────────────────────────
FROM node:22-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Pick up Alpine security patches (e.g. openssl) released since this
# base image tag was last built.
RUN apk update && apk upgrade --no-cache

# The standalone server needs no package manager at runtime, and this
# project only ever uses pnpm — drop the bundled npm CLI so its own
# dependency CVEs (pacote, sigstore, etc.) aren't shipped in the image.
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx

# Non-root user for security
RUN addgroup --system --gid 1001 nodejs \
 && adduser  --system --uid 1001 nextjs

# Copy the standalone server output
COPY --from=builder /app/.next/standalone ./
# Static assets must live alongside the standalone server
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# next.js standalone produces a self-contained server.js
CMD ["node", "server.js"]
