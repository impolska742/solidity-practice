// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Constants {
  address public constant MY_ADDRESS = 0x6887246668a3b87F54DeB3b94Ba47a6f63F32985;
  uint public constant MY_UINT = 123;
}

contract Var {
  address public NOT_CONSTANT_ADDRESS = 0x6887246668a3b87F54DeB3b94Ba47a6f63F32985;
}
