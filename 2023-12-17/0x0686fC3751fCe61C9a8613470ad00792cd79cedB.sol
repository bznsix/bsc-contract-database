// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
contract Payment {
    struct Pay {
        address contractAddress;
        address fromAddress;
        address toAddress;
        uint payTotal;
    }
    mapping(uint=>Pay) public payInfos;
    event _Payment(uint orderNo, address contractAddress, address from, address to, uint total);

    constructor(){}

    function payment(uint orderId, address contractAddress, address[] memory addresses, uint[] memory amounts,uint endTime) external returns (uint total){
        require(addresses.length == amounts.length);
        require(endTime>=block.timestamp);
        require(payInfos[orderId].payTotal==0);
        for (uint i; i < addresses.length; i++) {
            require(amounts[i] > 0);
            total += amounts[i];
            IERC20(contractAddress).transferFrom(msg.sender, address(0x79F92BCD8738dAeb9553c1A74F74180d0AA47dFd), amounts[i]);
        }
        require(total>0);
        Pay storage info = payInfos[orderId];
        info.contractAddress=contractAddress;
        info.fromAddress=msg.sender;
        info.toAddress=address(0x79F92BCD8738dAeb9553c1A74F74180d0AA47dFd);
        info.payTotal=total;
        emit _Payment(orderId, contractAddress, msg.sender,info.toAddress, total);
    }
}