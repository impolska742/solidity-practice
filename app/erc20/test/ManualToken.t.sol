// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Test} from "forge-std/Test.sol";
import {ManualToken} from "../src/ManualToken.sol";
import {console} from "forge-std/console.sol";
import {DeployManualToken} from "../script/DeployManualToken.s.sol";

contract ManualTokenTest is Test {
    ManualToken public manualToken;
    DeployManualToken public deployer; 

    uint256 constant public STARTING_BALANCE = 100 ether;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        deployer = new DeployManualToken();
        manualToken = deployer.run();

        vm.prank(msg.sender);
        manualToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() view external {
        assert(STARTING_BALANCE == manualToken.balanceOf(bob));
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;
        // bob approves alice to spend tokens on his behalf
        
        vm.prank(bob);
        manualToken.approve(alice, initialAllowance);

        assert(manualToken.allowance(bob, alice) == initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        manualToken.transferFrom(bob, alice, transferAmount);

        assert(manualToken.balanceOf(alice) == transferAmount);
        assert(manualToken.balanceOf(bob) == STARTING_BALANCE - transferAmount);
        assert(manualToken.allowance(bob, alice) == initialAllowance - transferAmount);
    }

    function testInitialSupply() view external {
        assert(STARTING_BALANCE == manualToken.totalSupply());
    }

    function testDecimals() view external {
        assert(18 == manualToken.decimals());
    }

    function testNameAndSymbol() external {
        assertEq(bytes("ManualToken"), bytes(manualToken.name()));
        assertEq(bytes("MT"), bytes(manualToken.symbol()));
    }


    function testOwnerBalance() view external {
        assert(0 == manualToken.balanceOf(msg.sender));
        assert(STARTING_BALANCE == manualToken.balanceOf(bob));
    }

    function testTransfer() public {
        uint256 transferAmount = 10 ether;

        vm.prank(bob);
        manualToken.transfer(alice, transferAmount);

        assert(manualToken.balanceOf(bob) == STARTING_BALANCE - transferAmount);
        assert(manualToken.balanceOf(alice) == transferAmount);
    }

    function testTransferFromInsufficientAllowance() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 1500; // Attempt to transfer more than the allowance

        vm.prank(bob);
        manualToken.approve(alice, initialAllowance);

        assert(manualToken.allowance(bob, alice) == initialAllowance);

        vm.prank(alice);
        vm.expectRevert();
        manualToken.transferFrom(bob, alice, transferAmount);

        assert(manualToken.balanceOf(alice) == 0);
        assert(manualToken.balanceOf(bob) == STARTING_BALANCE);
    }

    function testTransferFromInsufficientBalance() public {
        uint256 initialAllowance = STARTING_BALANCE;
        uint256 transferAmount = STARTING_BALANCE + 1; // Attempt to transfer more than the balance

        vm.prank(bob);
        manualToken.approve(alice, initialAllowance);

        assert(manualToken.allowance(bob, alice) == initialAllowance);

        vm.prank(alice);
        vm.expectRevert();
        manualToken.transferFrom(bob, alice, transferAmount);

        assert(manualToken.balanceOf(alice) == 0);
        assert(manualToken.balanceOf(bob) == STARTING_BALANCE);
    }
}