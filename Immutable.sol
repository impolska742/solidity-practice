// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Immutable {
    address public immutable owner;

    // "immutable" variables will be set only once, when the contract is deployed.
    // They will never change.
    // Gas efficient.

    // They are like constants but they can only be initialised when
    // the contract is deployed.

    uint public x;

    constructor () {
        owner = msg.sender;
    }

    // immutable - 50123 gas
    // not immutable - 52576 gas

    function foo() external {
        require(msg.sender == owner, "Not Owner");
        x += 1;
    }
}