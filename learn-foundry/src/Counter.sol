// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;

    string public str;

    function setNumber(uint256 newNumber, string memory _str) public {
        // int a = 10;
        // int a = new Integer(19);
        number = newNumber;
        str = _str;
    }

    function increment() public {
        number++;
    }
}
