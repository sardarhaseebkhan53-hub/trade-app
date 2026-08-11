# AURUM API

AURUM API is a Fastify + TypeScript + PostgreSQL/Prisma backend. It owns user data, password hashing, opaque sessions, alert evaluation, notification records, backend-side integrations, and future AI/provider secrets.

## Local development

```bash
cd backend
cp .env.example .env
npm install
npm run prisma:generate
# Start PostgreSQL with Docker if available:
docker compose -f docker-compose.dev.yml up -d postgres
npm run prisma:migrate
npm run dev
```

The API listens on `http://0.0.0.0:8080` by default. Do not expose this development instance publicly and do not use production secrets in `.env`.

## Commands

```bash
npm run build
npm test
npm run prisma:deploy
```

## Security boundary

- The mobile client only receives public profile fields and opaque access/refresh tokens.
- Passwords are Argon2id hashes; plaintext passwords are never persisted.
- Raw session, device, and reset tokens are never persisted; the database stores SHA-256 token hashes.
- Provider, AI, FCM, database, and deployment secrets stay in backend environment/secret infrastructure.
- Production must terminate HTTPS before the API, configure trusted CORS origins, and run PostgreSQL migrations through controlled CI/deployment.
