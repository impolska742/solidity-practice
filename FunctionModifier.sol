// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Function modifiers - reuse code before and/or after function
// Basic, inputs, sandwich

contract FunctionModifier {
    bool public paused;
    uint public count;

    function setPause(bool _pause) external {
        paused = _pause;
    }

    modifier whenNotPaused() {
        require(!paused, "paused");
        _;
    }

    function inc() external whenNotPaused {
        count += 1;
    }

    function dec() external whenNotPaused {
        count -= 1;
    }

    modifier capBy100(uint _x) {
        require(_x <= 100, "x > 100");
        _;
    }

    function incBy(uint _x) external whenNotPaused capBy100(_x){
        count += _x;
    }

    modifier sandwich() {
        // Code

        count += 10;
        _x;

        // More Code here
        count *= 2;
    }
}