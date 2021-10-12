'use strict';

// const mockedUpdateCounty =  jest.fn().mockReturnValue(Promise.resolve([]));
// jest.setMock('../../repository/update-county', mockedUpdateCounty);
const subject = require('../update-indicators');

describe('update indicator', () => {

  test('updateIndicator should extract information from api call response and update the db', () => {
    // GIVEN
    const apiResponse = {
          Header: {
              Name: "Datos compactos BISE",
              Email: "atencion.usuarios@inegi.org.mx"
          },
          Series: [
              {
                  INDICADOR: "1002000001",
                  FREQ: "7",
                  TOPIC: "123",
                  UNIT: "96",
                  UNIT_MULT: "",
                  NOTE: "1398",
                  SOURCE: "2,3,343,487,1714,3001,20101",
                  LASTUPDATE: null,
                  STATUS: "3",
                  OBSERVATIONS: [
                      {
                          TIME_PERIOD: "2020",
                          OBS_VALUE: "948990.00000000000000000000",
                          OBS_EXCEPTION: null,
                          OBS_STATUS: "3",
                          OBS_SOURCE: "",
                          OBS_NOTE: "",
                          COBER_GEO: "070000010001"
                      }
                  ]
              }
          ]
      };

    // WHEN
    let result = subject(apiResponse);
    // THEN
    expect(result).toBeDefined();
    //console.log(result);
    //expect(mockedUpdateCounty).toHaveBeenCalled();
  });

});
