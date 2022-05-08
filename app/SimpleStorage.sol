// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// A simple storage app using data locations 

contract SimpleStorage {
    string public text;

    // aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    // calldata - 102891  gas
    // memory - 103452  gas
    function set(string memory _text) external {
        text = _text;
    }

    function get() external view returns (string memory) {
        return text;
    }
}