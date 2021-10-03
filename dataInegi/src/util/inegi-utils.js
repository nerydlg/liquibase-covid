'use strict';

const {leftPadding, isNilOrEmpty, mapIndexed } = require('./index');

const {
  assoc,
  evolve, 
  converge, 
  tap,
  concat, 
  compose, 
  pipe, 
  prop,
  path,
  paths, 
  cond,
  equals, 
  always, 
  T, 
  identity, 
  map,
  splitEvery,
  reduce,
  whereEq,
  zipObj } = require('ramda');

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

/**
 * extract get information from the property called Series
 * returns an array with the extracted values
 * @param object form the INEGI API
 * @returns [] with the values of 'indicator', 'OBS_VALUE' and 'COBER_GEO'
 */
const extract = compose(
  map(paths([
    ['INDICADOR'],
    ['OBSERVATIONS', 0, 'OBS_VALUE'],
    ['OBSERVATIONS', 0, 'COBER_GEO']
  ])),
  prop('Series'));

/**
 * indicatorToProp reads the indicator and gives it a value
 * @param object {value: 'string'}
 * @returns the property name or by default it returs the indicator value
 */
const indicatorToProp = cond([
  [whereEq({value: '1002000001'}), always('pop')],
  [T, prop('value')]
]);

/**
 * geoToIds converts to a geoData object which contains the value for 
 * state_id and municipality
 * @param String COBER_GEO value which contains the state and municipality id
 */
const geoToIds = compose(
  zipObj(['cntry', 'state_id', 'id']),
  map(parseInt),
  splitEvery(4),
  prop('value')
);

/**
 * transform each value depending on their position
 * @param Array of values 
 * @return Array with the transformed values
 */
const transformByPosition = cond([
  [whereEq({idx: 0}), indicatorToProp],
  [whereEq({idx: 1}), prop('value')],
  [whereEq({idx: 2}), geoToIds],
  [T, identity]
]);

/**
 * converts from single value or object to an object with the index 
 * @param obj value or object 
 * @param idx integer reprecenting index value
 * @returns an object containing value and index
 */
const addIndexToObj = (obj, idx) => ({idx: idx, value: obj});

const transformEachByPosition = pipe(
  mapIndexed(addIndexToObj),
  map(transformByPosition)
);

const convert = zipObj(['indicator', 'value', 'geoData']);

/**
 * extracts data from the INEGI reponse and converts value into an easy to handle object 
 * @param response JSON value containing the reponse from the inegi API
 * @returns transitionObject {indicator: <String>, value:<numeric>, geoData: { id: <integer>, state_id: <integer>, country: <integer>} }
 */
const parse = pipe(
  extract,
  map(transformEachByPosition),
  map(convert)
);

const groupByGeoData = (acc, curr) => {
  const buildKey = compose(
     buildGeoArea,
     formatGeoArea,
     prop('geoData')
   );
  let key = buildKey(curr);
  let obj = acc.get(key) || {
    id: curr.geoData.id,
    state_id: curr.geoData.state_id
  };
  let pair = paths([['indicator'], ['value'] ], curr);
  acc.set(key, assoc(pair[0], parseInt(pair[1]), obj));
   return acc;
};

/**
 * convert from transitionObject into a county database entity with all the indicators
 * @param transitionObject 
 * @param cntyEntity 
 */
const mergeByCounty = reduce(groupByGeoData, new Map());

module.exports = {
  formatStateOrCounty,
  formatGeoArea,
  buildGeoArea,
  buildUrl,
  getTotalPopulation,
  mergeByCounty,
  parse
};
