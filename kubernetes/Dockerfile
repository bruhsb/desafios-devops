FROM node:9-alpine
WORKDIR /src
COPY app/ .
RUN npm install --quiet
EXPOSE 3000
USER 1000
CMD ["npm", "start"]
