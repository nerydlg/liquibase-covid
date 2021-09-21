'use strict';

const knex = require('knex');
const mockDb = require('mock-knex');
const db = knex({
  client: 'pg'
});
let tracker = mockDb.getTracker();
let subject = require('../get-all-counties');

describe('get-all-counties', () => {

  // setup 
  beforeAll(() => {
    mockDb.mock(db);
    tracker.install();
  }); 

  // clear modules
  afterAll(() => {
    jest.clearAllMocks();
    jest.resetModules();
    tracker.uninstall();
  });


  test('getAllCounties should execute query on db', () => {
    // GIVEN
    const expectedQuery = 'select \"id\", \"state_id\", \"lng_nm\" from \"cvd_cnty\" where \"id\" = $1';
    const expectedResponse = [{id: '1', state_id: '1', lng_nm: 'Aguascalientes'}];
    const criteria = {id: 1};
    tracker.on('query', (query) => {
      expect(query.sql).toEqual(expectedQuery);
      query.response(expectedResponse);
    });
    // WHEN
    return subject(db, criteria)
      .then(response => {
        // THEN
        expect(response).toBeDefined();
        expect(response).toEqual(expectedResponse);
      });
    
  });
});
