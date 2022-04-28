// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Data Types - values and references
contract ValueTypes {
    bool public b = true;
    string public s = "Yo";
    uint public u = 1321; // uint = uint256 0 to 2^256 - 1
    uint8 public u8 = 13; //       uint8 0 to 2^8 - 1 
    int public i = 131; // int256 -> (-) 2^255 to (+) 2^225 - 1
                        // int128 -> (-) 2^127 to (+) 2^127 - 1
    int public minInt = type(int8).min;
    int public maxInt = type(int8).max;
    address public addr = 0x277b0ceE2Ac5D2c046c753776013A810dE20D703;
    bytes32 public b32 = 0xc8ff3c895df6da36dfc9c132526f6114be45f54ba50007aeb447c07dc9cfc831;
}