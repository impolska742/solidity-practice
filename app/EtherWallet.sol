// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract EtherWallet {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function withdraw(uint _amount) external onlyOwner {
        // owner.transfer(_amount);

        // Optimizing for gas
        payable(msg.sender).transfer(_amount);
    } 

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}