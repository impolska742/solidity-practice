// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {console} from "forge-std/console.sol";


contract RaffleTest is Test {
    Raffle raffle;
    HelperConfig helperConfig;

    uint256 entranceFee;
    uint256 duration;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;

    address public PLAYER = makeAddr("PLAYER");
    uint256 public constant STARTING_BALANCE = 10 ether;

    /** Events */
    event Raffle__EnteredRaffle(address indexed player);
    event Raffle__PickedWinner(address indexed winner);

    modifier raffleEnteredAndTimePassed() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);
        _;
    }

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig, subscriptionId) = deployer.run();
        console.log("Raffle Balance: ", address(raffle).balance);
        (
            entranceFee,
            duration,
            vrfCoordinator,
            gasLane,
            /** subscriptionId */ ,
            callbackGasLimit,
            link,
            /** deployer */
        ) = helperConfig.activeNetworkConfig();
        vm.deal(PLAYER, STARTING_BALANCE);
    }

    function testEntranceFees() external view {
        assert(raffle.getEntranceFee() == entranceFee);
    }

    function testDuration() external view {
        assert(raffle.getDuration() == duration);
    }

    function testGasLane() external view {
        assert(raffle.getGasLane() == gasLane);
    }

    function testVRFCoordinator() external view {
        assert(address(raffle.getVRFCoordinator()) == vrfCoordinator);
    }

    function testSubscriptionId() external view {
        assert(raffle.getSubscriptionId() == subscriptionId);
    }

    function testCallbackGasLimit() external view {
        assert(raffle.getCallbackGasLimit() == callbackGasLimit);
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenYouDontPayEnough() external {
        // Arrange
        vm.prank(PLAYER);
        // Act
        vm.expectRevert(Raffle.Raffle__InsufficientEthSent.selector);
        raffle.enterRaffle();
        // Assert 
    }

    function testPlayersRecordsAfterPlayerEntersRaffle() external {
        uint256 prevPlayersLength = raffle.getNumberOfPlayers();
        assert(prevPlayersLength == 0);
        vm.expectRevert();
        raffle.getPlayerAtIndex(0);

        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

        uint256 afterPlayersLength = raffle.getNumberOfPlayers();
        address playerRecorded = raffle.getPlayerAtIndex(0);

        assert(afterPlayersLength == prevPlayersLength + 1);
        assert(playerRecorded == PLAYER);
    }

    function testEventEmitsAfterPlayerEntersRaffle() external {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit Raffle__EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testCannotEnterRaffleWhenRaffleInCalculatingState() raffleEnteredAndTimePassed external {
        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle__RaffleIsNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testCheckUpkeepFalseIfItHasNoBalance() external {
        // Pass enough time for checkUpkeep to return 'true' so that performUpkeep can fire 
        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        assert(upkeepNeeded == false);
    }

    function testCheckUpkeepFalseIfEnoughTimeHasNotPassed() external {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        assert(upkeepNeeded == false);
    }

    function testCheckUpkeepFalseIfEnoughRaffleNotInOpenState() raffleEnteredAndTimePassed external {
        raffle.performUpkeep("");
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        assert(upkeepNeeded == false);
    }

    function testCheckUpkeepTrueWhenParamsAreGood() raffleEnteredAndTimePassed external {
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        assert(upkeepNeeded);
    }

    function testPerformUpkeepRunsOnlyIfCheckUpkeepIsTrue() raffleEnteredAndTimePassed external {
        raffle.performUpkeep("");
    }

    // No balance / No Players
    function testPerformUpkeepRevertsIfCheckUpkeepIsFalseNoBalance() external {
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState raffleState = Raffle.RaffleState.OPEN;
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__UpkeepNotNeeded.selector, 
                currentBalance, 
                numPlayers, 
                raffleState
            )
        );
        raffle.performUpkeep("");
    }

    // Not Open
    function testPerformUpkeepRevertsIfCheckUpkeepIsFalseNotOpenState() raffleEnteredAndTimePassed external {
        uint256 currentPlayers = 1;

        assert(address(raffle).balance == entranceFee);
        assert(raffle.getNumberOfPlayers() == currentPlayers);
        
        raffle.performUpkeep("");

        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__UpkeepNotNeeded.selector, 
                entranceFee, 
                currentPlayers, 
                Raffle.RaffleState.CALCULATING
            )
        );
        raffle.performUpkeep("");
    }

    // Not Enough Time Has Passed
    function testPerformUpkeepRevertsIfCheckUpkeepIsFalseNotEnoughTimeHasPassed() external {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

        uint256 currentPlayers = 1;
        Raffle.RaffleState raffleState = Raffle.RaffleState.OPEN;

        console.log("entranceFee : ", entranceFee);
        console.log("address(raffle).balance : ", address(raffle).balance);
        console.log("raffle.getNumberOfPlayers() : ", raffle.getNumberOfPlayers());
        console.log("currentPlayers : ", currentPlayers);

        assert(address(raffle).balance == entranceFee);
        assert(raffle.getNumberOfPlayers() == currentPlayers);
        
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__UpkeepNotNeeded.selector, 
                entranceFee, 
                currentPlayers, 
                raffleState
            )
        );
        raffle.performUpkeep("");
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() 
        raffleEnteredAndTimePassed external 
    {
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 requestId = entries[1].topics[1];
        Raffle.RaffleState raffleState = raffle.getRaffleState();

        assert(uint256(requestId) > 0);
        assert(raffleState == Raffle.RaffleState.CALCULATING);
    }

    modifier skipFork() {
        if(block.chainid != 31337) {
            return;
        }
        _;
    }

    function testFulfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep(uint256 randomRequestId) 
        external skipFork raffleEnteredAndTimePassed
    {
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(randomRequestId, address(raffle));
    }

    function testFulfillRandomWordsPicksAWinnerResetsAndSendsMoney()
        external skipFork raffleEnteredAndTimePassed
    {
        // Arrange
        uint256 additionalEntrants = 5;
        uint256 startingIndex = 1;
        
        for(uint256 i = startingIndex; i < startingIndex + additionalEntrants; i++) {
            address player = address(uint160(i));
            hoax(player, STARTING_BALANCE);
            raffle.enterRaffle{value: entranceFee}();
        }

        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        uint256 previousTimeStamp = raffle.getLastTimeStamp();
        uint256 prize = entranceFee * (additionalEntrants + startingIndex);

        // pretent to be chainlink vrf to get the random number & pick winner
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId), 
            address(raffle)
        );

        address winner = raffle.getRecentWinner();

        // Assert
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
        assert(winner != address(0));
        assert(raffle.getNumberOfPlayers() == 0);
        assert(raffle.getLastTimeStamp() > previousTimeStamp);
        assert(winner.balance == STARTING_BALANCE + prize - entranceFee);
    }
}