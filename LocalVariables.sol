// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract LocalVariable {
    uint public i;
    bool public j;
    address public myAddress;

    // local variables exist only while the function is executed and 
    // destroyed after the function is done

    function foo () external {
        uint x = 132;
        bool f = false;
        //  more code 
        x += 456;  
        f = true;

        i = 123;
        j = true;
        myAddress = address(1);
    }
}