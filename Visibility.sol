// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// visibility
// private - only inside contract
// internal - only outside contract and child contracts
// public - inside and outside contract
// external - only from outside contract 

/*
 ___________________
| A                |
| private pri()    |
| internal inter() | <------- C
| public pub()     |    pub() and ext()
| external ext()   |
|__________________|

 ___________________
| B is A           |
| inter()          | <------- C
| pub()            |    pub() and ext()
|__________________|

*/

contract VisibilityBase {
    uint private x = 0;
    uint internal y = 1;
    uint public z = 2;

    function privateFunction() private pure returns (uint) {
        return 0;
    }

    function internalFunction() internal pure returns (uint) {
        return 0;        
    }

    function publicFunction() public pure returns (uint) {
        return 0;
    }

    function externalFunction() external pure returns (uint) {
        return 0;        
    }

    function examples() external view {
        x + y + z;

        privateFunction();
        internalFunction();
        publicFunction();

        // We can only call external function from the contracts or account
        // that are external to the current contract.
        // externalFunction(); -> WRONG


        // For the sake of calling an external function we can use "this" keyword
        // It is a hacky trick and also gas inefficient.
        // this.externalFunction();
    }
}

contract VisibilityChild is VisibilityBase {
    function examples2() external view {
        // We cannot use "x" as it is a private variable.
        y + z;

        internalFunction();
        publicFunction();

        // Cannot access privateFunction() because it is outside the contract
        // in which it was declared.
        // privateFunction();
    }
}