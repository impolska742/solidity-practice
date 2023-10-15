// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.sol";
import {console} from "forge-std/console.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

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
}
