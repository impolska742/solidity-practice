// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract StateVariable {
    uint public state_variable = 123;
    function foo() external pure returns (uint) {
        uint local_variable = 456;
        return local_variable;
    }

    function bar() external pure{
        uint local_variable = 456;
        bool f = false;
        // more code;
        local_variable += 123;
        f = true;
    }
}