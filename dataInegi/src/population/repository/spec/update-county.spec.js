'use strict';

const knex = require('knex');
const mockDb = require('mock-knex');
const db = knex({
  client: 'pg'
});
let tracker = mockDb.getTracker();
let subject = require('../update-county');

describe('update-county', () => {

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

  test('update county should execute an update statement in the db', () => {
    // GIVEN
    const expectedQuery = 'update \"cvd_cnty\" set \"pop\" = $1 where \"id\" = $2 and \"state_id\" = $3';
    const expectedResponse = [];
    const obj = {id: 1, state_id: 1, pop: 3000};
    tracker.on('query', (query) => {
      expect(query.sql).toEqual(expectedQuery);
      query.response(expectedResponse);
    });
    // WHEN
    return subject(db, obj)
      .then(response => {
        // THEN
        expect(response).toBeDefined();
        expect(response).toEqual(expectedResponse);
      });
  });
});
