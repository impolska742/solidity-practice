// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// keyword - when we deploy this contract we'll be a  ble to call this function
// pure - this function is read-only
contract Function {
    function add (uint x, uint y) external pure returns (uint) {
        return x + y;
    }
    
    // returns only +ve numbers
    function sub (uint x, uint y) external pure returns (uint) {
        return x - y;
    }
}