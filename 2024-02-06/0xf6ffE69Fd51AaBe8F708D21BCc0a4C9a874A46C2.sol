pragma solidity ^0.8.10;

contract THBN {

    function hellowolrd() external pure returns(string memory) {
        return "hellowolrd";
    }

    function release() external {
        selfdestruct(payable (msg.sender));
    } 
    
}