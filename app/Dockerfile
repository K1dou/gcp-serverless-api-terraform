# Imagem da API para o Cloud Run.

FROM node:24-bookworm-slim

# O schema engine do Prisma precisa de openssl.
RUN apt-get update \
 && apt-get install -y --no-install-recommends openssl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev


COPY . .
RUN DATABASE_URL="postgresql://build:build@localhost:5432/build" npx prisma generate

ENV PORT=8080
EXPOSE 8080

RUN chown -R node:node /app
USER node

CMD ["node_modules/.bin/tsx", "src/server.js"]
