// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract DefaultValues {
	uint public u; // 0
	int public i; // 0
	bool public b; // false
	address public a;    // 0x0000000000000000000000000000000000000000
						 // 40 times zero
	bytes32 public b32;  // 0x0000000000000000000000000000000000000000000000000000000000000000
						 // 64 times zero

	// mapping, structs, enums, fixed sized arrays						 
}