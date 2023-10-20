// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;
import './ReentrancyGuard.sol';

contract CoinstTrailPresales is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    IERC20 internal immutable _wbnbToken;
    IERC20 internal immutable _usdToken;
    IERC20 public immutable _ctrlToken;
    address public immutable _sysOps; 
    address internal immutable dev;

    address internal immutable _stmrsrvd = address(0xf2Af1992a0C3E6278C26Cd95F40bA6cFE15649be); // multisig 40%
    address internal immutable _teamwrsrd = address(0x69862C2b3d3Fe5B8d2e7b13847400f962AB6feA2); // R&D 15% + Team 5% 
    address internal immutable _mrktgWlt = address(0x5AF8737fe7DFb7c264E8bA883a770F5CA2937C95); // multisig 10%

    IUniswapRouter public immutable uniswapRouter;

    // system config
    uint internal constant MLTIPLR = 1000000;
    uint internal constant DIVIDER = 10000;
    uint internal constant COMMISS = 500; // 5% 
    uint internal constant INLQDTY = 4000; // System Reserve 40% 
    uint internal constant MARKTNG = 1000; // Marketing Wallet 10% 
    uint internal constant STMLQTY = 2500; // System Liquity 25% 
    uint internal constant TEAMRSV = 2000; // 20% 
    uint internal constant MINPURC = 50 ether; // $50 minimum purchase
    uint internal constant INIPRIC = 0.0001 ether;
    uint internal constant PRVPRIC = 0.00001 ether; // 18 months Locked 
    uint internal constant DECIMAL = 1e18;
    uint internal constant SALEWDW = 30 days;
    uint internal constant PRVLCKT = 540 days;

    uint internal immutable STARTED = block.timestamp;

    uint public lastUserId;

    struct User {
        uint uid;
        address sponsor; 
        uint purchased; // total ctrl
        uint _lstVtd;
        uint spent; // total usdt worth
        uint earned; // total commissions in usdt
        mapping(uint => VestedToken) vestedTokens;
    }

    struct VestedToken {
        uint uid;
        uint _amount;
        bool _claimed;
        uint _release;
    }

    struct Stat {
        uint totalSold; // total ctrl sold
        uint totalVolm; // total usdt volume
        uint totalComm; // total commissions
    }

    bool private inSwapAndLiquify;

    mapping (address => User) public users;

    Stat public stats;

    modifier salesOpen() {
        require(block.timestamp < STARTED + SALEWDW, 'Sales Closed');
        _;
    }

    modifier isAllowed() {
        require(!address(msg.sender).isContract(), "NotAllowed");
        _;
    }

    modifier hasVested (uint _pchId) {
        require(users[msg.sender].vestedTokens[_pchId].uid == _pchId, 'NotFound');
        _;
    }

    modifier hasRdyVested (uint _pchId) {
        require(users[msg.sender].vestedTokens[_pchId].uid == _pchId && 
                users[msg.sender].vestedTokens[_pchId]._release <= block.timestamp, 'NotRdy');
        _;
    }

    modifier hasNclmdVested (uint _pchId) {
        require(users[msg.sender].vestedTokens[_pchId].uid == _pchId && 
                users[msg.sender].vestedTokens[_pchId]._release <= block.timestamp && 
                !users[msg.sender].vestedTokens[_pchId]._claimed
                , 'NotRdy');
        _;
    }
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    // Events [NewOrder, NewUser, TokenSent, CommissionSent]
    event NewUser(address indexed sender, address indexed sponsor);
    event NewOrder(address indexed sender, uint _amount, uint amount, string payoption);
    event TokenSent(address indexed sender, uint amount);
    event TokenVested(address indexed sender, uint amount);
    event VestedTokenClaimed(address indexed sender, uint pchId, uint amount);
    event CommissionSent(address indexed sender, uint amount);

    constructor(){
        dev = msg.sender;
        _sysOps    = address(0x04C42e3419Ff76B7E5f4E7e9428FB3C18D358525); // CTRL engine test 0xC4807d8A76316873484f0dE8a89E48D78B7467F2 mainnet 0x04C42e3419Ff76B7E5f4E7e9428FB3C18D358525
        _usdToken  = IERC20(address(0x55d398326f99059fF775485246999027B3197955)); // testnet 0xC6Efc0f7AF6e0B3e413d8FdD339FAf4d9a6e2D8F 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814 // mainnet 0x55d398326f99059fF775485246999027B3197955
        _wbnbToken = IERC20(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)); // testnet 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd // mainnet 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
        _ctrlToken = IERC20(address(0x3645c60ce5679c950D629D0BCcfecf9d9Bd6E3B8)); // tesnet 0x8724A3850Df4F65c43a67de65A7a4ddA1FFc8F77 // mainnet 0x3645c60ce5679c950D629D0BCcfecf9d9Bd6E3B8
        IUniswapRouter _uniswapV2Router = IUniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // testnet 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 // mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
        uniswapRouter = _uniswapV2Router;
    }

    // Register User
    function register(address _sender, address _sponsor) private{
        lastUserId++;
        if(_sender == _sponsor || _sponsor == address(0) || users[_sponsor].uid == 0) 
            _sponsor = dev;
        users[_sender].sponsor = _sponsor;
        users[_sender].uid = lastUserId;
        emit NewUser(_sender, _sponsor);
    }

    // Credit user
    function credit(address _sender, uint _amount, bool _vtdtkn) private{
        uint tokenPrice = _vtdtkn ? PRVPRIC : INIPRIC;
        uint _tokenAmount = (_amount / tokenPrice) * DECIMAL;
        users[_sender].purchased += _tokenAmount;
        users[_sender].spent += _amount;
        if(!_vtdtkn){
            require(_ctrlToken.transferFrom(dev, _sender, _tokenAmount), 'txferFailed');
            emit TokenSent(_sender, _tokenAmount);
        }
        else {
            require(_ctrlToken.transferFrom(dev, address(this), _tokenAmount), 'txferFailed');
            emit TokenSent(address(this), _tokenAmount);
            // Vested Token
            users[_sender]._lstVtd++;
            uint _lstVtd = users[_sender]._lstVtd;
            VestedToken memory newVestedToken = VestedToken({
                uid: _lstVtd,
                _amount : _tokenAmount,
                _claimed : false,
                _release : block.timestamp + PRVLCKT
            });
            users[_sender].vestedTokens[_lstVtd] = newVestedToken;
            
            emit TokenVested(_sender, _tokenAmount);
        }
        stats.totalSold += _tokenAmount;
        stats.totalVolm += _amount;
    }

    function disptachOrder(address _sender, uint _amount, bool _isUSDT) private{
        if(!_isUSDT){
            uint _contractBalance = _usdToken.balanceOf(address(this));
            swapBNBForUSDT(_amount);
            // USDT received
            _amount = _usdToken.balanceOf(address(this)) - _contractBalance;
        }
        // distribution
        uint _commission = _amount * COMMISS / DIVIDER; // 5%
        uint _mrktgservd = _amount * MARKTNG / DIVIDER; // 10%
        uint _initialLqt = _amount * INLQDTY / DIVIDER; // 40%
        uint _systmilLqt = _amount * STMLQTY / DIVIDER; // 25%
        // uint _projectmgt = _amount * PRJTRSC / DIVIDER; // 15%
        uint _teamRservd = _amount * TEAMRSV / DIVIDER; // 20%
        _usdToken.transfer(users[_sender].sponsor, _commission);
        _usdToken.transfer(_mrktgWlt, _mrktgservd);
        _usdToken.transfer(_stmrsrvd, _initialLqt);
        _usdToken.transfer(_sysOps, _systmilLqt);
        // _usdToken.transfer(_mangmntWlt, _projectmgt);
        _usdToken.transfer(_teamwrsrd, _teamRservd);
        emit CommissionSent(_sender, _commission);
        stats.totalComm += _commission;
    }

    // Process Order
    function processOrder(address _sender, address _sponsor, 
                        uint _amount, uint _usdtAmount, 
                        bool _isUSDT, bool _vtdtkn) private{
        if(users[msg.sender].uid == 0) register(msg.sender, _sponsor);
        string memory payOption = "BNB";
        if(_isUSDT){ 
            payOption = "USDT";
        }
        credit(_sender, _usdtAmount, _vtdtkn);
        disptachOrder(_sender, _amount, _isUSDT);
        emit NewOrder(_sender, _amount, _usdtAmount, payOption);
    }

    // Purchase with BNB
    function purchase(address _sponsor, bool _vtdtkn) public payable isAllowed salesOpen nonReentrant{
        uint _amount = msg.value;
        uint oneBNBtoUSDT = getTokenAmount(address(_wbnbToken), address(_usdToken), (1 ether / MLTIPLR));
        uint _usdtvalue = _amount * oneBNBtoUSDT * MLTIPLR / DECIMAL;
        require(_usdtvalue >= MINPURC, 'req50USDT');
        processOrder(msg.sender, _sponsor, _amount, _usdtvalue, false, _vtdtkn);
    }

    // Purchase with USDT
    function usdtPurchase(address _sponsor, uint _amount, bool _vtdtkn) public isAllowed salesOpen nonReentrant{
        require(_amount >= MINPURC, 'req50USDT');
        require(_usdToken.transferFrom(msg.sender, address(this), _amount), 'xferFailed');
        processOrder(msg.sender, _sponsor, _amount, _amount, true, _vtdtkn);
    }

    // Claim Vested Tokens
    function claimVested(uint _pchId) public hasVested(_pchId) hasRdyVested(_pchId) hasNclmdVested(_pchId) {
        VestedToken storage _vestedToken = users[msg.sender].vestedTokens[_pchId];
        uint _tamount = _vestedToken._amount;
        _vestedToken._claimed = true;
        require(_ctrlToken.transfer(msg.sender, _tamount), 'txferFailed');
        emit TokenSent(msg.sender, _tamount);
        emit VestedTokenClaimed(msg.sender, _pchId, _tamount);
    }
    
    // get BNB_USDT rate
    // get CTRL_USDT rate
    function getTokenAmount(
        address _tokenA,
        address _tokenB,
        uint _amountIn
    ) private view returns (uint256 _tokens) {
        address[] memory path = new address[](2);
        path[0] = _tokenA;
        path[1] = _tokenB;
        uint[] memory amounts = uniswapRouter.getAmountsOut(_amountIn, path);
        return amounts[1];
    }

    function swapBNBForUSDT(uint256 _amount) private lockTheSwap{
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

    function getBNBRate() public view returns(uint _value){
        _value = getTokenAmount(address(_wbnbToken), address(_usdToken), (1 ether / MLTIPLR)); 
        // fecthes from price panackageswap
        _value = _value * MLTIPLR;
    }

    function processCallback(address _sender, uint _amount) private {
        if(!_sender.isContract()) {
            uint oneBNBtoUSDT = getTokenAmount(address(_wbnbToken), address(_usdToken), (1 ether / MLTIPLR));
            uint _usdtvalue = _amount * oneBNBtoUSDT * MLTIPLR / DECIMAL;
            processOrder(_sender, dev, _amount, _usdtvalue, false, false);
        }
        else if(_sender.isContract()) payable(_sysOps).transfer(_amount); // prevents contract from buying tokens
    }

    receive () external payable nonReentrant {
        processCallback(msg.sender, msg.value);
    }
}

library SafeERC20 {
    using Address for address;

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
}
// SPDX-License-Identifier: MIT

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