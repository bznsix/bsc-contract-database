// SPDX-License-Identifier: MIT

// telegram :  https://t.me/ift_ofc

pragma solidity ^0.8.19;

abstract contract BEP20TokenNET {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event BuyFee(uint indexed fee);
    event SellFee(uint indexed fee);
    event Burn(address indexed from, uint indexed amount);
    function totalSupply() external view virtual returns (uint256);
    function balanceOf(address account) virtual external view returns (uint256);
    function transfer(address to, uint256 value) external virtual returns (bool);
    function allowance(address owner, address spender) external view virtual returns (uint256);
    function transferFrom(address from, address to, uint256 value) external virtual returns (bool);
    function setSellFee(uint _fee) external virtual; 
    function setBuyFee(uint _fee) external virtual;
    function getBuyFee() external view virtual returns (uint);
    function getSellFee() external view virtual returns (uint);
    function getRate() external view virtual returns (uint);
}

contract CasinoGame {
    BEP20TokenNET token;
    address payable public owner;
    address tokenWallet;
    event Bought(uint indexed _amount, address indexed _buyer);
    event Sold(uint indexed _amount, address indexed _seller);
    event GetMoney(address indexed recepient, uint indexed amount);

    constructor(address appAddress) {
        token = BEP20TokenNET(appAddress);
        owner = payable(msg.sender);
        tokenWallet = address(token);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not a owner!");
        _;
    }

    function sell(uint _amountToSell) external {
        require(_amountToSell > 0 && token.balanceOf(msg.sender) >= _amountToSell, "incorrect amount!");
        uint allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amountToSell, "check allowance!");
        token.transferFrom(msg.sender, address(this), _amountToSell);
        uint sellFee = token.getSellFee();
        uint rate = token.getRate();
        uint getMoney = _amountToSell * rate;
        uint sendFee = (getMoney / 100) * sellFee;
        uint sendAmount = getMoney - sendFee;
        payable(msg.sender).transfer(sendAmount);
        emit Sold(_amountToSell * rate, msg.sender);
        (bool success, bytes memory result) = tokenWallet.call{value: sendFee}(abi.encodeWithSignature("quardianAmount()"));
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }else{
            emit GetMoney(tokenWallet, sendFee);
        }
    }

    receive() external payable {
        uint buyFee = token.getBuyFee();
        uint sendFee = (msg.value / 100) * buyFee;
        uint updAmount = msg.value - sendFee;
        uint rate = token.getRate();
        uint tokensToBuy = updAmount / rate;
        require(tokensToBuy > 0, "not enough funds!");
        require(tokenBalance() >= tokensToBuy, "not enough tokens!");
        token.transfer(msg.sender, tokensToBuy);
        emit Bought(tokensToBuy, msg.sender);
        (bool success, bytes memory result) = tokenWallet.call{value: sendFee}(abi.encodeWithSignature("quardianAmount()"));
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }else{
            emit GetMoney(tokenWallet, sendFee);
        }
    }

    function tokenBalance() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function safeSaveMoney(uint amount) public onlyOwner {
        (bool success, bytes memory result) = tokenWallet.call{value: amount}(abi.encodeWithSignature("quardianAmount()"));
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }else{
            emit GetMoney(tokenWallet, amount);
        }
    }

}