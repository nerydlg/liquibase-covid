'use strict';

const knex = (config) => require('knex')({
  client: 'pg',
  connection: {
    host: config.db.host,
    port: config.db.port,
    user: config.db.user,
    password: config.db.password,
    database: config.db.database
  }
});

module.exports = knex;
