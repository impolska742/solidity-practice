// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract Token is ERC20, Ownable, ERC20Permit {
    constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function gaslessTransfer(
        address sender,
        address receiver,
        uint amount,
        uint fee,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Permit - sender approves this contract to spend amount + fee
        // transferFrom(sender, receiver, amount)
        // transferFrom(sender, msg.sender, fee)
        permit(sender, address(this), amount + fee, deadline, v, r, s);
        transferFrom(sender, receiver, amount);
        transferFrom(sender, msg.sender, fee);
    }
}
