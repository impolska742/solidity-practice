// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.21;

contract ManualToken {
    mapping(address => uint256) private s_balances;
    mapping(address => mapping(address => uint256)) s_allowances;

    string public name = "ManualToken";
    string public symbol = "MT";
    uint256 public totalSupply = 100 ether;
    uint8 public decimals = 18;

    constructor(uint256 initialSupply) {
        s_balances[msg.sender] = initialSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function allowance(address _from, address _to) public view returns (uint256) {
        return s_allowances[_from][_to];
    }

    function approve(address _to, uint256 _amount) public {
        require(s_balances[msg.sender] >= _amount);
        s_allowances[msg.sender][_to] += _amount;
    }

    function transfer(address _to, uint256 _amount) public {
        require(balanceOf(msg.sender) >= _amount);
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public {
        require(s_allowances[_from][_to] >= _amount);
        require(s_balances[_from] >= _amount);

        s_allowances[_from][_to] -= _amount;
        s_balances[_from] -= _amount;
        s_balances[_to] += _amount;
    }
}