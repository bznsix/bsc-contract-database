// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

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

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsPreSale is Ownable {
    struct UserInfo {
        bool active;
        uint256 buyAmount;
        uint256 inviteAmount;
        uint256 inviteReward;
    }

    uint256 private _qty;
    uint256 private _soldAmount;
    uint256 private _mintPrice;
    uint256 private _tokenAmountPerBNB;
    bool private _pauseBuy;
    bool private _whiteBuy = true;

    address private _tokenAddress;
    address public _cashAddress;

    mapping(address => UserInfo) private _userInfo;
    uint256 public _inviteFee = 1000;

    constructor(address CashAddress){
        _cashAddress = CashAddress;

        _qty = 500 ether;
        _mintPrice = 0.5 ether;

        _tokenAmountPerBNB = 160000 * 10 ** 18;
    }

    function buy(address invitor) external payable {
        require(!_pauseBuy, "pauseBuy");
        require(_qty > _soldAmount, "soldOut");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        if (_whiteBuy) {
            require(userInfo.active, "!white");
        }
        if (!userInfo.active) {
            require(_userInfo[invitor].active, "!invitor");
            _inviter[account] = invitor;
            _binders[invitor].push(account);
            userInfo.active = true;
        }
        uint256 buyAmount = userInfo.buyAmount;
        require(0 == buyAmount, "bought");

        uint256 msgValue = msg.value;
        uint256 amount = _mintPrice;
        require(msgValue >= amount, "!price");

        buyAmount += amount;
        _soldAmount += amount;

        userInfo.buyAmount = buyAmount;

        uint256 cashEth = amount;
        invitor = _inviter[account];
        if (address(0) != invitor) {
            UserInfo storage invitorInfo = _userInfo[invitor];
            invitorInfo.inviteAmount += amount;
            uint256 invitorEth = cashEth * _inviteFee / 10000;
            if (invitorEth > 0) {
                invitorInfo.inviteReward += invitorEth;
                _safeTransferETH(invitor, invitorEth);
                cashEth -= invitorEth;
            }
        }
        _safeTransferETH(_cashAddress, cashEth);

        uint256 tokenAmount = _tokenAmountPerBNB * amount / 1 ether;
        _giveToken(_tokenAddress, account, tokenAmount);
    }

    function _safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        if (success) {}
    }

    function _giveToken(address tokenAddress, address account, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        token.transfer(account, amount);
    }

    function getSaleInfo() external view returns (
        address tokenAddress,
        uint256 tokenDecimals,
        string memory tokenSymbol,
        bool pauseBuy,
        uint256 qty,
        uint256 soldAmount,
        uint256 mintPrice,
        bool whiteBuy,
        uint256 tokenAmountPerBNB
    ) {
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        pauseBuy = _pauseBuy;
        whiteBuy = _whiteBuy;
        qty = _qty;
        soldAmount = _soldAmount;
        mintPrice = _mintPrice;
        tokenAmountPerBNB = _tokenAmountPerBNB;
    }

    function getUserInfo(address account) external view returns (
        bool active,
        uint256 buyAmount,
        uint256 inviteAmount,
        uint256 inviteReward,
        uint256 balance,
        address invitor,
        uint256 binderLen
    ) {
        UserInfo storage userInfo = _userInfo[account];
        active = userInfo.active;
        buyAmount = userInfo.buyAmount;
        inviteAmount = userInfo.inviteAmount;
        inviteReward = userInfo.inviteReward;
        balance = account.balance;
        invitor = _inviter[account];
        binderLen = getBinderLength(account);
    }

    receive() external payable {}

    function setQty(uint256 qty) external onlyOwner {
        _qty = qty;
    }

    function setMintPrice(uint256 price) external onlyOwner {
        _mintPrice = price;
    }

    function setTokenAmountPerBNB(uint256 amount) external onlyOwner {
        _tokenAmountPerBNB = amount;
    }

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    function setWhiteBuy(bool white) external onlyOwner {
        _whiteBuy = white;
    }

    function setTokenAddress(address tokenAddress) external onlyOwner {
        _tokenAddress = tokenAddress;
    }

    function setCashAddress(address cashAddress) external onlyOwner {
        _cashAddress = cashAddress;
    }

    function setInviteFee(uint256 inviteFee) external onlyOwner {
        _inviteFee = inviteFee;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        address payable addr = payable(to);
        addr.transfer(amount);
    }

    function claimToken(address erc20Address, address to, uint256 amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(to, amount);
    }

    function batchActive(address [] memory addr) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _userInfo[addr[i]].active = true;
        }
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;

    function getBinderLength(address account) public view returns (uint256){
        return _binders[account].length;
    }
}

contract PreSale is AbsPreSale {
    constructor() AbsPreSale(
        address(0x81CD30c0921CBBd4d23b06a28bea9b1472a6AD56)
    ){

    }
}