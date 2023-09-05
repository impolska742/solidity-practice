// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title  A simple contract to receive ether not less than 5 USD
 * @author @impolska742
 */

contract FundMe {
    AggregatorV3Interface internal dataFeed;
    uint256 public minimumUsd = 5 * 1e18;

    function fund() public payable {
        require(
            getConversionRate(msg.value) >= minimumUsd,
            "Didn't send enough usd"
        );
    }

    /**
     * Network: Goerli
     * Aggregator: ETH/USD
     * Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
     */
    constructor() {
        dataFeed = AggregatorV3Interface(
            0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        );
    }

    receive() external payable {}

    function getConversionRate(
        uint256 ethAmount
    ) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1e18;
        return ethAmountInUsd;
    }

    /**
     * Returns the latest answer.
     */
    function getPrice() public view returns (uint256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return uint256(answer * 1e10);
    }
}
