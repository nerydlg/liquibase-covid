'use strict';

const winston = require('winston');
const {tap} = require('ramda');
const logger = winston.createLogger({
  level: 'debug',
  format: winston.format.json(),
  defaultMeta: {service: 'user-service'},
  transports: [
    new winston.transports.File({filename: 'inegi-importer-err.log', level: 'error'}),
    new winston.transports.File({filename: 'inegi-importer.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

module.exports = {
  info: tap(msg => logger.info),
  error: tap(msg => logger.error)
};

