'use strict';

const {leftPadding, isNilOrEmpty, mapIndexed } = require('./index');

const { evolve, converge, tap,
  concat, compose, pipe, prop, paths, cond,
  equals, always, T, identity, map,
  splitEvery, zipObj } = require('ramda');

const {inegiAPI} = require('../config');


/**
 * formatStateOrCounty Gives the expected format to be used as url parameter in the INEGI's indicators API
 * which is an integer left padded with zeros.
 * @param str string to be formatted
 * @returns a string padded with zeros at the begging
 */
const formatStateOrCounty = str => leftPadding(str, 4, '0');

/**
 * geoAreaFormatter Defines the format of CVD_CNTY entity by padding its county_id and the state_id 
 * @param countyEntry a record from the db especifically from the table CVD_CNTY
 * @returns Object with the id and state_id podded with zeros at the beginning
 */
const geoAreaFormatter = {
  id: formatStateOrCounty,
  state_id: formatStateOrCounty
};

 /**
 * geoAreaFormatter Applys the format of CVD_CNTY entity by padding its county_id and the state_id 
 * @param countyEntry a record from the db especifically from the table CVD_CNTY
 * @returns countyEntityFormatted with the id and state_id podded with zeros at the beginning
 */ 
const formatGeoArea = evolve(geoAreaFormatter);

/**
 * buildGeoArea concats the properties state_id and id into a single string
 * @param countyEntityFormatted 
 * @returns String value containing the state_id and the countyid
 */
const buildGeoArea = converge(concat, [prop('state_id'), prop('id')]);

/**
 * buildUrl returns a function that expect the geoArea value before to build url to call the API INEGI's indicators API
 * @param indicators String representing the indicators separated by commas
 * @param token the INEGI's API token 
 * @returns a function that expects the geoArea to generate the URL for INEGI's API
 */
const buildUrl = (indicators, token) => (geoArea) => `https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/${indicators}/es/0700${geoArea}/true/BISE/2.0/${token}`;

/**
 * getTotalPopulation returns the url to get the population from the INEGI's API
 * @param geoArea geoArea value 
 * @returns url to get the population by municipality
 */
const getTotalPopulation = buildUrl('1002000001', inegiAPI.apiKey);

const extract = compose(
  map(paths([
    ['INDICADOR'],
    ['OBSERVATIONS', 0, 'OBS_VALUE'],
    ['OBSERVATIONS', 0, 'COBER_GEO']
  ])),
  prop('Series'));



const indicatorToProp = cond([
  [equals('1002000001'), always('pop')],
  [T, identity]
]);

const geoToIds = compose(
  map(parseInt),
  splitEvery(4)
);

const transformByPosition = (val, idx) => cond([
  [equals(0), indicatorToProp],
  [equals(1), identity],
  [equals(2), geoToIds],
  [T, identity]
])(idx);

const transformEachByPosition = mapIndexed(transformByPosition);

const convert = zipObj(['indicator', 'value', 'id', 'state_id']);

const parse = pipe(
  tap(console.log),
  extract,
  tap(console.log),
  transformEachByPosition,
  tap(console.log),
  convert
);


module.exports = {
  formatStateOrCounty,
  formatGeoArea,
  buildGeoArea,
  buildUrl,
  getTotalPopulation,
  parse
};
