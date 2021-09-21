'use strict';

module.exports = (conn, cntyEntry) => conn('cvd_cnty')
  .where({
    id: cntyEntry.id,
    state_id: cntyEntry.state_id
  })
  .update({pop: cntyEntry.pop});
