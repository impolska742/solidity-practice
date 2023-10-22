// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription} from "./Interactions.s.sol";
import {FundSubscription} from "./Interactions.s.sol";
import {AddConsumer} from "./Interactions.s.sol";
import {console} from "forge-std/console.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig, uint64) {
        HelperConfig helperConfig = new HelperConfig();
        
        (
            uint256 entranceFee,
            uint256 duration,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        // If we don't have a subscription
        if(subscriptionId == 0) {
            // Create a subscription
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(vrfCoordinator, deployerKey);

            // Fund Subscription
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(vrfCoordinator, subscriptionId, link, deployerKey);
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(entranceFee, duration, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit);
        console.log("DeployRaffle -> Raffle Balance : ", address(raffle).balance);
        vm.stopBroadcast();

        // Add consumer
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(address(raffle), vrfCoordinator, subscriptionId, deployerKey);

        return (raffle, helperConfig, subscriptionId);
    }
}