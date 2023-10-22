// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {  
        uint256 entranceFee;
        uint256 duration;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address link;
        uint256 deployerKey;
    }

    uint256 public constant DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 1) {
            activeNetworkConfig = getMainnetConfig();
        } else if (block.chainid == 5) {
            activeNetworkConfig = getGoerliConfig();
        } else if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getMainnetConfig() public view returns (NetworkConfig memory) {
        NetworkConfig memory networkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            duration: 30, // 30 seconds
            vrfCoordinator : 0x271682DEB8C4E0901D1a1550aD2e64D568E69909,
            gasLane: 0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef,
            subscriptionId: 0, // TODO: update with our subscription id with script
            callbackGasLimit: 500_000,
            link: 0x514910771AF9Ca656af840dff83E8264EcF986CA,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
        return networkConfig;
    }

    function getGoerliConfig() public view returns (NetworkConfig memory) {
        NetworkConfig memory networkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            duration: 30, // 30 seconds
            vrfCoordinator : 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D,
            gasLane: 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15,
            subscriptionId: 14975, // TODO: update with our subscription id with script
            callbackGasLimit: 500_000,
            link: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
        return networkConfig;
    }

    function getSepoliaConfig() public view returns (NetworkConfig memory) {
        NetworkConfig memory networkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            duration: 30, // 30 seconds
            vrfCoordinator : 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 6091, 
            callbackGasLimit: 500_000,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
        return networkConfig;
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if(activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        uint96 baseFee = 0.25 ether; // 0.25 LINK
        uint96 gasPriceLink = 1e9; // 1 gwei LINK

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(baseFee,gasPriceLink);
        vm.stopBroadcast();

        LinkToken link = new LinkToken();

        NetworkConfig memory networkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            duration: 30, // 30 seconds
            vrfCoordinator : address(vrfCoordinatorV2Mock),
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0, // TODO: update with our subscription id with script
            callbackGasLimit: 500_000,
            link: address(link),
            deployerKey: DEFAULT_ANVIL_KEY
        });
        return networkConfig;
    }
}

