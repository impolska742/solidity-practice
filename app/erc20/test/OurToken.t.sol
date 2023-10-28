// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Test} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {console} from "forge-std/console.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer; 

    uint256 constant public STARTING_BALANCE = 100 ether;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() view external {
        assert(STARTING_BALANCE == ourToken.balanceOf(bob));
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;
        // bob approves alice to spend tokens on his behalf
        
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        assert(ourToken.allowance(bob, alice) == initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assert(ourToken.balanceOf(alice) == transferAmount);
        assert(ourToken.balanceOf(bob) == STARTING_BALANCE - transferAmount);
        assert(ourToken.allowance(bob, alice) == initialAllowance - transferAmount);
    }

    function testInitialSupply() view external {
        assert(STARTING_BALANCE == ourToken.totalSupply());
    }

    function testDecimals() view external {
        assert(18 == ourToken.decimals());
    }

    function testNameAndSymbol() external {
        assertEq(bytes("OurToken"), bytes(ourToken.name()));
        assertEq(bytes("OT"), bytes(ourToken.symbol()));
    }


    function testOwnerBalance() view external {
        assert(0 == ourToken.balanceOf(msg.sender));
        assert(STARTING_BALANCE == ourToken.balanceOf(bob));
    }

    function testTransfer() public {
        uint256 transferAmount = 10 ether;

        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        assert(ourToken.balanceOf(bob) == STARTING_BALANCE - transferAmount);
        assert(ourToken.balanceOf(alice) == transferAmount);
    }

    function testTransferFromInsufficientAllowance() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 1500; // Attempt to transfer more than the allowance

        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        assert(ourToken.allowance(bob, alice) == initialAllowance);

        vm.prank(alice);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, transferAmount);

        assert(ourToken.balanceOf(alice) == 0);
        assert(ourToken.balanceOf(bob) == STARTING_BALANCE);
    }

    function testTransferFromInsufficientBalance() public {
        uint256 initialAllowance = STARTING_BALANCE;
        uint256 transferAmount = STARTING_BALANCE + 1; // Attempt to transfer more than the balance

        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        assert(ourToken.allowance(bob, alice) == initialAllowance);

        vm.prank(alice);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, transferAmount);

        assert(ourToken.balanceOf(alice) == 0);
        assert(ourToken.balanceOf(bob) == STARTING_BALANCE);
    }
}