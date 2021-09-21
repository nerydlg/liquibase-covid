'use strict';

const { addIndex, anyPass, isNil, isEmpty, map } = require('ramda');

/**
 * isNilOrEmpty validates if a argument is null, undefined, empty or empty, If the argument matches both cases
 * then this method will returns true, otherwise false
 * @param subject a variable of any type
 * @returns boolean wich indicates if subject is null or empty
 */
const isNilOrEmpty = anyPass([isNil, isEmpty]);

/**
 * leftPadding adds the indicated character at the beginning of the string if the string is smaller than indicated length.
 * if string is null or empty is will return a string of size length filled with given characeter.
 * @param str string to be padded 
 * @param length size of the expected string after padding
 * @param character character used to fill the string
 * @returns a new string with the expected size.
 */
const leftPadding = (str, length, character) => isNilOrEmpty(str) ? ''.padStart(length, character) : str.padStart(length, character);


const mapIndexed = addIndex(map);

module.exports = {
  isNilOrEmpty,
  leftPadding,
  mapIndexed
};
