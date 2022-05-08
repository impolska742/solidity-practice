// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Order of Inheritance - most base like to derived

/*
Example. 1
    X
  / |   X does not inherit anyone
 Y  |   Z inherits from Both X and Y
  \ |   Y inherits from X
    Z
*/

// Order of most base like to derived contract in this case is
// X -> Y -> Z

/*
Example. 2;

    X
  /   \      X does not inherit from anyone
 Y     A     Y and A inherit from X
 |     |     B inherits from A
 |     B     Z inherits from Y and B
  \   /
    Z
*/

// Order of most base like to derived contract in this case is
// X -> (Y = A) -> B -> Z

contract X {
    function foo() public pure virtual returns (string memory) {
        return "X";
    }

    function bar() public pure virtual returns (string memory) {
        return "X";
    }

    function x() public pure returns (string memory) {
        return "X";
    }
}

contract Y is X {
    function foo() public pure virtual override returns (string memory) {
        return "Y";
    }

    function bar() public pure virtual override returns (string memory) {
        return "Y";
    }
    
    function y() public pure returns (string memory) {
        return "Y";
    }
}

contract Z is X, Y {
    function foo() public pure override(X, Y) returns (string memory) {
        return "Y";
    }

    function bar() public pure override(X, Y) returns (string memory) {
        return "Y";
    }
}