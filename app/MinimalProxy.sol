// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/**
 * Minimal proxy contract (create_forwarder_to in Vyper)
 *
 * - Why is it cheap to deploy contract? - it uses delegatecall
 * - Why is the constructor not called? - it uses delegatecall
 * - Why is the original contract not affected? - it uses delegatecall
 *
 * What is delegatecall?
 *
 *`
 */

contract MinimalProxy {
    address masterCopy;

    constructor(address _masterCopy) {
        masterCopy = _masterCopy;
    }

    function forward() external returns (bytes memory) {
        (bool success, bytes memory data) = masterCopy.delegatecall(msg.data);
        require(success);
        return data;
    }
}
