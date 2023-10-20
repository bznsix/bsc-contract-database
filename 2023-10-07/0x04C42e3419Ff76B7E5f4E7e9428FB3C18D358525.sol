// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "./CoinsTrailCore.sol";
/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */

contract CoinsTrailActivation is CoinsTrailCore {

    constructor(){}

    // free Member Registration
    function joinFree (address _refBy) public nonReentrant {
        address _sender = msg.sender;
        if(users[_sender].uid == 0 || users[_sender].sponsor == address(0)){
            register(_sender, _refBy);
        }
        User storage _user = users[msg.sender];
        _user.earningCap   = ECAPS[0];
        _user.daysLeft     = EXPIR[0];
        _user.lastRecord   = block.timestamp;
    }

    // activate pack
    function activateAcc (address _refBy, uint8 _packId) public nonReentrant packExists(_packId) {
        address _sender = msg.sender;
        if(users[_sender].uid == 0 || users[_sender].sponsor == address(0)){
            register(_sender, _refBy);
        }

        uint _packValue = PACKS[_packId]; // usdt Value

        // get usdt Value
        uint oneCTRLtoUSDT = getTokenAmount(address(_ctrlToken), address(_usdToken), (1 ether / MLTIPLR));

        uint _ctrlValue = _packValue / (oneCTRLtoUSDT * MLTIPLR);
        require (_ctrlToken.transferFrom(_sender, address(this), _ctrlValue));
        // activate Pack 
        processActivation (_sender, _packId, _ctrlValue);
        emit NewPackActivation(_sender, _packId, _ctrlValue);
    }

    // withdraw usdt
    function withdrawEarnings (uint _amount) public nonReentrant minWithd(_amount) onlyActive hasBalance(_amount) {
        User storage _user = users[msg.sender];
        require(_amount < _usdToken.balanceOf(address(this)));
        _user.balance -= _amount;
        stats.totalBalance   -= _amount;
        stats.totalWithdrawn += _amount;
        require(_usdToken.transfer(msg.sender, _amount));
        emit Withdrawan (msg.sender, _amount);
    }

    // withdraw Initial
    function withdrawCapital (uint _actId) public nonReentrant activationExists(_actId) exprdActivation(_actId)  unClaimedActivation(_actId) {
        users[msg.sender].activations[_actId]._claimed = true;
        uint _amount = users[msg.sender].activations[_actId]._amount;
        // sent USDT
        require(_usdToken.balanceOf(address(this)) > _amount);
        require(_usdToken.transfer(msg.sender, _amount));
        emit ReleasedInit(msg.sender, _actId, _amount);
    }

    // record click [once daily]
    function recordDailyClick (uint _sysId) public nonReentrant onlyActive canEarn allowDaily{
        User storage _user = users[msg.sender];
        uint _reward            = getDailyRewrd(_user);
        _user.balance          += _reward;
        _user.earningCap       -= _reward;
        _user.earningsCredited -= _reward;
        _user.lastRecord        = block.timestamp; // updates once daily
        _user.daysLeft--;
        if(_user.earningCap == 0) _user.daysLeft = 0;
        emit NewRecord (msg.sender, _sysId, _reward);
        stats.totalBalance     += _reward;
        // pay affiliate commissions
        dipatchCommission(msg.sender, _reward);
    }

    function activations(address _sender) public view returns(Activation[] memory _activations){
        _activations = users[_sender].activations;
    }
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "./ReentrancyGuard.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */

contract CoinsTrailCore is ReentrancyGuard{
    using SafeERC20 for IERC20;
    using Address for address;
    IERC20 public immutable _ctrlToken;
    IERC20 internal immutable _usdToken;
    IERC20 internal immutable _wbnbToken;
    IUniswapRouter public immutable uniswapRouter;
    address internal immutable dev;
    
    // System Settings [on buying tokens]
    address internal immutable adminReserve; // 40%
    address internal immutable marketing; // 10 %
    address internal immutable teamAndLegal; // 20% 
    uint internal constant MLTIPLR = 1000000000;
    uint internal constant DECIMAL = 1e18;
    uint internal constant DIVIDER = 10000;
    uint internal constant COMMISSION = 100; // 1% on each level for daily clicks 
    // Pack Activation = 15% marketing, 10% burns, 75% liquidity
    uint internal constant ACTIVATION_BURNS = 1000; // 10% burns on activation
    uint internal constant ACTIVATION_MRKTG = 1500; // 15% goes to marketing wallet
    uint internal constant ACTIVATION_RSRVD = 3000; // 30% goes to liquidty reserve
    uint internal constant ACVTION_LQTYAMNT = 8000; // 80% sold from liquidty reserve
    uint internal constant PURCHASE_SYSRSVD = 4000; // 40% goes to system reserve wallet
    uint internal constant PURCHASE_SYSADMN = 2000; // 20% goes to team/legal
    uint internal constant MINWDRW          = 10 ether;
    uint internal constant TRIGGER          = 500 ether;
    // system config
    uint[] internal PACKS = [0 ether, 50 ether, 100 ether, 250 ether, 500 ether, 1000 ether, 2500 ether, 5000 ether, 10000 ether];
    uint[] internal ECAPS = [5 ether, 10 ether, 25 ether, 75 ether, 175 ether, 500 ether, 1625 ether, 3750 ether, 10000 ether];
    uint[] internal EXPIR = [30, 21, 30, 30, 45, 60, 65, 90, 90]; // number of activities days for each packs
    uint[] internal COMMI = [0, 3, 5, 6, 10, 10, 12, 15, 15]; // Max Earning Levels for each packs 3 to 15 levels
    uint internal constant DAILY = 24 hours;
    bool internal enabled; // enable/disable activations
    uint internal _lstRqt;

    // user structure
    struct User{
        uint uid; // unique user id
        address sponsor;
        uint balance; // active usdt balance
        uint earningsCredited; // total credited
        uint commissionEarned; // updates on click records
        uint earningCap; // updates on activation
        uint8 currentPack; // [Last pack activated] 
        uint totalActivation; // total token spent
        uint tokenPurchased; // total ctrl purchased
        uint tokenSold; // total ctrl sold
        uint daysLeft; // activities days left
        uint lastRecord;
        Activation[] activations;
    }

    struct Stats{
        uint totalUsers;
        uint totalActivation; // total in ctrl
        uint totalPurchased; // ctrl
        uint totalSold; // ctrl
        uint totalBalance; // total usdt to pay
        uint totalWithdrawn; // total usdt
        uint totalUSDTactivation; // total activation in usdt
        uint activationToLqty; // resets every $500
        uint amountToLqty; // resets every $500 sold
    }

    struct Request {
        uint uid;
        address _rqtdBy; // requester [only dev]
        address _destan; // destination
        uint _tfxAmount; // amount to transfer
        string _purpose; // request reasons/comment
        uint _validations; // total validations [45% of users]
        IERC20 _token; // USDT or CTRL
        string _tokenName;
        bool _isProcessed;
    }

    struct Activation{
        uint _amount;
        uint _expird;
        bool _claimed;
    }
    
    /*// Advertisers
    struct Advertiser{
        uint uid; // unique identifier
        uint credit; // total usdt credits
        Ads[] ads;
    }
    // ads record
    struct Ads{
        uint uid; // unique ad id
        string adRef; // ad referrence
        uint credit; // cpc [usdt cost per click]
        uint avCredit; // max usdt to spend
        bool status;
    }*/

    mapping (address => User) public users;

    mapping (uint => Request) public requests;

    mapping (address => mapping(uint => bool)) public votes;

    Stats public stats;

    bool private inSwapAndLiquify;
    
    // Only Members
    modifier isMember () {
        require(users[msg.sender].uid > 0);
        _;
    }

    // only Active User
    modifier onlyActive (){
        require(users[msg.sender].daysLeft > 0);
        _;
    }

    // existing activation 
    modifier activationExists (uint _actId) {
        require(users[msg.sender].activations.length > _actId);
        _;
    }

    // activation has expired
    modifier exprdActivation (uint _actId) {
        require(users[msg.sender].activations.length > _actId 
            && users[msg.sender].activations[_actId]._expird <= block.timestamp);
        _;
    }

    // activation has notBeen Claimed
    modifier unClaimedActivation (uint _actId) {
        require(users[msg.sender].activations.length > _actId 
            && users[msg.sender].activations[_actId]._expird <= block.timestamp
            && !users[msg.sender].activations[_actId]._claimed);
        _;
    }

    // Can Earn
    modifier canEarn () {
        require(users[msg.sender].earningCap > 0);
        _;
    }
    // Daily Record
    modifier allowDaily () {
        require(users[msg.sender].lastRecord + DAILY <= block.timestamp);
        _;
    }
    // Has balance
    modifier hasBalance (uint _amount) {
        require (users[msg.sender].balance >= _amount);
        _;
    }
    // Minimum Withdrawal
    modifier minWithd (uint _amount) {
        require(_amount >= MINWDRW);
        _;
    }
    // Valid Pack
    modifier packExists (uint8 _packId) {
        require (_packId < PACKS.length);
        _;
    }
    // Only Dev
    modifier onlyDev () {
        require (msg.sender == dev);
        _;
    }   
    // Request Exist
    modifier rqtExists (uint _rqtId) {
        require (requests[_rqtId].uid == _rqtId);
        _;
    }
    // User Has not yet Voted
    modifier hasNotVotd (uint _rqtId) {
        require (!votes[msg.sender][_rqtId]);
        _;
    }
    // User Has Voted
    modifier hasVotd (uint _rqtId) {
        require (votes[msg.sender][_rqtId]);
        _;
    }
    // Request Has Enough Votes
    modifier hasEnoughVotes (uint _rqtId) {
        // require ((requests[_rqtId]._validations / stats.totalUsers) * DIVIDER >= 4500, 'rq45%');
        require (requests[_rqtId]._validations >= 2);
        _;
    }
    // Request Has been processed
    modifier hasNotBeenPrcsd (uint _rqtId) {
        require (!requests[_rqtId]._isProcessed);
        _;
    }
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    // events
    // new user
    event NewUser (address indexed _sender, address indexed _refBy);
    // pack activation
    event NewPackActivation (address indexed _sender, uint indexed _packId, uint _tokenSpent);
    // Daily click recorded 
    event NewRecord (address indexed _sender, uint indexed _sysId, uint _earnings);
    // commission earned
    event CommissionEarned (address indexed _benefactor, address _from, uint indexed _level, uint _amount);
    // successful withdrawal
    event Withdrawan (address indexed _sender, uint _amount);
    // successful released 
    event ReleasedInit(address indexed _sender, uint _activationId, uint _amount);
    // token purchased
    event TokenPurchased (address indexed _sender, uint _amount);
    // token sold
    event Tokensold (address indexed _sender, uint _amount);   
    // token Sent
    event TokenSent(address indexed _sender, uint amount);
    // token burned
    event BurnCTRL(uint amount);
    
    // CTRL/USDT transfer Initiated
    event TransferInitiated (address indexed _sender, address indexed _destination, uint _amount, string _reason, string _token);
    // CTRL/USDT transfer validation
    event TransferVlidatd (address indexed _sender, uint indexed _tfxid);
    // CTRL/USDT transfer validation revoqued
    event ValidationRvoqd (address indexed _sender, uint indexed _tfxid);
    // Transfer Request processed
    event TransferProcessed (uint indexed _tfxId, uint _amount, address indexed _to, string _token);

    constructor(){ dev = msg.sender; }

    // register user
    function register (address _sender, address _refBy) internal {
        User storage _user = users[msg.sender];
        if(_refBy == address(0) || _refBy == _sender || users[_refBy].uid == 0){
            _refBy = dev;
        }
        stats.totalUsers++;
        _user.uid = stats.totalUsers;
        _user.sponsor = _refBy;
    }

    function dispatchTokens (uint _amount) internal {
        // 15% marketing
        uint _marktg = _amount * ACTIVATION_MRKTG / DIVIDER;
        _ctrlToken.transfer(marketing, _marktg);
        // 10% burns
        uint _brn  = _amount * ACTIVATION_BURNS / DIVIDER;
        _ctrlToken.transfer(address(0), _brn);
        emit BurnCTRL(_brn);
        // get 30% liquity 
        stats.amountToLqty += _amount * ACTIVATION_RSRVD / DIVIDER;
        if(stats.activationToLqty >= TRIGGER){
            uint _lqtyAmount = stats.amountToLqty * ACVTION_LQTYAMNT / DIVIDER;
            swapAndLiquify(_ctrlToken, _usdToken, _lqtyAmount);
            stats.amountToLqty -= _lqtyAmount;
            stats.activationToLqty -= TRIGGER;
        }
    }

    function dispatchFunds (uint _amount, bool _isToken) internal {
        // 40% sytem reserve
        uint _rsrvd = _amount * PURCHASE_SYSRSVD / DIVIDER;
        // 10% Marketing
        uint _maktg = _amount * ACTIVATION_BURNS / DIVIDER;
        // 20 system admin
        uint _dmnfd = _amount * PURCHASE_SYSADMN / DIVIDER;
        
        if (!_isToken){
            uint _contractBalance = _usdToken.balanceOf(address(this));
        // }
        // else {
            // payable(adminReserve).transfer(_rsrvd);
            // payable(marketing).transfer(_maktg);
            // payable(teamAndLegal).transfer(_dmnfd);
            // _amount -= (_rsrvd + _maktg + _dmnfd);
            swapBNBForUSDT(_amount);
            // USDT received
            _amount = _usdToken.balanceOf(address(this)) - _contractBalance;
        }

        _usdToken.transfer(adminReserve, _rsrvd);
        _usdToken.transfer(marketing, _maktg);
        _usdToken.transfer(teamAndLegal, _dmnfd);
    }

    function processActivation (address _sender, uint8 _packId, uint _tokens) internal {
        User storage _user = users[_sender];
        if(_user.currentPack < _packId) _user.currentPack = _packId;
        _user.earningCap       += ECAPS[_packId];
        _user.daysLeft         += EXPIR[_packId];
        _user.totalActivation  += _tokens; // total token spent
        _user.lastRecord        = block.timestamp;

        stats.totalActivation  += _tokens;
        stats.activationToLqty += PACKS[_packId];
        // dispatch tokens
        dispatchTokens(_tokens);
    }

    // process buy order
    function processBuy (address _sender, address _refBy, uint _amount) internal {
        if(users[_sender].uid == 0 || users[_sender].sponsor == address(0)){
            register(_sender, _refBy);
        }
        uint _tokenAmount = (_amount / getTokenPrice()) * DECIMAL;
        users[_sender].tokenPurchased += _tokenAmount;
        require(_ctrlToken.transfer(_sender, _tokenAmount), 'txferFailed');
        stats.totalPurchased += _tokenAmount;
        emit TokenPurchased (_sender, _tokenAmount);
        emit TokenSent(_sender, _tokenAmount);
    }

    function dipatchCommission(address _sender, uint _reward) internal {
        uint _comm = _reward * COMMISSION / DIVIDER;
        address _upline = users[_sender].sponsor;
        for(uint8 i = 0; i < 15; i++){
            if(_upline == address(0)) break;
            if(users[_upline].currentPack > 0 && COMMI[users[_upline].currentPack] > i){
                // pay commission here.
                users[_upline].balance          += _comm;
                users[_upline].earningCap       -= _comm;
                users[_upline].commissionEarned += _comm;
                stats.totalBalance              += _comm;
                emit CommissionEarned (_upline, _sender, i + 1, _comm);
            }
            _upline = users[_upline].sponsor;
        }
    }

    function getDailyRewrd(User memory _user) internal view returns(uint _reward) {
        uint8 _packId   = _user.currentPack;
        _reward       = ECAPS[_packId] / EXPIR[_packId];
        if(_user.earningCap < _reward) _reward = _user.earningCap;
    }

    // get TOKEN_USDT rate
    function getTokenAmount(
        address _tokenA,
        address _tokenB,
        uint _amountIn
    ) internal view returns (uint256 _tokens) {
        address[] memory path = new address[](2);
        path[0] = _tokenA;
        path[1] = _tokenB;
        uint[] memory amounts = uniswapRouter.getAmountsOut(_amountIn, path);
        return amounts[1];
    }

    function getTokenPrice () public view returns (uint){
        uint oneCTRLtoUSDT = getTokenAmount(address(_ctrlToken), address(_usdToken), (1 ether / MLTIPLR));
        return oneCTRLtoUSDT * MLTIPLR;
    }
    
    // swap available usd to bnb
    function swapAndLiquify(IERC20 _token1, IERC20 _token2, uint tokenAmount) internal lockTheSwap{
        // uint256 tokenAmount = _busdAddress.balanceOf(address(this));
        _token1.approve(address(uniswapRouter), tokenAmount);
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(_token1);
        path[1] = address(_token2);
        // path[1] = uniswapRouter.WETH();
        // make the swap
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        emit Tokensold(address(this), tokenAmount);
    }

    function swapBNBForUSDT(uint256 _amount) internal lockTheSwap{
        // Swap BNB to BUSD for contest rewards.
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = address(_usdToken);
        // make the swap
        uniswapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: _amount }(
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

interface IUniswapRouter {
    function WETH() external pure returns (address);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "./CoinsTrailMultiSig.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */

contract CoinsTrailEngine is CoinsTrailMultiSig{
    constructor(){
        adminReserve = address(0x3a2DF645850e6da7700Fb022015723eFaE4afD21);
        marketing = address(0x07821dC911eA9C6229E8844DE458535443B3C399);
        teamAndLegal = address(0xf653562815Ab51bB67baE3f9278D90269b5B0F22);        
        _usdToken  = IERC20(address(0x55d398326f99059fF775485246999027B3197955)); // testnet 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd 0xC6Efc0f7AF6e0B3e413d8FdD339FAf4d9a6e2D8F 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814 // mainnet 0x55d398326f99059fF775485246999027B3197955
        _ctrlToken = IERC20(address(0x3645c60ce5679c950D629D0BCcfecf9d9Bd6E3B8)); // tesnet 0x8724A3850Df4F65c43a67de65A7a4ddA1FFc8F77 // mainnet 0x3645c60ce5679c950D629D0BCcfecf9d9Bd6E3B8
        _wbnbToken = IERC20(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)); // testnet 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd // mainnet 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
        IUniswapRouter _uniswapV2Router = IUniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // testnet 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 // mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
        uniswapRouter = _uniswapV2Router;
    }

    // buy ctrl
    function buyCTRLBNB (address _refBy) public payable nonReentrant{
        address _sender = msg.sender;
        uint _amount = msg.value;
        // get usdt Value
        uint _usdtvalue = _amount * getTokenPrice() / DECIMAL;
        // dispatch funds
        dispatchFunds(_amount, false);
        processBuy(_sender, _refBy, _usdtvalue);
    }

    function buyCTRLUSDT (address _refBy, uint _amount) public nonReentrant {
        address _sender = msg.sender;
        require (_usdToken.transferFrom(_sender, address(this), _amount));
        // dispatch funds
        dispatchFunds (_amount, true);
        processBuy(_sender, _refBy, _amount);
    }

    function toggleActivation() public onlyDev {
        enabled = !enabled;
    }
    
    // fallback function [ ability to receive bnb]
    receive() external payable {
        // swap bnb to ether
        swapBNBForUSDT(msg.value);
    }
    
    /* To do on next upgrade
    * sell ctrl
    * create ads
    * edit ad
    * record clicks based on ads
    */
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "./CoinsTrailActivation.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */

contract CoinsTrailMultiSig is CoinsTrailActivation{
    constructor(){}
    
    function requestFunds(address _dest, uint _amount, string memory _reason, bool _isToken) public nonReentrant onlyDev {
        require(_dest != address(0));
        string memory _token;
        if(_isToken) {
            require (_amount <= _ctrlToken.balanceOf(address(this)));
             _token = "CTRL";
        }
        else {
            require (_amount <= _usdToken.balanceOf(address(this)));
             _token = "USDT";
        }

        _lstRqt++;
        Request storage _request = requests[_lstRqt];

        _request.uid             = _lstRqt;
        _request._rqtdBy         = msg.sender; // requester [only dev]
        _request._destan         = _dest; // destination
        _request._tfxAmount      = _amount; // amount to transfer
        _request._purpose        = _reason; // request reasons/comment
        _request._validations    = 1; // total validations [45% of users]
        _request._token          = _isToken ? _ctrlToken : _usdToken; // USDT or CTRL
        _request._tokenName      = _token; // USDT or CTRL
        _request._isProcessed    = false;
        emit TransferInitiated (msg.sender, _dest, _amount, _reason, _token);
    }

    // vote
    function approveTransfer (uint _rqtId) public nonReentrant isMember rqtExists(_rqtId) hasNotVotd(_rqtId) hasNotBeenPrcsd(_rqtId){
        Request storage _request = requests[_rqtId];
        _request._validations++;
        votes[msg.sender][_rqtId] = true;
        emit TransferVlidatd (msg.sender, _rqtId);
    }

    // revoque vote
    function revoqueVote (uint _rqtId) public nonReentrant isMember rqtExists(_rqtId) hasVotd(_rqtId) hasNotBeenPrcsd(_rqtId) {
        Request storage _request = requests[_rqtId];
        _request._validations--;
        votes[msg.sender][_rqtId] = false;
        emit ValidationRvoqd (msg.sender, _rqtId);
    }

    // process transfer
    function processTransfer(uint _rqtId) public nonReentrant rqtExists(_rqtId) hasNotBeenPrcsd(_rqtId) {
        Request storage _request = requests[_rqtId];
        _request._isProcessed = true;
        uint _amount          = _request._tfxAmount;
        IERC20 _token         = _request._token;
        require(_token.balanceOf(address(this)) >= _amount);
        require(_token.transfer(_request._destan, _amount));
        
        emit TransferProcessed (_rqtId, _amount, _request._destan, _request._tokenName);
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */

contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}