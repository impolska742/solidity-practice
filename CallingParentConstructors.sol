// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 2 ways to call parent constructors
// Order of initialization

contract S {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

contract T {
    string public text;

    constructor(string memory _text) {
        text = _text;
    }
}

contract U is S("s"), T("t") {
    // code
}

contract V is S, T {
    constructor(string memory _name, string memory _text) S(_name) T(_text) {
        // code
    }
}

contract VV is S("s"), T {
    constructor(string memory _text) T(_text) {
        // code
    }
}

// Order of execution - depends on the order of inheritance, not on the order
//                      in which they are called
// 1. S
// 2. T
// 3. V0
contract V0 is S, T {
    constructor(string memory _name, string memory _text) T(_text) S(_name) {
        // code
    }
}

// Order of execution
// 1. S
// 2. T
// 3. V1
contract V1 is S, T {
    constructor(string memory _name, string memory _text) S(_name) T(_text){
        // code
    }
}

// Order of execution
// 1. T
// 2. S
// 3. V1
contract V2 is T, S {
    constructor(string memory _name, string memory _text) S(_name) T(_text){
        // code
    }
}

// Order of execution
// 1. T
// 2. S
// 3. V1
contract V3 is T, S {
    constructor(string memory _name, string memory _text) T(_text) S(_name){
        // code
    }
}
