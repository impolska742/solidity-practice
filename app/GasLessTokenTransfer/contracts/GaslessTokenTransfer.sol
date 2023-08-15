// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

interface TokenWithPermit is IERC20, IERC20Permit {}

contract GasLessTokenTransfer {
    TokenWithPermit token;

    constructor(address _token) {
        token = TokenWithPermit(_token);
    }

    function send(
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
        TokenWithPermit(token).permit(
            sender,
            address(this),
            amount + fee,
            deadline,
            v,
            r,
            s
        );
        TokenWithPermit(token).transferFrom(sender, receiver, amount);
        TokenWithPermit(token).transferFrom(sender, msg.sender, fee);
    }
}
