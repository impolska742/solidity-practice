// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    address USER1 = makeAddr("user1");
    address USER2 = makeAddr("user2");

    uint256 constant SEND_FUND = 1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    modifier funded() {
        vm.prank(USER1);
        fundMe.fund{value: SEND_FUND}();
        _;
    }

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
    function testGetOwner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // Unit
    function testVersion() public {
        assertEq(fundMe.getVersion(), 4);
    }

    // Unit
    function testGetFunderFailsBeforeFunding() public {
        vm.expectRevert();
        fundMe.getFunder(0);
    }

    // Unit
    function testGetFunderSucceedsAfterFunding() public funded {
        assertEq(fundMe.getFunder(0), USER1);
    }

    // Unit
    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund(); // 0 value
    }

    // Integration
    function testFundUpdatesAddressToAmountFundedDataStructure()
        public
        funded
    {
        vm.prank(USER1);
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER1);
        assertEq(SEND_FUND, amountFunded);
    }

    // Integration
    function testFundUpdatesFundersDataStructure() public funded {
        vm.prank(USER1);
        address funder = fundMe.getFunder(0);
        assertEq(USER1, funder);
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

    // Integration
    function testWithdrawFail() public funded {
        vm.prank(USER1);
        vm.expectRevert();
        fundMe.withdraw();
    }

    // Integration
    function testWithdrawSucceeds() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    // Integration
    function testWithdrawFromMultipleFunders() public {
        uint256 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            address CURRENT_USER = address(i);

            // vm.prank new address
            // vm.deal new address
            // vm.prank(CURRENT_USER);
            // vm.deal(CURRENT_USER, STARTING_BALANCE);

            hoax(CURRENT_USER, STARTING_BALANCE);
            fundMe.fund{value: SEND_FUND}();
        }

        // Test balance before withdraw
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        assertEq(startingFundMeBalance, numberOfFunders * SEND_FUND);

        // Withdraw
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // Test balance after withdraw
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    // Integration
    function testCheaperWithdrawFromMultipleFunders() public {
        uint256 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            address CURRENT_USER = address(i);

            // vm.prank new address
            // vm.deal new address
            // vm.prank(CURRENT_USER);
            // vm.deal(CURRENT_USER, STARTING_BALANCE);

            hoax(CURRENT_USER, STARTING_BALANCE);
            fundMe.fund{value: SEND_FUND}();
        }

        // Test balance before withdraw
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        assertEq(startingFundMeBalance, numberOfFunders * SEND_FUND);

        // Withdraw
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // Test balance after withdraw
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    // E2E
    function testAll() public {
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

        // Test balance before withdraw
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Withdraw
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 amountFundedAfterWithdraw = fundMe.getAddressToAmountFunded(
            USER1
        );

        vm.expectRevert();
        fundMe.getFunder(0);

        // Test balance after withdraw
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
        assertEq(amountFundedAfterWithdraw, 0);
    }
}
