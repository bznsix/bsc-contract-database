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
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface INFT {
    function mint(address to, uint256 num) external;

    function balanceOf(address owner) external view returns (uint256 balance);
}

interface IToken {
    function nftReward(address account) external view returns (uint256);

    function initSaleLP(address account, uint256 lpAmount) external;
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

abstract contract AbsPreSale is Ownable {
    struct UserInfo {
        bool active;
        uint256 nftInviteIndex;
    }

    uint256 private _pricePerSale;
    uint256 private _tokenAmountPerSale;

    address public _cashAddress;
    address private _tokenAddress;

    address public _nftAddress;

    mapping(address => UserInfo) private _userInfo;
    address[] public _userList;
    bool private _pauseBuy = false;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;

    uint256 private _nftCondition = 10;
    address private _defaultInvitor;
    uint256 public _inviteRate = 1000;
    uint256 public _lpRate = 5000;

    address private immutable _weth;
    ISwapRouter private immutable _swapRouter;
    ISwapFactory private immutable _swapFactory;

    constructor(address RouterAddress, address TokenAddress, address NFTAddress, address CashAddress, address DefaultInvitor){
        _cashAddress = CashAddress;
        _tokenAddress = TokenAddress;
        _nftAddress = NFTAddress;
        _pricePerSale = 0.5 ether;
        _tokenAmountPerSale = 13500 * 10 ** IERC20(TokenAddress).decimals();
        _defaultInvitor = DefaultInvitor;
        _userInfo[DefaultInvitor].active = true;
        IERC20(TokenAddress).approve(RouterAddress, ~uint256(0));
        _swapRouter = ISwapRouter(RouterAddress);
        _swapFactory = ISwapFactory(_swapRouter.factory());
        _weth = _swapRouter.WETH();
    }

    function buy(address invitor) external payable {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(!userInfo.active, "bought");

        UserInfo storage invitorInfo = _userInfo[invitor];
        require(invitorInfo.active, "invalid Invitor");
        _invitor[account] = invitor;
        _binder[invitor].push(account);
        invitorInfo.nftInviteIndex += 1;
        if (invitorInfo.nftInviteIndex >= _nftCondition) {
            invitorInfo.nftInviteIndex = 0;
            _giveNFT(invitor);
        }
        userInfo.active = true;
        _userList.push(account);

        uint256 value = _pricePerSale;
        require(msg.value >= value, "value");

        uint256 inviteValue = value * _inviteRate / 10000;
        safeTransferETH(invitor, inviteValue);
        uint256 lpValue = value - inviteValue;
        address tokenAddress = _tokenAddress;
        (, , uint liquidity) = _swapRouter.addLiquidityETH{value : lpValue}(tokenAddress, _tokenAmountPerSale, 0, 0, address(this), block.timestamp);
        address lp = _swapFactory.getPair(_weth, tokenAddress);
        uint256 userLP = liquidity * _lpRate / (10000 - _inviteRate);
        IToken(tokenAddress).initSaleLP(account, userLP);
        IERC20(lp).transfer(account, userLP);
        IERC20(lp).transfer(_cashAddress, liquidity - userLP);
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        if (success) {

        }
    }

    function _giveNFT(address invitor) private {
        INFT(_nftAddress).mint(invitor, 1);
    }


    function _giveToken(address tokenAddress, address account, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= tokenNum, "BNE");
        token.transfer(account, tokenNum);
    }

    function getSaleInfo() external view returns (
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        uint256 pricePerSale, uint256 tokenAmountPerSale,
        bool pauseBuy, uint256 nftCondition, uint256 saleTokenAmount,
        address defaultInvitor
    ) {
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        pricePerSale = _pricePerSale;
        tokenAmountPerSale = _tokenAmountPerSale;
        pauseBuy = _pauseBuy;
        nftCondition = _nftCondition;
        saleTokenAmount = IERC20(tokenAddress).balanceOf(address(this));
        defaultInvitor = _defaultInvitor;
    }

    function getUserInfo(address account) external view returns (
        bool active,
        uint256 nftInviteIndex,
        uint256 balance,
        uint256 nftNum,
        uint256 nftReward,
        uint256 binderLength
    ) {
        UserInfo storage userInfo = _userInfo[account];
        active = userInfo.active;
        nftInviteIndex = userInfo.nftInviteIndex;
        balance = account.balance;
        nftNum = INFT(_nftAddress).balanceOf(account);
        nftReward = IToken(_tokenAddress).nftReward(account);
        binderLength = _binder[account].length;
    }

    function getBinderLength(address account) public view returns (uint256){
        return _binder[account].length;
    }

    function getUserListLength() public view returns (uint256){
        return _userList.length;
    }

    receive() external payable {}

    function setAmountPerSale(uint256 amount) external onlyOwner {
        _tokenAmountPerSale = amount;
    }

    function setPricePerSale(uint256 amount) external onlyOwner {
        _pricePerSale = amount;
    }

    function setNftCondition(uint256 c) external onlyOwner {
        _nftCondition = c;
    }

    function setTokenAddress(address adr) external onlyOwner {
        _tokenAddress = adr;
        IERC20(adr).approve(address(_swapRouter), ~uint256(0));
    }

    function setDefaultInvitor(address adr) external onlyOwner {
        _defaultInvitor = adr;
        _userInfo[_defaultInvitor].active = true;
    }

    function setCashAddress(address adr) external onlyOwner {
        _cashAddress = adr;
    }

    function claimBalance(uint256 amount, address to) external onlyOwner {
        address payable addr = payable(to);
        addr.transfer(amount);
    }

    function claimToken(address erc20Address, address to, uint256 amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(to, amount);
    }

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    function getUserList(
        uint256 start,
        uint256 length
    ) external view returns (
        uint256 returnCount,
        address[] memory userList
    ){
        uint256 recordLen = _userList.length;
        if (0 == length) {
            length = recordLen;
        }
        returnCount = length;

        userList = new address[](length);
        uint256 index = 0;
        for (uint256 i = start; i < start + length; i++) {
            if (i >= recordLen) {
                return (index, userList);
            }
            userList[index] = _userList[i];
            index++;
        }
    }
}

contract PreSale is AbsPreSale {
    constructor() AbsPreSale(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //Token
        address(0xbDc52e316535D745fe0506CCe5573Db2ac3C7bA1),
    //NFT
        address(0x4a60BE007f5E48cBfb7009A64fb287AB08815392),
    //Cash
        address(0x8565f096A6cE251d3d032f4788ebd33A2e175A29),
    //Default Invitor
        address(0x194d29255526e6ED1449faF6444e871A8385E01d)
    ){

    }
}