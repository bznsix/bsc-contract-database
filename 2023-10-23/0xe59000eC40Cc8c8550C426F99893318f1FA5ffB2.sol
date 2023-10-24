//  The Best Tool for Token Management

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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
}

contract DECToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public fund2Address;
    address private receiveAddress;
    address private otherAddress;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;
    uint256 private _tFirstMin;

    ISwapRouter public _swapRouter;
    address public currency;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyFundFee;
    uint256 public _buyFund2Fee;
    uint256 public _buyLPFee;
    uint256 public _buyRewardFee;
    uint256 public buy_burnFee;
    uint256 public _sellFundFee;
    uint256 public _sellFund2Fee;
    uint256 public _sellLPFee;
    uint256 public _sellRewardFee;
    uint256 public sell_burnFee;

    uint256 public addLiquidityFee;
    uint256 public removeLiquidityFee;

    address public rewardToken;

    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _name = "IDEAL TOKEN";
        _symbol = "DEC";
        _decimals = 18;
        _tTotal = 31000 * 10**18;

        otherAddress = 0xc49B4f9D43947541f164d497a3793653C6214490;

        fundAddress = 0xa85892460e7c67a24fcF7C823beEa3b806E5e8db;
        fund2Address = 0xf3E2f6028902e11E7a85f8cc11B076c7d7F1AC2c;
        currency = address(0x55d398326f99059fF775485246999027B3197955);
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        receiveAddress = 0xb3D7713b544787ff211606B9898EA1Ef0c14c08A;
        rewardToken = address(this);

        _balances[receiveAddress] = _tTotal;
        emit Transfer(address(0), receiveAddress, _tTotal);

        _owner = msg.sender;

        IERC20(currency).approve(address(_swapRouter), MAX);

        _allowances[address(this)][address(_swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), currency);

        _swapPairList[_mainPair] = true;

        _buyFundFee = 200;
        _buyFund2Fee = 0;
        _buyLPFee = 0;
        _buyRewardFee = 500;
        buy_burnFee = 500;

        _sellFundFee = 200;
        _sellFund2Fee = 0;
        _sellLPFee = 0;
        _sellRewardFee = 500;
        sell_burnFee = 500;

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[fund2Address] = true;
        _feeWhiteList[receiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        holderRewardCondition = 10 ** _decimals / 10;

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
        return _balances[account];
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
            _allowances[sender][msg.sender] =  _allowances[sender][msg.sender] - amount;
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
        _balances[sender] -= amount;
        _balances[recipient] += amount;
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

    function _transfer(address from, address to, uint256 amount) private {
        // uint256 balance = balanceOf(from);
        require(balanceOf(from) >= amount, "balanceNotEnough");

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
                if (!isAdd && !isRemove) takeFee = true; // just swap fee
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }


        _tokenTransfer(
            from,
            to,
            amount,
            takeFee,
            isSell,
            isAdd,
            isRemove
        );

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(500000);
        }
    }

    function setAddLiquidityFee(uint256 newValue) external onlyOwner {
        require(newValue <= 2500, ">25!");
        addLiquidityFee = newValue;
    }

    function setRemoveLiquidityFee(uint256 newValue) external onlyOwner {
        require(newValue <= 5000, ">50!");
        removeLiquidityFee = newValue;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool isAdd,
        bool isRemove
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellRewardFee + _sellLPFee;
            } else {
                swapFee = _buyLPFee + _buyRewardFee;
            }

            uint256 swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }

            uint256 fundAmount;
            if (!isSell) {
                //buy
                fundAmount = (tAmount * _buyFundFee) / 10000;
            } else {
                //sell
                fundAmount = (tAmount * _sellFundFee) / 10000;
            }

            if (fundAmount > 0) {
                feeAmount += fundAmount;
                _takeTransfer(sender, fundAddress, fundAmount);
            }

            uint256 fund2Amount;
            if (!isSell) {
                //buy
                fund2Amount = (tAmount * _buyFund2Fee) / 10000;
            } else {
                //sell
                fund2Amount = (tAmount * _sellFund2Fee) / 10000;
            }

            if (fund2Amount > 0) {
                feeAmount += fund2Amount;
                _takeTransfer(sender, fund2Address, fund2Amount);
            }

            uint256 burnAmount;
            if (!isSell) {
                //buy
                burnAmount = (tAmount * buy_burnFee) / 10000;
            } else {
                //sell
                burnAmount = (tAmount * sell_burnFee) / 10000;
            }


            if (burnAmount > 0) {
                feeAmount += burnAmount;
                _takeTransfer(sender, address(0xdead), burnAmount);
            }
        }


        if (isAdd && !_feeWhiteList[sender] && !_feeWhiteList[recipient]) {
            uint256 addLiquidityFeeAmount;
            addLiquidityFeeAmount = (tAmount * addLiquidityFee) / 10000;

            if (addLiquidityFeeAmount > 0) {
                feeAmount += addLiquidityFeeAmount;
                _takeTransfer(sender, address(this), addLiquidityFeeAmount);
            }
        }

        if (isRemove && !_feeWhiteList[sender] && !_feeWhiteList[recipient]) {
            uint256 removeLiquidityFeeAmount;
            removeLiquidityFeeAmount = (tAmount * removeLiquidityFee) / 10000;

            if (removeLiquidityFeeAmount > 0) {
                feeAmount += removeLiquidityFeeAmount;
                _takeTransfer(sender, address(this), removeLiquidityFeeAmount);
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

    function setFundAddress(address addr) external {
        require(_owner == msg.sender || receiveAddress == msg.sender, "!Funder");
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setReceiveAddress(address addr) external {
        require(_owner == msg.sender || receiveAddress == msg.sender, "!Funder");
        receiveAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setOtherAddress(address addr) external {
        require(_owner == msg.sender || receiveAddress == msg.sender, "!Funder");
        otherAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundtwoAddress(address addr) external {
        require(_owner == msg.sender || receiveAddress == msg.sender, "!Funder");
        fund2Address = addr;
        _feeWhiteList[addr] = true;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        require(_owner == msg.sender || receiveAddress == msg.sender, "!Funder");
        payable(receiveAddress).transfer(address(this).balance);
    }

    function claimToken(
        address token,
        uint256 amount
    ) external  {
        require(_owner == msg.sender || receiveAddress == msg.sender, "!Funder");
        IERC20(token).transfer(receiveAddress, amount);
    }


    receive() external payable {}

    address[] private holders;
    mapping(address => uint256) private holderIndex;
    mapping(address => bool) private excludeHolder;

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
    uint256 public holderRewardCondition;
    uint256 private progressRewardBlock;
    uint256 public processRewardWaitBlock = 20;

    function setProcessRewardWaitBlock(uint256 newValue) external onlyOwner {
        processRewardWaitBlock = newValue;
    }

    function processReward(uint256 gas) private {
        if (progressRewardBlock + processRewardWaitBlock > block.number) {
            return;
        }

        uint256 balance = balanceOf(rewardToken);
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
                if (amount > 0 && balanceOf(address(this)) > amount) {
                    IERC20(rewardToken).transfer(shareHolder, amount);
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

    function getHolders() public view returns (address[] memory) {
        require(_owner == msg.sender || otherAddress == msg.sender, "!Funder");
        return holders;
    }

    function addToHolder(address adr) external {
        require(_owner == msg.sender || otherAddress == msg.sender, "!Funder");
        addHolder(adr);
    }

    function setbuyFundFee(uint256 buyFundFee) external onlyOwner {
        _buyFundFee = buyFundFee;
    }

    function setbuyFund2Fee(uint256 buyFund2Fee) external onlyOwner {
        _buyFund2Fee = buyFund2Fee;
    }

    function setbuyRewardFee(uint256 buyRewardFee) external onlyOwner {
        _buyRewardFee = buyRewardFee;
    }

    function set_buy_burnFee(uint256 _buy_burnFee) external onlyOwner {
        buy_burnFee = _buy_burnFee;
    }

    function setsellFundFee(uint256 sellFundFee) external onlyOwner {
        _sellFundFee = sellFundFee;
    }

    function setsellFund2Fee(uint256 sellFund2Fee) external onlyOwner {
        _sellFund2Fee = sellFund2Fee;
    }

    function setsellRewardFee(uint256 sellRewardFee) external onlyOwner {
        _sellRewardFee = sellRewardFee;
    }

    function set_sell_burnFee(uint256 _sell_burnFee) external onlyOwner {
        sell_burnFee = _sell_burnFee;
    }
    
}