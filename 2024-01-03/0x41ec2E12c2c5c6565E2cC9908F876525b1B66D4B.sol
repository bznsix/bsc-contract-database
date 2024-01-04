// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IBEP20 {
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function transfer(address _to, uint256 _value) external returns (bool success);
}

contract AlmeContract is Ownable {
    event PaymentEmit(address indexed buyer, uint256 usdtAmount, uint256 almeAmount);

    address public usdtAddress;
    address public almeCoinAddress;
    uint256 public rate; // AlmeCoins provided per USDT

    constructor() {
        // Set the initial addresses and rate
        usdtAddress = 0x55d398326f99059fF775485246999027B3197955; // USDT Address
        almeCoinAddress = 0xc4f0B44f8585aa587f5fba8B6896c3b434EC9BCD; // AlmeCoin Address
        rate = 500; // Initial rate: 1 USDT = 500 AlmeCoins
    }

    function buyAlmeCoin(uint256 usdtAmount) external returns (bool) {
        uint256 almeAmount = usdtAmount * rate;

        // Transfer USDT from sender to contract owner
        require(IBEP20(usdtAddress).transferFrom(msg.sender, owner(), usdtAmount), "USDT transfer failed");

        // Transfer AlmeCoin from contract owner to sender
        require(IBEP20(almeCoinAddress).transfer(msg.sender, almeAmount), "AlmeCoin transfer failed");

        emit PaymentEmit(msg.sender, usdtAmount, almeAmount);
        return true;
    }

    function setUsdtAddress(address _usdtAddress) public onlyOwner {
        require(_usdtAddress != address(0), "USDT address cannot be the zero address");
        usdtAddress = _usdtAddress;
    }

    function setAlmeCoinAddress(address _almeCoinAddress) public onlyOwner {
        require(_almeCoinAddress != address(0), "AlmeCoin address cannot be the zero address");
        almeCoinAddress = _almeCoinAddress;
    }

    function setRate(uint256 newRate) public onlyOwner {
        require(newRate > 0, "Rate must be greater than 0");
        rate = newRate;
    }
}