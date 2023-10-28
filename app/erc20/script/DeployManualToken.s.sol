// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script} from "forge-std/Script.sol";
import {ManualToken} from "../src/ManualToken.sol";

contract DeployManualToken is Script {
    uint256 constant public STARTING_BALANCE = 100 ether;

    function run() external returns (ManualToken) {
        vm.startBroadcast();
        ManualToken manualToken = new ManualToken(STARTING_BALANCE);
        vm.stopBroadcast();

        return manualToken;
    }
}