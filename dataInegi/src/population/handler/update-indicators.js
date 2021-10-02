'use strict';

const { ap, paths, zipObj } = require('ramda');

const updateCounty = require('../repository/update-county');

const extract = paths([
  ['INDICATOR'],
  ['OBSERVATIONS', 0, 'OBS_VALUE'],
  ['OBSERVATIONS', 0, 'COBER_GEO']
]);

const convert = zipObj(['indicator', 'value', 'geoArea']);
