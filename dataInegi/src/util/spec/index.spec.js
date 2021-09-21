'use strict';

const subject = require('../index');

describe('utils', () => {
  

  test('utils.isNillOrEmpty should return true if given input is null', () => {
    // GIVEN
    const input = null;
    // WHEN
    let result = subject.isNilOrEmpty(input);
    // THEN
    expect(result).toBe(true);
  });

  test('utils.isNillOrEmpty should return false if given input is not null', () => {
    // GIVEN
    const input = 'a';
    // WHEN
    let result = subject.isNilOrEmpty(input);
    // THEN
    expect(result).toBe(false);
  });

  test('utils.isNillOrEmpty should return true if given input is not null', () => {
    // GIVEN
    const input = '';
    // WHEN
    let result = subject.isNilOrEmpty(input);
    // THEN
    expect(result).toBe(true);
  });

  test('utils.leftPadding should add 4 characters at the beginning of the string', () => {
    // GIVEN
    const str = 'a';
    const length = 5;
    const character = '_';
    const expectedResult = '____a';
    // WHEN
    let result = subject.leftPadding(str, length, character);
    // THEN
    expect(result).toBeDefined();
    expect(result).toEqual(expectedResult);
  });
  
  test('utils.leftPadding should add 5 characters at the beginning of an empty string', () => {
    // GIVEN
    const str = '';
    const length = 5;
    const character = '_';
    const expectedResult = '_____';
    // WHEN
    let result = subject.leftPadding(str, length, character);
    // THEN
    expect(result).toBeDefined();
    expect(result).toEqual(expectedResult);
  });

  test('utils.leftPadding should return a 5 character string when parameter is null', () => {
    // GIVEN
    const str = null;
    const length = 5;
    const character = '_';
    const expectedResult = '_____';
    // WHEN
    let result = subject.leftPadding(str, length, character);
    // THEN
    expect(result).toBeDefined();
    expect(result).toEqual(expectedResult);
  });
});
