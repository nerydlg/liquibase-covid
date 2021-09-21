'use strict';

const request = require('superagent');

/**
 * apiCall performs a get call to a given URL 
 * @param url the url to be called.
 * @returns promise with the response of the call.
 */
module.exports = (url) => request
  .get(url)
  .query({type: 'json'})
  .set('Content-Type', 'application/json')
  .set('Accept', 'application/json')
  .set('User-Agent', 'superagent, NodeJS')
  .catch(error => {
    console.error("There was a problem trying to reach url", error);
  });

