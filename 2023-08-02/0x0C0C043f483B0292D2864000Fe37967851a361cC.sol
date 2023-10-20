pragma solidity ^0.8.0;

interface OtherContract {
    function deposit() external payable;
}

contract deposV2 {
    OtherContract private otherContract;
    
    constructor(address _otherContractAddress) {
        otherContract = OtherContract(_otherContractAddress);
    }

    function depositToOther() public {
        uint256 balance = address(this).balance;
        if(balance > 0){
            otherContract.deposit{value: balance}();
        }
    }

    // This function is called when the contract receives Ether
    receive() external payable {}
    
    // This function is called when someone sends a transaction to the contract with .send() or .transfer()
    fallback() external payable {}
}
