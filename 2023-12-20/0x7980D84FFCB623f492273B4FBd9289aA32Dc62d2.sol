// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public destroyAddress=address(0x000000000000000000000000000000000000dEaD);

    mapping(address => address) public inviter;
    mapping(address => mapping(address => bool)) public inviterSend;
   
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    uint256 private constant MAX = ~uint256(0);
    
    uint256 public inviteFee=100;//1%
    uint256 public destroyFee=100;
    uint256 public fundFee = 100;
    uint256 public dividendFee = 200;

 
    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public _mainPair;

    constructor(
        address RouterAddress,
        address USDTAddress,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        address FundAddress,
        address ReceiveAddress
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _allowances[address(this)][RouterAddress] = MAX;
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10**Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        holderRewardCondition = 500 * 10**18;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        bool takeFee;
        bool isSell;
        bool isAddLdx;

        if (_swapPairList[to]) {
            isAddLdx = _isAddLiquidityV1();
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLdx, "!startAddLP");
                    takeFee = false;
                }
            }
        }

        if (_swapPairList[to]) {
            isSell = true;
        }
        uint256 inviteAmount=1 * 10 ** (_decimals - 3);


        if(!isContract(from) && !inviterSend[to][from] && amount == inviteAmount){
             inviterSend[to][from] = true;
        }

        if(amount == inviteAmount){
            if(!isContract(from) && !isContract(to) && inviterSend[from][to] && inviter[from] == address(0)){
               inviter[from] = to;
            }
        }


        
        _tokenTransfer(from, to, amount, takeFee, isSell);
        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(500000);
        }
        
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (takeFee) {

            uint256 fundAmount = (tAmount * fundFee) / 10000;
            uint256 dividendAmount = (tAmount * dividendFee) / 10000;
            uint256 inviteAmount=(tAmount*inviteFee)/10000;
            uint256 destroyAmount=(tAmount*destroyFee)/10000;
            address parent;
            if(isSell){
                parent=inviter[sender];
            }else{
                parent=inviter[recipient];
            }
   
            if (fundAmount > 0) {
                feeAmount += fundAmount;
                _takeTransfer(sender, fundAddress, fundAmount);
            }
            if (dividendAmount > 0) {
                feeAmount += dividendAmount;
                _takeTransfer(sender, address(this), dividendAmount);
            }
                         
            if(inviteAmount>0 && parent!=address(0)){
                feeAmount+=inviteAmount;
                 _takeTransfer(sender, parent, inviteAmount);
            }
            if(destroyAmount>0){
                 feeAmount+=destroyAmount;
                 _takeTransfer(sender, destroyAddress, destroyAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setDividendFee(uint256 fee) external onlyOwner {
        dividendFee = fee;
    }

    function setFundFee(uint256 fee) external onlyOwner {
        fundFee = fee;
    }

    function setInviteFee(uint256 fee) external onlyOwner {
        inviteFee = fee;
    }

    function setDestroyFee(uint256 fee) external onlyOwner {
        destroyFee = fee;
    }

    function startAddLP() external onlyOwner {
        require(0 == startAddLPBlock, "startedAddLP");
        startAddLPBlock = block.number;
    }

    function closeAddLP() external onlyOwner {
        startAddLPBlock = 0;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(fundAddress, amount);
    }

    receive() external payable {}

    address[] private holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    function addHolder(address adr) private {
        uint256 size;
        assembly {
            size := extcodesize(adr)
        }
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 public progressRewardBlock;
    uint256 public rewardWaitBlock = 10;

    function setRewardWaitBlock(uint256 newValue) public onlyOwner {
        rewardWaitBlock = newValue;
    }

    function resetRewardBlock(uint256 newValue) public onlyOwner {
        progressRewardBlock = newValue;
    }

    function processReward(uint256 gas) private {
        if (progressRewardBlock + rewardWaitBlock > block.number) {
            return;
        }

        IERC20 Token = IERC20(address(this));

        uint256 balance = Token.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint256 holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (amount > 0) {
                    Token.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function _isAddLiquidityV1() internal view returns (bool ldxAdd) {
        address token0 = IPair(_mainPair).token0();
        address token1 = IPair(_mainPair).token1();
        (uint256 r0, uint256 r1, ) = IPair(_mainPair).getReserves();
        uint256 bal1 = IERC20(token1).balanceOf(_mainPair);
        uint256 bal0 = IERC20(token0).balanceOf(_mainPair);
        if (token0 == address(this)) {
            if (bal1 > r1) {
                uint256 change1 = bal1 - r1;
                ldxAdd = change1 > 1000;
            }
        } else {
            if (bal0 > r0) {
                uint256 change0 = bal0 - r0;
                ldxAdd = change0 > 1000;
            }
        }
    }
}

contract LK is AbsToken {
    constructor()
        AbsToken(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E), //router
            address(0x55d398326f99059fF775485246999027B3197955), //u
            "LK",
            "LK",
            18,
            1000000,
            address(0xE08EbF86974dbecb24959102BC488A6F7C6a8401), //fund
            address(0x46Bded499cAD39F19336e128d9047B6F0472D505) // receive
        )
{}
    
}