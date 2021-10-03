'use strict';

const { tap, pipe } = require('ramda');
const callAPI = require('../../util/api-call');
const logger = require('../../util/logger');
const {
  formatGeoArea,
  buildGeoArea,
  getTotalPopulation
} = require('../../util/inegi-utils');
const updateIndicators = require('./update-indicators');

/**
 * updateCounty execute a series of steps to download information 
 * from the INEGI's API and then update the information of a specific 
 * municipality
 * @param countyEntry a record from the db especifically from the table CVD_CNTY
 */
module.exports = pipe(
  formatGeoArea,
  buildGeoArea,
  getTotalPopulation,
  logger.info,
  callAPI,
  logger.info,
  updateIndicators
);

