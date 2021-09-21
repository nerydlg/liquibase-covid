'use strict';

const { pipe } = require('ramda');
const callApiAndUpdate = require('./handler/update-county');
const getAllCounties = require('./repository/get-all-counties');
const dbConnection = require('../util/pg-connection');

/**
 * fillPopulationByMunicipality -> void
 * performs a call to INEGI API to get the population 
 * by each county and then updates its value
 */
const fillPopulationByMunicipality = pipe(
  dbConnection,
  getAllCounties,
  callApiAndUpdate
);

module.exports = fillPopulationByMunicipality;
