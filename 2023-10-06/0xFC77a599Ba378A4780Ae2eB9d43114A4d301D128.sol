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

abstract contract AbsPreSale is Ownable {
    struct SaleInfo {
        uint256 price;
        uint256 qty;
        uint256 saleNum;
    }

    struct UserInfo {
        bool isActive;
        uint256 buyUsdtAmount;
        uint256 inviteUsdt;
        uint256 teamNum;
        uint256 teamAmount;
        uint256 buyNodeId;
    }

    address private _usdtAddress;
    address public _cashAddress;

    SaleInfo[] private _saleInfo;
    mapping(address => UserInfo) private _userInfo;

    bool private _pauseBuy = false;

    uint256 private _totalUsdt;
    uint256 private _totalInviteUsdt;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;
    mapping(uint256 => uint256) public _inviteFee;
    uint256 public _inviteRewardLen = 1;
    uint256 public  _teamLen = 10;
    mapping(uint256 => address[]) public _buyList;

    constructor(
        address UsdtAddress, address CashAddress
    ){
        _usdtAddress = UsdtAddress;
        _cashAddress = CashAddress;

        uint256 usdtUnit = 10 ** IERC20(UsdtAddress).decimals();

        _saleInfo.push(SaleInfo(1000 * usdtUnit, 500, 0));
        _saleInfo.push(SaleInfo(3000 * usdtUnit, 300, 0));
        _saleInfo.push(SaleInfo(5000 * usdtUnit, 200, 0));
        _saleInfo.push(SaleInfo(10000 * usdtUnit, 100, 0));
        _saleInfo.push(SaleInfo(30000 * usdtUnit, 100, 0));

        _inviteFee[0] = 2000;
    }

    function buy(uint256 saleId, address invitor) external {
        require(!_pauseBuy, "pauseBuy");

        address account = msg.sender;
        _bindInvitor(account, invitor);

        SaleInfo storage sale = _saleInfo[saleId];
        require(sale.qty > sale.saleNum, "no qty");
        sale.saleNum += 1;

        uint256 price = sale.price;

        UserInfo storage userInfo = _userInfo[account];
        require(0 == userInfo.buyUsdtAmount, "bought");
        _buyList[saleId].push(account);
        userInfo.buyUsdtAmount += price;
        userInfo.buyNodeId += saleId;

        _totalUsdt += price;

        address usdtAddress = _usdtAddress;
        _takeToken(usdtAddress, account, address(this), price);

        uint256 inviteRewardLen = _inviteRewardLen;
        address current = account;
        uint256 totalInviteUsdt;
        for (uint256 i; i < inviteRewardLen; ++i) {
            invitor = _invitor[current];
            if (address(0) == invitor) {
                break;
            }
            uint256 inviteAmount = price * _inviteFee[i] / 10000;
            totalInviteUsdt += inviteAmount;
            _userInfo[invitor].inviteUsdt += inviteAmount;
            _giveToken(usdtAddress, invitor, inviteAmount);
            current = invitor;
        }

        _giveToken(usdtAddress, _cashAddress, price - totalInviteUsdt);
        _totalInviteUsdt += totalInviteUsdt;

        current = account;
        uint256 teamLen = _teamLen;
        for (uint256 i; i < teamLen;) {
            invitor = _invitor[current];
            if (address(0) == invitor) {
                break;
            }
            _userInfo[invitor].teamAmount += price;
            current = invitor;
        unchecked{
            ++i;
        }
        }
    }

    function _bindInvitor(address account, address invitor) private {
        UserInfo storage user = _userInfo[account];
        if (!user.isActive) {
            if (_userInfo[invitor].isActive) {
                _invitor[account] = invitor;
                _binder[invitor].push(account);
                address current = account;
                uint256 teamLen = _teamLen;
                for (uint256 i; i < teamLen;) {
                    invitor = _invitor[current];
                    if (address(0) == invitor) {
                        break;
                    }
                    _userInfo[invitor].teamNum += 1;
                    current = invitor;
                unchecked{
                    ++i;
                }
                }
            }
            user.isActive = true;
        }
    }

    function _giveToken(address tokenAddress, address account, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "PTNE");
        safeTransfer(tokenAddress, account, amount);
    }

    function _takeToken(address tokenAddress, address from, address to, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(from)) >= tokenNum, "TNE");
        safeTransferFrom(tokenAddress, from, to, tokenNum);
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TF');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'ETF');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TFF');
    }

    function allSaleInfo() external view returns (
        uint256[] memory prices,
        uint256[] memory qtyNums,
        uint256[] memory saleNums
    ) {
        uint256 len = _saleInfo.length;
        prices = new uint256[](len);
        qtyNums = new uint256[](len);
        saleNums = new uint256[](len);
        for (uint256 i; i < len; i++) {
            SaleInfo storage sale = _saleInfo[i];
            prices[i] = sale.price;
            qtyNums[i] = sale.qty;
            saleNums[i] = sale.saleNum;
        }
    }

    function shopInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        bool pauseBuy, uint256 totalUsdt, uint256 totalInviteUsdt
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        pauseBuy = _pauseBuy;
        totalUsdt = _totalUsdt;
        totalInviteUsdt = _totalInviteUsdt;
    }

    function getUserInfo(address account) external view returns (
        uint256 usdtBalance, uint256 usdtAllowance,
        uint256 buyUsdtAmount, uint256 inviteUsdt,
        bool isActive, address invitor,
        uint256 teamNum, uint256 teamAmount,
        uint256 buyNodeId, uint256 binderLen
    ){
        usdtBalance = IERC20(_usdtAddress).balanceOf(account);
        usdtAllowance = IERC20(_usdtAddress).allowance(account, address(this));
        UserInfo storage userInfo = _userInfo[account];
        buyUsdtAmount = userInfo.buyUsdtAmount;
        inviteUsdt = userInfo.inviteUsdt;
        isActive = userInfo.isActive;
        invitor = _invitor[account];
        teamNum = userInfo.teamNum;
        teamAmount = userInfo.teamAmount;
        buyNodeId = userInfo.buyNodeId;
        binderLen = getBinderLength(account);
    }

    function getBuyListLength(uint256 saleId) public view returns (uint256){
        return _buyList[saleId].length;
    }

    function getBuyList(uint256 saleId) public view returns (address[] memory){
        return _buyList[saleId];
    }

    function getBinderLength(address account) public view returns (uint256){
        return _binder[account].length;
    }

    function getBinderList(
        address account,
        uint256 start,
        uint256 length
    ) external view returns (
        uint256 returnCount,
        address[] memory binders,
        uint256[] memory binderTeamNums,
        uint256[] memory binderTeamAmounts,
        uint256[] memory binderLens
    ){
        address[] storage _binders = _binder[account];
        uint256 recordLen = _binders.length;
        if (0 == length) {
            length = recordLen;
        }
        returnCount = length;
        binders = new address[](length);
        binderTeamNums = new uint256[](length);
        binderTeamAmounts = new uint256[](length);
        binderLens = new uint256[](length);
        uint256 index = 0;
        address binder;
        for (uint256 i = start; i < start + length; i++) {
            if (i >= recordLen) {
                return (index, binders, binderTeamNums, binderTeamAmounts, binderLens);
            }
            binder = _binders[i];
            binders[index] = binder;
            binderTeamNums[index] = _userInfo[binder].teamNum;
            binderTeamAmounts[index] = _userInfo[binder].teamAmount;
            binderLens[index] = _binder[binder].length;
            index++;
        }
    }

    receive() external payable {}

    function addSale(uint256 usdtAmount, uint256 qty) external onlyOwner {
        _saleInfo.push(SaleInfo(usdtAmount, qty, 0));
    }

    function setPrice(uint256 saleId, uint256 price) external onlyOwner {
        _saleInfo[saleId].price = price;
    }

    function setQty(uint256 saleId, uint256 qty) external onlyOwner {
        _saleInfo[saleId].qty = qty;
    }

    function setUsdtAddress(address adr) external onlyOwner {
        _usdtAddress = adr;
    }

    function setCashAddress(address adr) external onlyOwner {
        _cashAddress = adr;
    }

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    //
    function setInviteFee(uint256 i, uint256 fee) external onlyOwner {
        _inviteFee[i] = fee;
    }

    function setInviteRewardLen(uint256 len) external onlyOwner {
        _inviteRewardLen = len;
    }

    function setTeamLen(uint256 len) external onlyOwner {
        _teamLen = len;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        safeTransferETH(to, amount);
    }

    function claimToken(address token, address to, uint256 amount) external onlyOwner {
        _giveToken(token, to, amount);
    }

    mapping(address => bool) public _inProject;

    function setInProject(address adr, bool enable) external onlyOwner {
        _inProject[adr] = enable;
    }

    function bindInvitor(address account, address invitor) public {
        address caller = msg.sender;
        require(_inProject[caller], "NJ");
        _bindInvitor(account, invitor);
    }
}

contract NodeSale is AbsPreSale {
    constructor() AbsPreSale(
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Cash
        address(0x816722B3Cb31FB231a7733CF183c29a07ad9f4d7)
    ){

    }
}