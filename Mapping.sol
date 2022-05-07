// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Dictionary in python
// Map, Unordered Map in C++
// Set, Get, delete

// ["alice", "bob", "charlie"]
// {
//  "alice" : true,
//  "bob" : true,
//  "charlie" : true,
// }

contract Mapping {
    // Syntax : mapping(key => value)
    mapping(address => uint) public balances;
    
    // Nested mapping
    mapping(address => mapping(address => bool)) public isFriend;
    
    function example() external {
        balances[msg.sender] = 123;
        uint bal = balances[msg.sender];
        uint bal1 = balances[address(1)]; // return 0 (default value of uint)

        balances[msg.sender] += 456;

        delete balances[msg.sender];

        isFriend[msg.sender][address(this)] = true;
    }
}