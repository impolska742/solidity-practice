// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Constructor - special functions that are only called once when the contract is deployed

contract Constructor {
    address public owner;
    uint public x;

    constructor(uint _x) {
        owner = msg.sender;
        x = _x;
    }
}