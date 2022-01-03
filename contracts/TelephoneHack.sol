// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Telephone.sol";

contract TelephoneHack {

  address public owner;
  Telephone originalContract;

  constructor() public {
    owner = msg.sender;
  }

//   function hack() public{

//     originalContract = Telephone(0x88781FAEb7Ec480D7d9e841B3c75d777BcEf78b1);
//     originalContract.changeOwner(owner);
//   }
}