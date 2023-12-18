// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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

contract IclickVaultCore is ReentrancyGuard{
    using SafeERC20 for IERC20;
    using Address for address;
    IERC20 public immutable _iclickToken;
    IERC20 internal immutable _usdToken;
    IUniswapRouter public immutable uniswapRouter;
    address immutable internal dev;
    // System Settings [on buying tokens]
    address internal immutable adminWallet; // 50%
    uint internal constant MLTIPLR          = 1e9;
    uint internal constant DECIMAL          = 1e18;
    uint internal constant DIVIDER          = 10000;
    uint internal constant ACTIVATION_ADMIN = 5000; // 50% goes to admin wallet
    uint internal constant ACTIVATION_RSRVD = 3000; // 50% goes to liquidty reserve
    uint internal constant MINWDRW          = 1 ether; // $1 Minimum
    uint internal constant MAXWDRW          = 500 ether; // $500 Maximum
    
    // system config
    uint[] internal PACKS        = [ 50 ether, 100 ether, 250 ether, 500 ether, 1000 ether, 2000 ether, 5000 ether, 7500 ether, 10000 ether ];
    uint[] internal ECAPS        = [ 60 ether, 122 ether, 312.5 ether, 650 ether, 1320 ether, 2700 ether, 6850 ether, 10500 ether, 14500 ether ];
    uint internal EXPIR          = 30; // number of activities days for each packs
    uint[] internal COMMI        = [ 300, 200, 100 ]; // 5% commission [on activation]
    uint internal COMCL          = 50; // 0.5% commission [on click]
    uint internal SWAPG          = 500; // +5% while swapping
    uint internal constant DAILY = 24 hours; // 24 hours;
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
        uint daysLeft; // activities days left
        uint lastRecord;
        uint lastWithdrawal;
    }

    struct Stats{
        uint totalUsers;
        uint totalActivation; // total in iclick
        uint totalSold; // iclick
        uint totalBalance; // total usdt to pay
        uint totalWithdrawn; // total usdt
        uint totalUSDTactivation; // total activation in usdt
    }
    
    mapping (address => User) public users;

    Stats public stats;

    bool private inSwapAndLiquify;
    
    modifier onlyAuth () {
        require(msg.sender == dev || msg.sender == adminWallet, 'unAuthorized');
        _;
    }

    // Only Members
    modifier isMember () {
        require(users[msg.sender].uid > 0, '_Memb');
        _;
    }

    // only Active User
    modifier onlyActive (){
        require(users[msg.sender].daysLeft > 0, '_Actv');
        _;
    }

    // Can Earn
    modifier canEarn () {
        require(users[msg.sender].earningCap > 0, '_Earn');
        _;
    }

    // Daily Record
    modifier allowDaily () {
        require(users[msg.sender].lastRecord + DAILY <= block.timestamp, 'Daily Only');
        _;
    }

    modifier withdrawDaily() {
        require(users[msg.sender].lastWithdrawal + DAILY <= block.timestamp, '24hrsHold');
        _;
    }

    // Has balance
    modifier hasBalance (uint _amount) {
        require (users[msg.sender].balance >= _amount, 'NoBalce');
        _;
    }

    // Minimum Withdrawal
    modifier minWithd (uint _amount) {
        require(_amount >= MINWDRW, 'MinWithd');
        _;
    }

    // Valid Pack
    modifier packExists (uint8 _packId) {
        require (_packId < PACKS.length, 'WgPck');
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
    event CommissionEarned (address indexed _benefactor, address _from, uint indexed _level, uint _amount, bool _activation);
    // successful withdrawal
    event Withdrawan (address indexed _sender, uint _amount);
    // token sold
    event Tokensold (address indexed _sender, uint _amount);   
    // token Sent
    event TokenSent(address indexed _sender, uint amount);

    constructor(){ 
        dev = msg.sender; 
        adminWallet = address(0xfCb339d1e5F06fec7E6646A2d70C6d0e587ACDE0); // testnet 0x2ECe85C590313fFB84A6ba5978e53Ca5551234f0 // mainnet 0xfCb339d1e5F06fec7E6646A2d70C6d0e587ACDE0
        _iclickToken = IERC20(address(0xc8C06a58E4ad7c01b9bb5Af6C76a7a1CfEBd0319)); // testnet 0x80247A78b06bac28B2086D0eb0012feCD0442B66 // mainnet 0xc8C06a58E4ad7c01b9bb5Af6C76a7a1CfEBd0319
        _usdToken = IERC20(address(0x55d398326f99059fF775485246999027B3197955)); // testnet 0xC6Efc0f7AF6e0B3e413d8FdD339FAf4d9a6e2D8F // mainnet 0x55d398326f99059fF775485246999027B3197955
        IUniswapRouter _uniswapV2Router = IUniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // testnet 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 // mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
        uniswapRouter = _uniswapV2Router;
    }

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
        // 50% Admin Funds
        uint _admin = _amount * ACTIVATION_ADMIN / DIVIDER;
        _iclickToken.transfer(adminWallet, _admin);
        emit TokenSent(adminWallet, _admin);
    }

    function processActivation (address _sender, uint8 _packId, uint _tokens) internal {
        User storage _user = users[_sender];
        if(_user.currentPack < _packId) _user.currentPack = _packId;
        _user.earningCap       += ECAPS[_packId];
        _user.daysLeft         += EXPIR;
        _user.totalActivation  += _tokens; // total token spent
        _user.lastRecord        = block.timestamp;

        stats.totalActivation     += _tokens;
        stats.totalUSDTactivation += PACKS[_packId];
        // dispatch tokens
        dispatchTokens(_tokens);
        // dispatch commissions [usdt value]
        dipatchCommission(_sender, PACKS[_packId], true);
    }

    function dipatchCommission(address _sender, uint _reward, bool _activation) internal {
        uint _comm = _reward * COMCL / DIVIDER;
        address _upline = users[_sender].sponsor;
        for(uint8 i = 0; i < 3; i++){
            if(_upline == address(0)) break;
            if(_activation) _comm = _reward * COMMI[i] / DIVIDER;
            users[_upline].balance          += _comm;
            users[_upline].commissionEarned += _comm;
            stats.totalBalance              += _comm;
            emit CommissionEarned (_upline, _sender, i + 1, _comm, _activation);
            
            _upline = users[_upline].sponsor;
        }
    }

    function getDailyRewrd(User memory _sender) internal pure returns(uint _reward) {
        // uint8 _packId   = _user.currentPack;
        // _reward         = ECAPS[_packId] / EXPIR;
        if(_sender.daysLeft > 0) _reward         = _sender.earningCap / _sender.daysLeft;
        if(_sender.earningCap < _reward) _reward = _sender.earningCap;
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

    // swap 
    function swapAndLiquify(IERC20 _token1, IERC20 _token2, uint tokenAmount) internal lockTheSwap{
        // uint256 tokenAmount = _busdAddress.balanceOf(address(this));
        _token1.approve(address(uniswapRouter), tokenAmount);
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(_token1);
        path[1] = address(_token2);
        // path[1] = uniswapRouter.WETH();
        // make the swap
        uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        emit Tokensold(address(this), tokenAmount);
    }

    function getTokenPrice () public view returns (uint){
        uint oneCTRLtoUSDT = getTokenAmount(address(_iclickToken), address(_usdToken), (1 ether / MLTIPLR));
        return oneCTRLtoUSDT * MLTIPLR;
    }

    // prevent token loss
    function getTokens (uint _amount, IERC20 _token) public onlyAuth {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, 'LowBlce');
        IERC20(_token).transfer(msg.sender, _amount);
        emit TokenSent(msg.sender, _amount);
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./IclickVaultCore.sol";
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

contract IclickVaultEngine is IclickVaultCore {

    constructor(){}

    // activate pack
    function activateAcc (address _refBy, uint8 _packId) public nonReentrant packExists(_packId) {
        address _sender = msg.sender;
        if(users[_sender].uid == 0 || users[_sender].sponsor == address(0)){
            register(_sender, _refBy);
        }

        uint _packValue = PACKS[_packId]; // usdt Value

        // get usdt Value
        uint oneICLICKtoUSDT = getTokenAmount(address(_iclickToken), address(_usdToken), (1 ether / MLTIPLR));

        uint _iclickValue = (_packValue / (oneICLICKtoUSDT * MLTIPLR)) * DECIMAL;
        require (_iclickToken.transferFrom(_sender, address(this), _iclickValue));
        // activate Pack 
        processActivation (_sender, _packId, _iclickValue);
        emit NewPackActivation(_sender, _packId, _iclickValue);
    }

    // record click [once daily]
    function recordDailyClick (uint _sysId) public nonReentrant onlyActive canEarn allowDaily{
        User storage _user = users[msg.sender];
        uint _reward            = getDailyRewrd(_user);
        
        _user.balance          += _reward;
        _user.earningCap       -= _reward;
        _user.earningsCredited += _reward;
        _user.lastRecord        = block.timestamp; // updates once daily
        _user.daysLeft          -= 1;
        if(_user.earningCap == 0) _user.daysLeft = 0;
        // pay affiliate commissions
        dipatchCommission(msg.sender, _reward, false);
        stats.totalBalance     += _reward;
        emit NewRecord (msg.sender, _sysId, _reward);
    }

    // withdraw usdt
    function withdrawEarnings (uint _amount) public nonReentrant minWithd(_amount) onlyActive withdrawDaily hasBalance(_amount) {
        User storage _user = users[msg.sender];
        // maxi withdrawal is $200 [withdrawal is once daily]
        // contract must sell to withdraw.
        uint _contractBalance = _usdToken.balanceOf(address(this));
        if(_contractBalance < _amount){
            // swap and liquify [get usdt]
            uint _tokenAmount = (_amount / getTokenPrice()) * DECIMAL;
            _tokenAmount     += _tokenAmount * SWAPG / DIVIDER; // + 5%
            swapAndLiquify(_iclickToken, _usdToken, _tokenAmount);
            stats.totalSold += _tokenAmount; 
            emit Tokensold(msg.sender, _tokenAmount);
            _contractBalance = _usdToken.balanceOf(address(this));
        }
        
        // maxi withdrawal is $500 [withdrawal is once daily] [save any extra to users balance]
        if(_amount > MAXWDRW){
            _amount = MAXWDRW; // withdrawal limit
        }

        require(_amount < _contractBalance, 'noLqty');

        _user.balance        -= _amount;
        stats.totalBalance   -= _amount;
        stats.totalWithdrawn += _amount;
        _user.lastWithdrawal  = block.timestamp;
        require(_usdToken.transfer(msg.sender, _amount));
        emit Withdrawan (msg.sender, _amount);
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

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