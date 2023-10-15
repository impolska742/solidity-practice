// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.sol";
import {console} from "forge-std/console.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    address USER1 = makeAddr("user1");
    address USER2 = makeAddr("user2");

    uint256 constant SEND_FUND = 1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    // What can we do to work with addresses outside our system?
    // 1. Unit
    //    - Testing a specific part of the code
    // 2. Integration
    //    - Testing how are code works with other parts of our code
    // 3. Forked
    //    - Testing our code in a simulated real environment
    // 4. Staging
    //    - Testing our code in a real environment that is not prod

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER1, STARTING_BALANCE);
        vm.deal(USER2, STARTING_BALANCE);
    }

    // Unit
    function testMinimumUSD() public {
        assertEq(fundMe.minimumUsd(), 5e18);
    }

    // Unit
    function testOwner() public {
        assertEq(fundMe.owner(), msg.sender);
    }

    // Unit
    function testGetOwner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // Unit
    function testVersion() public {
        assertEq(fundMe.getVersion(), 4);
    }

    // Unit
    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund(); // 0 value
    }

    // Integration
    function testFundUpdatesAddressToAmountFundedFundedDataStructure() public {
        vm.startPrank(USER1);

        fundMe.fund{value: SEND_FUND}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER1);
        assertEq(SEND_FUND, amountFunded);

        vm.stopPrank();
    }

    // Integration
    function testFundUpdatesFundersDataStructure() public {
        vm.startPrank(USER1);

        fundMe.fund{value: SEND_FUND}();
        address funder = fundMe.getFunder(0);
        assertEq(USER1, funder);

        vm.stopPrank();
    }

    // Integration
    function testFundUpdatesFundersDataStructureWithTwoUsers() public {
        vm.startPrank(USER1);

        fundMe.fund{value: SEND_FUND}();
        address funder1 = fundMe.getFunder(0);
        assertEq(USER1, funder1);

        vm.stopPrank();

        vm.startPrank(USER2);

        fundMe.fund{value: SEND_FUND}();
        address funder2 = fundMe.getFunder(1);
        assertEq(USER2, funder2);

        vm.stopPrank();
    }

    // Integration
    function testFundUpdatesAllDataStructures() public {
        vm.startPrank(USER1);

        // Check Balance at start
        assertEq(address(USER1).balance, STARTING_BALANCE);
        assertEq(address(fundMe).balance, 0);

        // Check amount funded before funding
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER1);
        assertEq(0, amountFunded);

        // Check funders list before funding
        vm.expectRevert();
        fundMe.getFunder(0);

        // Fund the contract
        fundMe.fund{value: SEND_FUND}();

        // Check Balance after funding
        assertEq(address(USER1).balance, STARTING_BALANCE - SEND_FUND);
        assertEq(address(fundMe).balance, SEND_FUND);

        // Check funders list after funding got updated
        address funder = fundMe.getFunder(0);
        assertEq(USER1, funder);

        // Check address to amount funded
        amountFunded = fundMe.getAddressToAmountFunded(USER1);
        assertEq(SEND_FUND, amountFunded);

        // Fund the contract again
        fundMe.fund{value: SEND_FUND}();

        // Check Balance after funding
        assertEq(address(USER1).balance, STARTING_BALANCE - (SEND_FUND * 2));
        assertEq(address(fundMe).balance, SEND_FUND * 2);

        // Check funders list after funding got updated twice
        funder = fundMe.getFunder(1);
        assertEq(USER1, funder);

        // Check address to amount funded
        amountFunded = fundMe.getAddressToAmountFunded(USER1);
        assertEq(SEND_FUND * 2, amountFunded);

        vm.stopPrank();
    }
}
