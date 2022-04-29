// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// There are three ways we can throw an Error
// 1. Require
// 2. Revert
// 3. Assert
// - gas refund, state updates are reverted
// - custom errors to save gas

contract Error {
    function testRequire(uint _i) public pure {
        require(_i <= 10, "i > 10"); 
        // code
    }

    function testRevert(uint _i) public pure {
        if(_i > 1) {
            // code
            if(_i > 2) {
                // more code
                if(_i > 10) {
                    revert("i > 10");
                }
            }
        }

        if(_i > 10) {
            revert("i > 10"); 
        }

        // code
    }

    uint public num = 123;

    function testAssert(uint _i) public view {
        assert(num == 123);
    }       

    function foo(uint _i) public {
        // accidently updated num
        num += 1;
        require(_i < 10);
    }

    error MyError(address caller, uint i);

    function testCustomError(uint _i) public view {
        // code
        if(_i > 10) {
            revert MyError(msg.sender, _i);
        }
    }
}