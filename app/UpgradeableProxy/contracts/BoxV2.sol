// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

contract BoxV2 {
    uint public val;

    // constructor(uint _val) {
    //     val = _val;
    // }

    // function initialize(uint _val) external {
    //     val = _val;
    // }

    function increment() external {
        val += 1;
    }
}
