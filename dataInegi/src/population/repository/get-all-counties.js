'use strict';

/**
 * getAllCounties -> Promise([<CVD_COUNTIES>])
 * generates the following query:
 * SELECT id, state_id, lng_name FROM cvd_cnty;
 */
module.exports = (conn, criteria) => conn
  .select('id', 'state_id', 'lng_nm')
  .from('cvd_cnty')
  .where(criteria);


