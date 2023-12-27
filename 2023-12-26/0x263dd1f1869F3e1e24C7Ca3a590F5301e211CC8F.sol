// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface BABYORDITOKEN {
    function balanceOf(address account) external view returns (uint);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function burn(uint256 value) external returns (bool);
}

interface IPancakeRouter01 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract BabyOrdiAirdrop {
    address public owner;
    address public babyordi;
    address payable public  fundAddress;
    
    bool public isShutdown;
    uint256 public tokenId;
    uint256 public totalDroped;

    uint256 private constant _value = 0.05 * 10**18;
    uint256 private constant _singleAmount = 100 * 10 ** 18; 
    

    // 6,000
    
    constructor(address _babyordi,address payable _fundAddress) {
        owner = msg.sender;
        babyordi = _babyordi;
        totalDroped = 0;
        fundAddress=payable(_fundAddress);
    }


    function shutdowm() external {
        require(msg.sender == owner, "Not owner");
        require(!isShutdown, "Already shutdown");

        BABYORDITOKEN oridi = BABYORDITOKEN(babyordi);
        oridi.burn(oridi.balanceOf(address(this)));
        isShutdown = true;
    }



    function babyordiAirdrop() internal {
        address _msgSender = msg.sender;
        require(_msgSender == tx.origin, "Only EOA");
        require(msg.value == _value, "Incorrect value");
        require(!isShutdown, "Already shutdown");

   
        BABYORDITOKEN oridi = BABYORDITOKEN(babyordi);
        require(oridi.balanceOf(address(this)) >= _singleAmount, "Droped out");
        require(oridi.transfer(_msgSender, _singleAmount), "Transfer failed");
        fundAddress.transfer(_value);
        totalDroped++;
    }

    receive() external payable {
        babyordiAirdrop();
    }
}