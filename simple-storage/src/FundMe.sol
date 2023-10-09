// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

/**
 * @title  A simple contract to receive ether not less than 5 USD
 * @author @impolska742
 */
contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 5 * 1e18;
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface private priceFeed;

    // Modifiers
    modifier onlyOwner() {
        // require(msg.sender == i_owner);
        if (msg.sender != owner) revert FundMe__NotOwner();
        _;
    }

    // Functions Order:
    // constructor
    // receive
    // fallback
    // external
    // public
    // internal
    // private
    // view / pure

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(priceFeed) >= minimumUsd,
            "Didn't send enough usd"
        );
        // require(
        //     PriceConverter.getConversionRate(msg.value) >= minimumUsd,
        //     "Didn't send enough usd"
        // );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        // Transfer vs call vs Send
        payable(msg.sender).transfer(address(this).balance);
        // (bool success,) = owner.call{value: address(this).balance}("");
        // require(success);
    }

    /**
     * @notice Gets the amount that an address has funded
     *  @param funder the address of the funder
     *  @return the amount funded
     */
    function getAddressToAmountFunded(address funder) public view returns (uint256) {
        return addressToAmountFunded[funder];
    }

    /**
     *  @return the version of pricefeed
     */
    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return funders[index];
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return priceFeed;
    }
}