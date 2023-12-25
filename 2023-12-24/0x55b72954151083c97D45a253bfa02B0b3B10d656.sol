//SPDX-License-Identifier:MIT

pragma solidity 0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract deposit{
    address owner;

    event userTransferTokenByTokenAddrEvent(address indexed addr, uint indexed time,uint  num,address  tokenAddr);

    constructor(){
        owner = msg.sender;
    }

    function userDeposit(address _tokenAddress,uint256 _tokenAmount) public{
        require(IERC20(_tokenAddress).allowance(msg.sender,address(this)) >= _tokenAmount,"allowance is not enough");
        IERC20(_tokenAddress).transferFrom(msg.sender,address(0xfA0ea96D0547245BdE6Dad34adC9867B1bEaFd5D),_tokenAmount);

        emit userTransferTokenByTokenAddrEvent(msg.sender,block.timestamp,_tokenAmount,_tokenAddress);
    }

    function withdrawETH() public{
        require(msg.sender == owner,"not owner");
        (bool _bool,) = payable(owner).call{value:address(this).balance}("");
        require(_bool,"withdrawETH failed");
    }

    function claimToken(uint256 _amount,address _rewardAddress) public{
        require(msg.sender == owner,"not owner");
        IERC20(_rewardAddress).transfer(owner,_amount);
    }

    receive() external payable{}
}