# Demo service: Express + a localhost-only MongoDB instance.
# Storage is ephemeral inside Code Engine; use a persistent DB for production.
FROM node:20-bullseye-slim AS node-runtime

FROM mongo:7.0
COPY --from=node-runtime /usr/local/bin/node /usr/local/bin/node
COPY --from=node-runtime /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && node --version && npm --version
WORKDIR /srv/dealership-api
COPY package*.json ./
RUN npm install --omit=dev --no-audit --no-fund
COPY app.js dealership.js review.js ./
COPY data/ ./data/
ENV PORT=3030
ENV MONGODB_URI=mongodb://127.0.0.1:27017/
EXPOSE 3030
ENTRYPOINT []
CMD ["/bin/sh", "-c", "mkdir -p /tmp/bestcars-mongodb && mongod --dbpath /tmp/bestcars-mongodb --bind_ip 127.0.0.1 --port 27017 --logpath /tmp/bestcars-mongod.log --fork && exec node app.js"]
