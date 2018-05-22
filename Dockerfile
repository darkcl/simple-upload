FROM node:8-slim

WORKDIR /server

COPY . /server
RUN npm install && npm run postinstall

EXPOSE 3000
CMD [ "npm", "start" ]