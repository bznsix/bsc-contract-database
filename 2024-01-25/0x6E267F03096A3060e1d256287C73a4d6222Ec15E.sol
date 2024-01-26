/**
 *Submitted for verification at BscScan.com on 2023-12-14
*/

/**
 *Submitted for verification at testnet.bscscan.com on 2023-12-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address _spender, uint _value) external;

    function transferFrom(address _from, address _to, uint _value) external ;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

interface ISwapPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function sync() external;
}

contract Token is IERC20, Ownable {
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public currency;
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _swapPairList;


    mapping(address => bool) public _allowedList;
    bool allowedTrade  = true;
    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee;
    uint256 public _buyLPFee;

    uint256 public _sellFundFee;
    uint256 public _sellLPFee;

    uint256 public _inviterFee;

    uint256 public startTime=block.timestamp;
    uint256 public burnTimes=0;
    uint256 public lpAutoBurnPercen = 5;
    mapping(address => uint256) private _balances;
    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => mapping(address => bool)) public _maybeInvitor;


    // mapping(address => uint256) public _interestTime;

    // uint256 public _interestStartTime;

    // mapping(address => bool) public _excludeHolder;

    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }


    address[] public rewardPath;

    constructor() {
        _name = "PIZZA";
        _symbol = "PIZZA";
        _decimals = 18;
        _tTotal = 49_000_000 * 10**_decimals;

        fundAddress = address(0xb5d36761eff79EE1a0C4415B39cdEE04624ecA2a);
        currency = address(0x55d398326f99059fF775485246999027B3197955);
        _swapRouter = ISwapRouter(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        address ReceiveAddress = address(0x09376BDb915B45709cA77a800f83823B123Fcc67);
        _owner = address(0x375DEFfcF59540A2dDccaC85a2445D4F05deC9d2);

        IERC20(currency).approve(address(_swapRouter), MAX);

        _allowances[address(this)][address(_swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), currency);

        _swapPairList[_mainPair] = true;
        rewardPath = [address(this),currency];

        _buyFundFee = 100;
        _buyLPFee = 100;

        _sellFundFee = 100;
        _sellLPFee = 100;

        _inviterFee = 400;


        

        _tOwned[ReceiveAddress] = _tTotal;
        emit Transfer(address(0), ReceiveAddress, _tTotal);

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

      
        _tokenDistributor = new TokenDistributor(currency);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        //  return _tOwned[account] - getInterest(account);
         return _tOwned[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override  {
        _approve(msg.sender, spender, amount);
        
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override  {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _tOwned[sender] -= amount;
        _tOwned[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }


    function _isAddLiquidity() internal view returns (bool isAdd) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = currency;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = currency;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
    }


     function lpBurn(address pairAddress) private {
        uint256 baseAmount = balanceOf(pairAddress);
        uint timeElapsed = block.timestamp - startTime;
        uint times = timeElapsed / 60 minutes;
        if (times > burnTimes){
            uint256 tTimes = times - burnTimes;
            if (tTimes > 0){
                ISwapPair pair = ISwapPair(pairAddress);
                uint256 burnAmount = tTimes * baseAmount * lpAutoBurnPercen / 1000;
                if(burnAmount > 0){
                    burnTimes += tTimes;
                     _tOwned[pairAddress] = _tOwned[pairAddress] - burnAmount;
                    _takeTransfer(
                            pairAddress,
                            burnAddress,
                            burnAmount
                        );
                    pair.sync();
                }
            }
        }
    }


    function _transfer(address from, address to, uint256 amount) private {
        require(balanceOf(from) >= amount, "NotEnough");

        // _mintInterest(from);
        // _mintInterest(to);
        bool takeFee;
        bool isSell;
        bool isRemove;
        bool isAdd;

        if (_swapPairList[to]) {
            isAdd = _isAddLiquidity();

        } else if (_swapPairList[from]) {
            isRemove = _isRemoveLiquidity();

        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                 if(allowedTrade){
                    if (_swapPairList[to]) {
                        if (!inSwap && !isAdd) {
                            uint256 contractTokenBalance = balanceOf(address(this));
                            if (contractTokenBalance > 0) {
                                uint256 swapFee = _buyFundFee +
                                    _buyLPFee +
                                    _sellFundFee +
                                    _sellLPFee;
                                uint256 numTokensSellToFund = (amount * swapFee) /
                                    5000;
                                if (numTokensSellToFund > contractTokenBalance) {
                                    numTokensSellToFund = contractTokenBalance;
                                }
                                swapTokenForFund(numTokensSellToFund, swapFee);
                            }
                        }
                    }
                }else{
                    require(_allowedList[from] || _allowedList[to]);
                    takeFee = true;
                }
                if (!isAdd && !isRemove) takeFee = true; // just swap fee
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }else {
            if (address(0) == _inviter[to] && amount > 0 && from != to) {
                _maybeInvitor[to][from] = true;
            }
            if (address(0) == _inviter[from] && amount > 0 && from != to) {
                if (_maybeInvitor[from][to] && _binders[from].length == 0) {
                    _bindInvitor(from, to);
                }
            }
            lpBurn(_mainPair);
        }


        _tokenTransfer(
            from,
            to,
            amount,
            takeFee,
            isSell
        );

    }       

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _tOwned[sender] = _tOwned[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPFee;

            } else {
                swapFee = _buyFundFee + _buyLPFee;

            }

            uint256 swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }

            uint256 inviterAmount;
            inviterAmount = (tAmount * _inviterFee) / 10000;
            if (inviterAmount > 0) {
                feeAmount += inviterAmount;
                _takeInviterFee(sender, recipient, inviterAmount);
            }
        }


        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _bindInvitor(address account, address invitor) private {
        if (invitor != address(0) && invitor != account && _inviter[account] == address(0)) {
            uint256 size;
            assembly {size := extcodesize(invitor)}
            if (size > 0) {
                return;
            }
            _inviter[account] = invitor;
            _binders[invitor].push(account);
        }
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        address cur;
        uint256 tak = 100;

        if (_swapPairList[sender]) {
            cur = recipient;
        } else {
            cur = sender;
        }
        for (uint256 i = 0; i < 2; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 75;
            }else {
                rate = 25;
            }
            cur = _inviter[cur];
            if (cur == address(0)) {
                uint256 _leftAmount = tAmount * tak / 100;
                _tOwned[fundAddress] = _tOwned[fundAddress] + _leftAmount;
                emit Transfer(sender, fundAddress, _leftAmount);
                break;
            }
            tak = tak - rate;
            uint256 curTAmount = tAmount * rate / 100;
            _tOwned[cur] = _tOwned[cur] + curTAmount;
            emit Transfer(sender, cur, curTAmount);
        }
    }

    event Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 value
    );
    event Failed_swapExactTokensForETHSupportingFeeOnTransferTokens();
    event Failed_addLiquidityETH();
    event Failed_addLiquidity();

    function swapTokenForFund(
        uint256 tokenAmount,
        uint256 swapFee
    ) private lockTheSwap {

        swapFee += swapFee;
        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = (tokenAmount * lpFee ) / swapFee;

        try
            _swapRouter
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    tokenAmount - lpAmount,
                    0,
                    rewardPath,
                    address(_tokenDistributor),
                    block.timestamp
                )
        {} catch {
            emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                1
            );
        }
        

        swapFee -= lpFee;

        IERC20 FIST = IERC20(currency);

        uint256 fistBalance ;
        uint256 lpFist;
        uint256 fundAmount ;

        fistBalance = FIST.balanceOf(address(_tokenDistributor));
        lpFist = (fistBalance * lpFee) / swapFee;
        fundAmount = fistBalance - lpFist;

        if (lpFist > 0) {
            FIST.transferFrom(
                address(_tokenDistributor),
                address(this),
                lpFist
            );
        }

        if (fundAmount > 0) {
            FIST.transferFrom(
                address(_tokenDistributor),
                fundAddress,
                fundAmount
            );

        }

        if (lpAmount > 0 && lpFist > 0) {
            try
                _swapRouter.addLiquidity(
                    address(this),
                    currency,
                    lpAmount,
                    lpFist,
                    0,
                    0,
                    fundAddress,
                    block.timestamp
                )
            {} catch {
                emit Failed_addLiquidity();
            }
        }
        
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _tOwned[to] = _tOwned[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    receive() external payable {}

    function setFeeWhiteList(address account, bool value) public onlyOwner {
        _feeWhiteList[account] = value;
    }

    function setSellFundFee(uint256 _fee) public onlyOwner {
        _sellFundFee=_fee;
    }

    function setAllowedList(
        address[] calldata addr,
        bool enable
    ) public onlyOwner {
        for (uint256 i = 0; i < addr.length; i++) {
            _allowedList[addr[i]] = enable;
        }
    }
    function setTradeMode(bool enable) external onlyOwner {
        allowedTrade = enable;
    }

}