'use strict';

jest.setMock('../../config', {
  db: {
  },
  inegiAPI: {
    apiKey: 'secret'
  }
});

const subject = require('../inegi-utils');

describe('inegiUtils tests', () => {

  afterAll(() => {
    jest.clearAllMocks();
  });

  test('formatStateOrCounty should return string padded with 4 zeros', () => {
    // GIVEN
    const input = '2';
    const expected = '0002';
    // WHEN
    let result = subject.formatStateOrCounty(input);
    // THEN
    expect(result).toEqual(expected);
  });

  test('formatStateOrCounty given a string longer than 4 characters it should return same string', () => {
    // GIVEN
    const input = '2222';
    // WHEN
    let result = subject.formatStateOrCounty(input);
    // THEN
    expect(result).toEqual(input);
  });

  test('formatGeoArea should transform the given object by applying function formatStateOrCounty', () => {
    // GIVEN
    const input = {id: '1', state_id:'1', lng_nm: 'Aguascalientes'};
    const expected = {id: '0001', state_id: '0001', lng_nm: 'Aguascalientes'};
    // WHEN
    let result = subject.formatGeoArea(input);
    // THEN
    expect(result).toEqual(expected);
  });

  test('buildGeoArea should concat the id and state_id of a given object', () => {
    // GIVEN
    const input = {id: '0001', state_id:'0001', lng_nm: 'Aguascalientes'};
    const expected = '00010001';
    // WHEN
    let result = subject.buildGeoArea(input);
    // THEN
    expect(result).toEqual(expected);
  });

  test('builUrl should return a function ', () => {
    // GIVEN
    const indicators = '0000000';
    const token = 'token';
   
    // WHEN
    let result = subject.buildUrl(indicators, token);
    // THEN
    expect(typeof result).toEqual('function');
  });

  test('getPopulation should return a url from the inegi API ', () => {
    // GIVEN
    const geoArea = '00010001';
    const expected = 'https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/1002000001/es/070000010001/true/BISE/2.0/secret';
    // WHEN
    let result = subject.getTotalPopulation(geoArea);
    // THEN
    expect(result).toEqual(expected);
  });

  test('parse should extract information from objects and convert into a county object ', () => {
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
    
    const expected = [{
      "geoData": {
          "cntry": 700,
          "id": 1,
          "state_id": 1
      }, 
      "indicator": "pop", 
      "value": "948990.00000000000000000000"
    }];
    
    // WHEN
    let result = subject.parse(apiResponse);
    
    // THEN
    expect(result).toEqual(expected);
  });
  
  test('parse should extract information when it receive various indicators ', () => {
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
              },
              {
                  INDICADOR: "1002000002",
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
                          OBS_VALUE: "100",
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
    
    const expected = [
      {
        "geoData": {
            "cntry": 700,
            "id": 1,
            "state_id": 1
        }, 
        "indicator": "pop", 
        "value": "948990.00000000000000000000"
      },
      {
        "geoData": {
            "cntry": 700,
            "id": 1,
            "state_id": 1
        }, 
        "indicator": "1002000002", 
        "value": "100"
      }
    ];
    
    // WHEN
    let result = subject.parse(apiResponse);
    
    // THEN
    expect(result).toEqual(expected);
  });

  test('mergeByCounty should return a list of counties given an array of transitionObjects', () => {
    // GIVEN
    const input = [
      {
        "geoData": {
            "cntry": 700,
            "id": 1,
            "state_id": 1
        }, 
        "indicator": "pop", 
        "value": "948990.00000000000000000000"
      },
      {
        "geoData": {
            "cntry": 700,
            "id": 1,
            "state_id": 1
        }, 
        "indicator": "1002000002", 
        "value": "100"
      }
    ];

    const expected = {
      id: 1,
      state_id: 1,
      pop: 948990,
      1002000002: 100
    }
    // WHEN
    let result = subject.mergeByCounty(input);
    // THEN
    expect(result).toBeDefined();
    expect(result.get('00010001')).toEqual(expected);
  });
}); 
