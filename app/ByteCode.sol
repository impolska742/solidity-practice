// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Factory {
    address bytecodeContractAddress;

    // Deploys a contract that always returns 42
    function deploy() external {
        bytes memory bytecode = hex"69602a60005260206000f3600052600a6016f3";
        address addr;
        assembly {
            // create(value, offset, size)
            addr := create(0, add(bytecode, 0x20), 0x13)
        }
        require(addr != address(0));

        bytecodeContractAddress = addr;
    }
}

interface IContract {
    function getMeaningOfLife() external view returns (uint);
}

/**
 * Runtime code
 * Creation code
 * Factory contract
 *
 * We will write a contract, 'A',  in assembly which will always return the number 42.
 *
 * Then we would write a factory contract, 'Factory', which will deploy the contract 'A'
 */

/**
 * 1. Runtime code
 *
 * Store 42 on memory
 * mstore(p, v) - store v at memory p to p + 32
 *
 * PUSH1 0x2a (42 in hexadecimal)
 * PUSH1 0
 * MSTORE
 *
 * return(p, s) - end execution and return data from memory p to p + s
 *
 * Return 32 bytes of memory
 * PUSH1 0x20
 * PUSH1 0
 * RETURN
 *
 * opcodes to bytecodes
 * PUSH1 - 60
 * MSTORE - 52
 *
 * total runtime bytecode - 602a60005260206000F3
 *
 * 2. Creation code
 *
 * Store the runtime code to memory
 *
 * PUSH10 602a60005260206000F3
 * PUSH1 0
 * MSTORE
 *
 * Return 10 bytes from memory starting at the offset of 22
 *
 * PUSH1 0x0a
 * PUSH1 0x16
 * RETURN
 *
 * total creation bytecode - 69602a60005260206000f3600052600a6016f3
 */
