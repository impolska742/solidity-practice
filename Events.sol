// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 1. Events allow you to write data on the blockchain
// 2. These data cannot ever be retrieved by a smart contract
// 3. The main purpose of "events" is to log what all has happened.
// 4. So it can be a cheap alternative of storing the data as a state variable
// 5. If the data that you're going to store is is something that you want to 
//    save on the blockchain once and later on the Smart Contract does not have to 
//    retrieve it.

contract Event {
    event Log(string message, uint val);

    // Up to 3 parameteres can be indexed.
    event IndexedLog(address indexed sender, uint val);

    function example() external {
        emit Log("foo", 123);
        emit IndexedLog(msg.sender, 456);
    }

    event Message(address indexed _from, address indexed _to, string message);

    function sendMessage(address _to, string calldata _message) external {
        emit Message(msg.sender, _to, _message);
    }
}