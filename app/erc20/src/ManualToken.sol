// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.21;

contract ManualToken {
    mapping(address => uint256) private s_balances;
    string public name = "Manual Token";
    uint256 public totalSupply = 100 ether;
    uint8 public decimals = 18;

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public {
        require(balanceOf(msg.sender) >= _amount);
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;
    }
}