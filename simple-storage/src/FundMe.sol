// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {PriceConverter} from "./PriceConverter.sol";

/**
 * @title  A simple contract to receive ether not less than 5 USD
 * @author @impolska742
 */

contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 5 * 1e18;

    function fund() public payable {
        require(
            msg.value.getConversionRate() >= minimumUsd,
            "Didn't send enough usd"
        );
    }

    receive() external payable {}
}
