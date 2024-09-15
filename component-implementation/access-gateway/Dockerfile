FROM node:20.17-alpine3.20 AS builder

# WORKDIR /usr/src/app

# COPY package*.json ./
# COPY nx.json ./
# COPY tsconfig.base.json ./
# COPY workspace.json ./

# RUN npm install

# COPY ../../../ .

# RUN npx nx build api-gateway-configurator

# FROM node:20.17-alpine3.20

# WORKDIR /usr/src/app

# COPY --from=builder /usr/src/app/dist ./dist
# COPY --from=builder /usr/src/app/package.json ./package.json
# COPY --from=builder /usr/src/app/package-lock.json ./package-lock.json

# RUN npm install --production

# EXPOSE 3000

# ENV TZ=Europe/Madrid

# CMD ["node", "dist/apps/api-gateway-configurator"]
