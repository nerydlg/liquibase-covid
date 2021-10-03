'use strict';

const {parse, mergeByCounty} = require('../../util/inegi-utils');
const updateCounty = require('../repository/update-county');
const {pipe, values, map} = require('ramda');
const logger = require('../../util/logger');

module.exports = pipe(
  parse,
  logger.info,
  mergeByCounty,
  values,
  map(updateCounty)
);

