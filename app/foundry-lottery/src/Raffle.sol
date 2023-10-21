// Layout of Contract:-
// Pragma statements - version
// Imports
// Errors
// Interfaces
// Libraries
// Contracts
// Type declarations
// State Variables
// Events
// Modifiers
// Functions

// Layout of Functions:-
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

/**
 * @title Lottery Contract
 * @author @impolska742
 * @notice This contract is for creating sample raffle
 * @dev Implements Chainlink VRFv2
 */
contract Raffle is VRFConsumerBaseV2, AutomationCompatibleInterface {
    /** Errors */
    error Raffle__InsufficientEthSent();
    error Raffle__RaffleIsNotOpen();
    error Raffle__PrizeTransferFailed();
    error Raffle__UpkeepNotNeeded(
        uint256 currentBalance,
        uint256 numPlayers,
        RaffleState raffleState
    );

    /** Type Declarations */
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /** State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUMBER_OF_RANDOM_NUMBERS = 1;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_duration;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint256 private s_lastTimestamp;
    address payable[] private s_players;
    address payable private s_recentWinner;
    RaffleState private s_raffleState;

    /** Events */
    event Raffle__EnteredRaffle(address indexed player);
    event Raffle__PickedWinner(address indexed winner);
    event Raffle__RequestedRaffleWinner(uint256 indexed requestId);

    constructor(
        uint256 entranceFee,
        uint256 duration,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_duration = duration;
        i_gasLane = gasLane;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_lastTimestamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__InsufficientEthSent();
        }

        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleIsNotOpen();
        }

        s_players.push(payable(msg.sender));

        emit Raffle__EnteredRaffle(msg.sender);
    }

    /**
     * @dev This is a function that Chainlink Automation nodes call
     * to see if it's time to perform an upkeep.
     * The following should be true for this to return true:
     * 1. The time interval has passed between the raffle runs
     * 2. The is in the OPEN state
     * 3. The contract has ETH (aka players)
     * 4. (Implicit) The subscription is funded with LINK
     */
    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        // check to see if enough time has passed
        bool timeHasPassed = (block.timestamp - s_lastTimestamp >= i_duration);
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;

        upkeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayers;

        return (upkeepNeeded, "0x0");
    }

    // Previous Name - pickWinner()
    // 1. Get a random number
    // 2. Use the random number to pick a player
    // 3. Be automatically called
    /**
     * @dev Once `checkUpkeep` is returning `true`, this function is called
     * and it kicks off a Chainlink VRF call to get a random winner.
     */
    function performUpkeep(bytes calldata /* performData */) external {
        (bool upkeepNeeded, ) = checkUpkeep("0x0");

        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                s_raffleState
            );
        }

        s_raffleState = RaffleState.CALCULATING;

        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, // gas
            i_subscriptionId, // id of subscription
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUMBER_OF_RANDOM_NUMBERS // number of random numbers
        );

        emit Raffle__RequestedRaffleWinner(requestId);
    }

    // CEI: Checks, Effects, Interactions
    function fulfillRandomWords(
        uint256 /* _requestId */,
        uint256[] memory _randomWords
    ) internal override {
        // Checks
        uint256 indexOfWinner = _randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];

        // Effects
        s_recentWinner = winner;
        s_players = new address payable[](0);
        s_raffleState = RaffleState.OPEN;
        s_lastTimestamp = block.timestamp;
        emit Raffle__PickedWinner(winner);

        // Interactions
        (bool success, ) = s_recentWinner.call{value: address(this).balance}(
            ""
        );

        if (!success) {
            revert Raffle__PrizeTransferFailed();
        }
    }

    /** Getter Functions */

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getDuration() external view returns (uint256) {
        return i_duration;
    }

    function getSubscriptionId() external view returns (uint64) {
        return i_subscriptionId;
    }

    function getCallbackGasLimit() external view returns (uint32) {
        return i_callbackGasLimit;
    }

    function getVRFCoordinator() external view returns (VRFCoordinatorV2Interface) {
        return i_vrfCoordinator;
    }

    function getGasLane() external view returns (bytes32) {
        return i_gasLane;
    }

    function getNumberOfPlayers() external view returns (uint256) {
        return s_players.length;
    }

    function getPlayerAtIndex(uint256 index) external view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() external view returns (address) {
        return s_recentWinner;
    }

    function getLastTimeStamp() external view returns (uint256) {
        return s_lastTimestamp;
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }
}
