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
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

abstract contract AbsPool is Ownable {
    struct UserInfo {
        uint256 accUsdt;
        uint256 amount;
        uint256 rewardLPDebt;
        uint256 calLPReward;
        uint256 publicRowReward;
        uint256 inviteReward;
        uint256 accPoolReward;
        uint256 accPublicRowReward;
        uint256 accInviteReward;
    }

    struct PoolInfo {
        uint256 totalAmount;
        uint256 accLPPerShare;
        uint256 accLPReward;
    }

    PoolInfo private _poolInfo;
    mapping(address => UserInfo) private _userInfo;

    ISwapRouter public immutable _swapRouter;
    address public immutable _weth;
    address public immutable _usdt;
    address public immutable _jts;
    address public immutable _token;
    address public immutable _wethUSDTLP;
    address public immutable _wethJTSLP;
    address public immutable _jtsTokenLP;
    address[] public _userList;
    mapping(address => uint256) public userIndex;
    mapping(address => address) public _invitor;
    mapping(address => mapping(uint256 => address[])) public _levelBinders;
    uint256 private constant _inviteLength = 2;
    bool public _pause;
    uint256 public _activePrice;
    address public _fundD;
    address public _fundE;
    address public _fundF;
    address public _fundG;
    uint256 private constant _rewardDiv = 1e12;
    uint256 private constant _publicRow = 20;
    mapping(address => bool) public _whileList;
    uint256 public _activePoolAmountRate = 100;
    uint256 private constant _activeUserRate = 20;
    uint256 private constant _activePoolRate = 15;
    uint256 private constant _activeInviteRate = 20;
    uint256 private constant _activeInvite2Rate = 5;
    uint256 private constant _activePublicRowRate = 40;
    uint256 private constant _buyUserRate = 80;
    uint256 private constant _buyPoolRate = 10;
    uint256 private constant _buyInviteRate = 10;
    uint256 public _buyPoolAmountRate = 150;
    uint256 public _sellUserRate = 97;
    uint256 public _claimHoldCondition;

    constructor(
        address SwapRouter, address USDT, address JTS, address Token,
        address FundD, address FundE, address FundF, address FundG
    ){
        _swapRouter = ISwapRouter(SwapRouter);
        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _weth = _swapRouter.WETH();
        _usdt = USDT;
        _jts = JTS;
        _token = Token;
        _wethUSDTLP = swapFactory.getPair(_usdt, _weth);
        _wethJTSLP = swapFactory.getPair(_jts, _weth);
        require(address(0) != _wethUSDTLP, "wethUSDTLP");
        require(address(0) != _wethJTSLP, "wethJTSLP");
        address jtsTokenLP = swapFactory.getPair(_jts, _token);
        if (address(0) == jtsTokenLP) {
            jtsTokenLP = swapFactory.createPair(_jts, _token);
        }
        _jtsTokenLP = jtsTokenLP;
        _fundD = FundD;
        _fundE = FundE;
        _fundF = FundF;
        _fundG = FundG;
        _addUser(address(0), address(0));
        _addUser(FundD, address(0));
        _addUser(FundE, FundD);
        _addUser(FundF, FundE);
        _addUser(FundG, FundF);

        _whileList[FundD] = true;
        _whileList[FundE] = true;
        _whileList[FundF] = true;
        _whileList[FundG] = true;

        uint256 usdtUnit = 10 ** IERC20(_usdt).decimals();
        _activePrice = 50 * usdtUnit;
        _claimHoldCondition = 10 * usdtUnit;
    }

    function active(address invitor) external {
        require(!_pause, "Pause");
        address account = msg.sender;
        require(account == tx.origin, "ori");
        require(0 == userIndex[account], "active");
        require(0 != userIndex[invitor], "!invitor");
        _addUser(account, invitor);

        uint256 usdtAmount = _activePrice;
        uint256 jtsAmount = getJTSAmount(usdtAmount);
        uint liquidity = _mintLP(account, jtsAmount);

        _giveToken(_jtsTokenLP, account, liquidity * _activeUserRate / 100);
        _addPoolReward(liquidity * _activePoolRate / 100);

        uint256 totalInviteReward = liquidity * (_activeInviteRate + _activeInvite2Rate) / 100;
        address current = account;
        uint256 rewardLPCondition = canRewardLPCondition();
        for (uint256 i = 0; i < _inviteLength; ++i) {
            invitor = _invitor[current];
            if (address(0) == invitor) {
                break;
            }
            if (IERC20(_jtsTokenLP).balanceOf(invitor) >= rewardLPCondition) {
                UserInfo storage invitorInfo = _userInfo[invitor];
                uint256 accUsdt = invitorInfo.accUsdt;
                uint256 inviteLiquidity = liquidity * (0 == i ? _activeInviteRate : _activeInvite2Rate) / 100;
                if (accUsdt < usdtAmount) {
                    inviteLiquidity = inviteLiquidity * accUsdt / usdtAmount;
                }
                totalInviteReward -= inviteLiquidity;
                invitorInfo.inviteReward += inviteLiquidity;
            }

            current = invitor;
        }
        _addFundInviteReward(totalInviteReward);

        uint256 totalPublicRowReward = liquidity * _activePublicRowRate / 100;
        uint256 publicRowReward = totalPublicRowReward / 20;
        uint256 parentIndex = userIndex[account] / 2;
        address parentAddress;
        for (uint256 i; i < _publicRow;) {
            if (0 == parentIndex) {
                break;
            }
            parentAddress = _userList[parentIndex];
            if (IERC20(_jtsTokenLP).balanceOf(parentAddress) >= rewardLPCondition) {
                _userInfo[parentAddress].publicRowReward += publicRowReward;
                totalPublicRowReward -= publicRowReward;
            }
        unchecked{
            parentIndex = parentIndex / 2;
            ++i;
        }
        }
        _addFundPublicRowReward(totalPublicRowReward);

        uint256 amount = usdtAmount * _activePoolAmountRate / 100;
        _updateUserPoolInfo(account, usdtAmount, amount);
    }

    function buy(uint256 jtsAmount) external {
        require(!_pause, "Pause");
        address account = msg.sender;
        require(account == tx.origin, "ori");
        require(0 != userIndex[account], "!active");

        uint256 usdtAmount = getUsdtAmount(jtsAmount);
        uint liquidity = _mintLP(account, jtsAmount);

        _giveToken(_jtsTokenLP, account, liquidity * _buyUserRate / 100);
        _addPoolReward(liquidity * _buyPoolRate / 100);
        uint256 rewardLPCondition = canRewardLPCondition();
        uint256 totalInviteReward = liquidity * _buyInviteRate / 100;
        address invitor = _invitor[account];
        if (address(0) != invitor) {
            if (IERC20(_jtsTokenLP).balanceOf(invitor) >= rewardLPCondition) {
                UserInfo storage invitorInfo = _userInfo[invitor];
                uint256 accUsdt = invitorInfo.accUsdt;
                uint256 inviteLiquidity = totalInviteReward;
                if (accUsdt < usdtAmount) {
                    inviteLiquidity = inviteLiquidity * accUsdt / usdtAmount;
                }
                totalInviteReward -= inviteLiquidity;
                invitorInfo.inviteReward += inviteLiquidity;
            }
        }

        _addFundInviteReward(totalInviteReward);

        uint256 amount = usdtAmount * _buyPoolAmountRate / 100;
        _updateUserPoolInfo(account, usdtAmount, amount);
    }

    function _addFundInviteReward(uint256 reward) private {
        if (reward > 0) {
            _userInfo[_fundD].inviteReward += reward * 80 / 100;
            _userInfo[_fundF].inviteReward += reward * 20 / 100;
        }
    }

    function _addFundPoolReward(uint256 reward) private {
        if (reward > 0) {
            _userInfo[_fundE].calLPReward += reward;
        }
    }

    function _addFundPublicRowReward(uint256 reward) private {
        if (reward > 0) {
            _userInfo[_fundG].publicRowReward += reward;
        }
    }

    function claim(address account) external {
        address msgSender = msg.sender;
        require(msgSender == tx.origin, "ori");
        require(msgSender == account || _whileList[msgSender], "Self");
        UserInfo storage userInfo = _userInfo[account];
        uint256 poolReward = userInfo.calLPReward;
        if (poolReward > 0) {
            userInfo.calLPReward = 0;
        }
        (uint256 accReward, uint256 pendingReward) = _calUserPoolReward(account);
        if (pendingReward > 0) {
            userInfo.rewardLPDebt = accReward;
            poolReward += pendingReward;
        }
        uint256 inviteReward = userInfo.inviteReward;
        if (inviteReward > 0) {
            userInfo.inviteReward = 0;
        }
        uint256 publicRowReward = userInfo.publicRowReward;
        if (publicRowReward > 0) {
            userInfo.publicRowReward = 0;
        }
        uint256 rewardLPCondition = canRewardLPCondition();
        if (IERC20(_jtsTokenLP).balanceOf(account) >= rewardLPCondition || _whileList[account]) {
            _giveToken(_jtsTokenLP, account, publicRowReward + inviteReward + poolReward);
            userInfo.accPoolReward += poolReward;
            userInfo.accPublicRowReward += publicRowReward;
            userInfo.accInviteReward += inviteReward;
        } else {
            _addFundInviteReward(inviteReward);
            _addFundPoolReward(poolReward);
            _addFundPublicRowReward(publicRowReward);
        }
    }

    function canRewardLPCondition() public view returns (uint256){
        uint256 holdCondition = getJTSAmount(_claimHoldCondition / 2);
        (uint256 rJts,) = getJTSTokenReserves();
        uint256 totalLiquidity = IERC20(_jtsTokenLP).totalSupply();
        return totalLiquidity * holdCondition / rJts;
    }

    function sell(uint256 liquidity) external {
        require(!_pause, "Pause");
        address account = msg.sender;
        require(account == tx.origin, "ori");
        require(0 != userIndex[account], "!active");
        _takeToken(_jtsTokenLP, account, _jtsTokenLP, liquidity);
        (uint256 amount0, uint256 amount1) = ISwapPair(_jtsTokenLP).burn(address(this));
        uint256 jtsAmount;
        uint256 tokenAmount;
        if (_jts < _token) {
            jtsAmount = amount0;
            tokenAmount = amount1;
        } else {
            jtsAmount = amount1;
            tokenAmount = amount0;
        }

        _giveToken(_token, address(0x000000000000000000000000000000000000dEaD), tokenAmount);
        uint256 userJtsAmount = jtsAmount * _sellUserRate / 100;
        _giveToken(_jts, account, userJtsAmount);

        jtsAmount -= userJtsAmount;
        if (jtsAmount > 0) {
            _buyToken(jtsAmount, address(0x000000000000000000000000000000000000dEaD));
        }
    }

    function getJTSAmount(uint256 usdtAmount) public view returns (uint256 jtsAmount){
        uint256 rEth;
        uint256 rUsdt;
        uint256 rJts;
        (rEth, rUsdt) = getETHUSDTReserves();
        uint256 ethAmount = usdtAmount * rEth / rUsdt;
        (rEth, rJts) = getETHJTSReserves();
        jtsAmount = ethAmount * rJts / rEth;
    }

    function getUsdtAmount(uint256 jtsAmount) public view returns (uint256 usdtAmount){
        (uint256 rEth, uint256 rJts) = getETHJTSReserves();
        uint256 jtsEthAmount = jtsAmount * rEth / rJts;
        uint256 rUsdt;
        (rEth, rUsdt) = getETHUSDTReserves();
        usdtAmount = jtsEthAmount * rUsdt / rEth;
    }

    function getJTSPrice() public view returns (uint256 jtsPrice){
        (uint256 rEth, uint256 rJts) = getETHJTSReserves();
        uint256 jtsEthPrice = 10 ** IERC20(_jts).decimals() * rEth / rJts;
        uint256 rUsdt;
        (rEth, rUsdt) = getETHUSDTReserves();
        jtsPrice = jtsEthPrice * rUsdt / rEth;
    }

    function getTokenPrice() public view returns (uint256 tokenPrice){
        (uint256 rJts, uint256 rToken) = getJTSTokenReserves();
        if (0 == rToken) {
            return 0;
        }
        uint256 tokenJtsPrice = 10 ** IERC20(_token).decimals() * rJts / rToken;
        uint256 rEth;
        (rEth, rJts) = getETHJTSReserves();
        uint256 tokenEthPrice = tokenJtsPrice * rEth / rJts;
        uint256 rUsdt;
        (rEth, rUsdt) = getETHUSDTReserves();
        tokenPrice = tokenEthPrice * rUsdt / rEth;
    }

    function getJtsTokenLPPrice() public view returns (uint256 jtsAmount){
        uint256 totalLP = IERC20(_jtsTokenLP).totalSupply();
        if (0 == totalLP) {
            return 0;
        }
        (uint256 rJts,) = getJTSTokenReserves();
        jtsAmount = 10 ** 18 * rJts / totalLP;
    }

    function getEthPrice() public view returns (uint256 ethPrice){
        (uint256 rEth, uint256 rUsdt) = getETHUSDTReserves();
        ethPrice = 1 ether * rUsdt / rEth;
    }

    function getETHUSDTReserves() public view returns (uint256 rEth, uint256 rUsdt){
        (uint256 r0, uint256 r1,) = ISwapPair(_wethUSDTLP).getReserves();
        if (_weth < _usdt) {
            rEth = r0;
            rUsdt = r1;
        } else {
            rEth = r1;
            rUsdt = r0;
        }
    }

    function getETHJTSReserves() public view returns (uint256 rEth, uint256 rJts){
        (uint256 r0, uint256 r1,) = ISwapPair(_wethJTSLP).getReserves();
        if (_weth < _jts) {
            rEth = r0;
            rJts = r1;
        } else {
            rEth = r1;
            rJts = r0;
        }
    }

    function getJTSTokenReserves() public view returns (uint256 rJts, uint256 rToken){
        (uint256 r0, uint256 r1,) = ISwapPair(_jtsTokenLP).getReserves();
        if (_jts < _token) {
            rJts = r0;
            rToken = r1;
        } else {
            rJts = r1;
            rToken = r0;
        }
    }

    function _mintLP(address account, uint256 jtsAmount) private returns (uint liquidity){
        _takeToken(_jts, account, address(this), jtsAmount);

        uint256 buyAmount = jtsAmount / 2;
        uint256 tokenAmount = _buyToken(buyAmount, address(this));

        _giveToken(_jts, _jtsTokenLP, jtsAmount - buyAmount);
        _giveToken(_token, _jtsTokenLP, tokenAmount);
        liquidity = ISwapPair(_jtsTokenLP).mint(address(this));
    }

    function _buyToken(uint256 buyAmount, address to) private returns (uint256 tokenAmount){
        address[] memory path = new address[](2);
        path[0] = _jts;
        path[1] = _token;
        tokenAmount = _swapRouter.getAmountsOut(buyAmount, path)[1];
        _giveToken(_jts, _jtsTokenLP, buyAmount);
        if (_jts < _token) {
            ISwapPair(_jtsTokenLP).swap(0, tokenAmount, to, new bytes(0));
        } else {
            ISwapPair(_jtsTokenLP).swap(tokenAmount, 0, to, new bytes(0));
        }
    }

    function _addPoolReward(uint256 reward) private {
        _poolInfo.accLPReward += reward;
        uint256 totalAmount = _poolInfo.totalAmount;
        if (totalAmount > 0) {
            _poolInfo.accLPPerShare += reward * _rewardDiv / totalAmount;
        } else {
            _addFundPoolReward(reward);
        }
    }

    function _updateUserPoolInfo(address account, uint256 usdtAmount, uint256 amount) private {
        (, uint256 pendingReward) = _calUserPoolReward(account);
        _poolInfo.totalAmount += amount;
        UserInfo storage userInfo = _userInfo[account];
        if (pendingReward > 0) {
            userInfo.calLPReward += pendingReward;
        }
        userInfo.accUsdt += usdtAmount;
        userInfo.amount += amount;
        userInfo.rewardLPDebt = userInfo.amount * _poolInfo.accLPPerShare / _rewardDiv;
    }

    function _calUserPoolReward(address account) private view returns (uint256 accReward, uint256 pendingReward){
        UserInfo storage userInfo = _userInfo[account];
        uint256 amount = userInfo.amount;
        if (amount > 0) {
            accReward = amount * _poolInfo.accLPPerShare / _rewardDiv;
            pendingReward = accReward - userInfo.rewardLPDebt;
        }
    }

    function _addUser(address account, address invitor) private {
        if (0 == userIndex[account]) {
            userIndex[account] = _userList.length;
            _userList.push(account);
        }

        _invitor[account] = invitor;
        address current = account;
        for (uint256 i = 0; i < _inviteLength;) {
            invitor = _invitor[current];
            if (address(0) == invitor) {
                break;
            }
            _levelBinders[invitor][i].push(account);
            current = invitor;
        unchecked{
            ++i;
        }
        }
    }

    function getUserListLength() public view returns (uint256){
        return _userList.length;
    }

    function _takeToken(address tokenAddress, address account, address to, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenBalance = token.balanceOf(to);
        token.transferFrom(account, to, amount);
        require(token.balanceOf(to) - tokenBalance >= amount, "TTF");
    }

    function _giveToken(address tokenAddress, address to, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        token.transfer(to, amount);
    }

    receive() external payable {}

    function getBinderLength(address account, uint256 level) public view returns (uint256){
        return _levelBinders[account][level].length;
    }

    function setPause(bool pause) external onlyOwner {
        _pause = pause;
    }

    function setActivePoolAmountRate(uint256 rate) external onlyOwner {
        _activePoolAmountRate = rate;
    }

    function setActivePrice(uint256 price) external onlyOwner {
        _activePrice = price;
    }

    function setClaimHoldCondition(uint256 c) external onlyOwner {
        _claimHoldCondition = c;
    }

    function setBuyPoolAmountRateRate(uint256 rate) external onlyOwner {
        _buyPoolAmountRate = rate;
    }

    function setSellUserRate(uint256 rate) external onlyOwner {
        _sellUserRate = rate;
    }

    function claimBalance(uint256 amount, address to) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function setFunD(address adr) external onlyOwner {
        _fundD = adr;
        _whileList[adr];
    }

    function setFunE(address adr) external onlyOwner {
        _fundE = adr;
        _whileList[adr];
    }

    function setFunF(address adr) external onlyOwner {
        _fundF = adr;
        _whileList[adr];
    }

    function setFunG(address adr) external onlyOwner {
        _fundG = adr;
        _whileList[adr];
    }

    function setWhileList(address adr, bool en) external onlyOwner {
        _whileList[adr] = en;
    }

    function searchIndex(uint256 index) public view returns (address){
        uint256 publicRowLen = getUserListLength();
        if (index >= publicRowLen) {
            return address(0);
        }
        return _userList[index];
    }

    function getPublicRowInfo(
        address account
    ) external view returns (
        uint256 index,
        uint256 publicRowReward,
        uint256 parentIndex,
        address parentAddress,
        uint256 leftIndex,
        address leftAddress,
        uint256 rightIndex,
        address rightAddress
    ){
        index = userIndex[account];
        publicRowReward = _userInfo[account].accPublicRowReward + _userInfo[account].publicRowReward;
        parentIndex = index / 2;
        parentAddress = _userList[parentIndex];
        if (0 < index) {
            uint256 len = _userList.length;
            leftIndex = index * 2;
            if (leftIndex < len) {
                leftAddress = _userList[leftIndex];
            }
            rightIndex = index * 2 + 1;
            if (rightIndex < len) {
                rightAddress = _userList[rightIndex];
            }
        }
    }

    function getBinderList(
        address account,
        uint256 level,
        uint256 start,
        uint256 len
    ) external view returns (
        address[] memory binderList
    ){
        address[] storage _binderList = _levelBinders[account][level];
        if (start > _binderList.length) {
            start = _binderList.length;
        }
        if (0 == len || len > _binderList.length - start) {
            len = _binderList.length - start;
        }
        binderList = new address[](len);
        uint256 index = 0;
        for (uint256 i = start; i < start + len; ++i) {
            address binder = _binderList[i];
            binderList[index] = binder;
            index++;
        }
    }

    function getUserList(
        uint256 start,
        uint256 len
    ) external view returns (
        address[] memory userList,
        uint256[] memory publicRowRewardList
    ){
        if (start > _userList.length) {
            start = _userList.length;
        }
        if (0 == len || len > _userList.length - start) {
            len = _userList.length - start;
        }
        userList = new address[](len);
        publicRowRewardList = new uint256[](len);
        uint256 index = 0;
        for (uint256 i = start; i < start + len; ++i) {
            address user = _userList[i];
            userList[index] = user;
            publicRowRewardList[index] = _userInfo[user].accPublicRowReward + _userInfo[user].publicRowReward;
            index++;
        }
    }

    function getBaseInfo() public view returns (
        address jtsAddress, address jtsTokenLPAddress,
        uint256 jtsPrice, uint256 tokenPrice, uint256 lpJtsUnitPrice,
        bool pause, uint256 publicRowLen, uint256 activePrice,
        uint256 buyUserRate, uint256 buyPoolAmountRate, uint256 sellUserRate,
        uint256 claimConditionJtsAmount, uint256 ethPrice
    ){
        jtsAddress = _jts;
        jtsTokenLPAddress = _jtsTokenLP;
        jtsPrice = getJTSPrice();
        tokenPrice = getTokenPrice();
        lpJtsUnitPrice = getJtsTokenLPPrice();
        pause = _pause;
        publicRowLen = getUserListLength();
        activePrice = _activePrice;
        buyUserRate = _buyUserRate;
        buyPoolAmountRate = _buyPoolAmountRate;
        sellUserRate = _sellUserRate;
        claimConditionJtsAmount = getJTSAmount(_claimHoldCondition / 2);
        ethPrice = getEthPrice();
    }

    function getPoolInfo() public view returns (
        uint256 totalAmount,
        uint256 accLPPerShare,
        uint256 accLPReward
    ){
        totalAmount = _poolInfo.totalAmount;
        accLPPerShare = _poolInfo.accLPPerShare;
        accLPReward = _poolInfo.accLPReward;
    }

    function getOriUserInfo(address account) public view returns (
        uint256 accUsdt,
        uint256 amount,
        uint256 rewardLPDebt,
        uint256 calLPReward,
        uint256 publicRowReward,
        uint256 inviteReward,
        uint256 accPoolReward,
        uint256 accPublicRowReward,
        uint256 accInviteReward
    ){
        UserInfo storage userInfo = _userInfo[account];
        accUsdt = userInfo.accUsdt;
        amount = userInfo.amount;
        rewardLPDebt = userInfo.rewardLPDebt;
        calLPReward = userInfo.calLPReward;
        publicRowReward = userInfo.publicRowReward;
        inviteReward = userInfo.inviteReward;
        accPoolReward = userInfo.accPoolReward;
        accPublicRowReward = userInfo.accPublicRowReward;
        accInviteReward = userInfo.accInviteReward;
    }

    function getUserInfo(address account) public view returns (
        uint256 accUsdt,
        uint256 amount,
        uint256 poolReward,
        uint256 publicRowReward,
        uint256 inviteReward,
        uint256 jtsBalance,
        uint256 jtsAllowance,
        uint256 lpBalance,
        uint256 lpAllowance,
        address invitor,
        uint256 binderLen,
        uint256 binderLen2
    ){
        UserInfo storage userInfo = _userInfo[account];
        accUsdt = userInfo.accUsdt;
        amount = userInfo.amount;
        (, poolReward) = _calUserPoolReward(account);
        poolReward += userInfo.calLPReward;
        publicRowReward = userInfo.publicRowReward;
        inviteReward = userInfo.inviteReward;
        jtsBalance = IERC20(_jts).balanceOf(account);
        jtsAllowance = IERC20(_jts).allowance(account, address(this));
        lpBalance = IERC20(_jtsTokenLP).balanceOf(account);
        lpAllowance = IERC20(_jtsTokenLP).allowance(account, address(this));
        invitor = _invitor[account];
        binderLen = getBinderLength(account, 0);
        binderLen2 = getBinderLength(account, 1);
    }
}

contract SwapPool is AbsPool {
    constructor() AbsPool(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        address(0x1D41ceD8b86421514fEB70D7dC7A0bFb0F7187d9),
        address(0xdDA6585EB8F35a38636e431367358c3A77c7350E),
        address(0xFACE7042ac06AF2e2a320473f5C2ef913B664f9C),
        address(0x547E7d44bbE0A1a523BeeE5ECb5bDA1264605a20),
        address(0x5D6Cb99a5E8BA05DCe16b61f39eA820a14C35D6A),
        address(0x1B1297dCc36958CF68018e5af62D5Dcbc6BD5985)
    ){

    }
}