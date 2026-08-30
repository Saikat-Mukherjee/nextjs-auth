# Next.js JWT Auth

A cookie-based JWT authentication starter built on the Next.js App Router, with MongoDB (Mongoose) for user storage, bcrypt password hashing, and route protection via middleware.

## Features

- Sign up, log in, and log out with hashed passwords (`bcryptjs`)
- Stateless auth using a signed JWT stored in an HTTP-only `token` cookie
- Route protection in [`src/middleware.ts`](src/middleware.ts) — redirects signed-out users away from `/profile`, and signed-in users away from `/login` and `/signup`
- `/api/users/me` resolves the current user from the JWT via [`src/helpers/getTokenData.ts`](src/helpers/getTokenData.ts)
- MongoDB connection managed in [`src/dbConfig/dbConfig.ts`](src/dbConfig/dbConfig.ts)

## Tech Stack

- [Next.js 16](https://nextjs.org) (App Router, Turbopack)
- [React 19](https://react.dev)
- [MongoDB](https://www.mongodb.com) via [Mongoose](https://mongoosejs.com)
- [jsonwebtoken](https://github.com/auth0/node-jsonwebtoken) + [bcryptjs](https://github.com/dcodeIO/bcrypt.js)
- [Tailwind CSS](https://tailwindcss.com)
- [TypeScript](https://www.typescriptlang.org)

## Getting Started

This project uses [pnpm](https://pnpm.io).

### 1. Install dependencies

```bash
pnpm install
```

### 2. Configure environment variables

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

| Variable                | Description                                                      |
| ------------------------ | ------------------------------------------------------------------ |
| `MONGO_URI`             | MongoDB connection string                                         |
| `TOKEN_SECRET`          | Secret used to sign JWTs — generate one with `openssl rand -hex 32` |
| `NEXT_BASE_PATH`        | Base path to serve the app under (leave empty to host at `/`)      |
| `NEXT_PUBLIC_BASE_PATH` | Same as above, exposed to the client                              |

### 3. Run the dev server

```bash
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) to see the app.

## Scripts

| Command      | Description                          |
| ------------ | ------------------------------------- |
| `pnpm dev`   | Start the dev server with hot reload  |
| `pnpm build` | Create a production build             |
| `pnpm start` | Run the production build              |
| `pnpm lint`  | Run ESLint over the project           |

## Project Structure

```
src/
├── app/
│   ├── api/users/       # signup, login, logout, me route handlers
│   ├── login/           # login page
│   ├── signup/          # signup page
│   └── profile/         # protected profile page
├── dbConfig/            # MongoDB connection
├── helpers/             # JWT verification helpers
├── models/               # Mongoose user model
└── middleware.ts         # route protection
```

## Deployment

The app is set up for containerized deployment:

- **Dockerfile** — multi-stage build producing a lean, non-root production image using Next.js's [standalone output](https://nextjs.org/docs/app/api-reference/config/next-config-js/output)
- **docker-compose.yml** — runs the built image, wiring up the environment variables above
- **`.github/workflows/deploy.yml`** — on every push to `main`, CI builds the Docker image to validate it, then deploys over SSH to a VPS by pulling the latest code and running `docker compose up -d --build`

To deploy your own copy, set these repository secrets: `NEXT_BASE_PATH`, `VPS_HOST`, `VPS_USER`, `VPS_PASSWORD`, `VPS_PORT`, `VPS_APP_DIR`, plus `MONGO_URI` and `TOKEN_SECRET` in a `.env` file on the VPS (read by `docker-compose.yml`).

To run it locally with Docker instead:

```bash
docker compose up --build
```

## Learn More

- [Next.js Documentation](https://nextjs.org/docs)
- [Mongoose Documentation](https://mongoosejs.com/docs/)
