// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!onlyOwner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        _owner = newOwner;
    }
}

contract AbsToken is IERC20, Ownable {
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint256 public _tTotal;

    address public fundAddress;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public whiteList;

    bool public isOpen;

    uint256 public _LPFee;

    uint256 private constant MAX = ~uint256(0);

    ISwapRouter public _swapRouter;

    address public mainPair;

    constructor(
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply
    ) {
        isOpen = false;
        _LPFee = 20;

        fundAddress = 0xc87cD5BD0B1671b3c4E0FCC002873d3C883a473a;
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        mainPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            _swapRouter.WETH()
        );
        _allowances[address(this)][address(_swapRouter)] = MAX;

        whiteList[address(this)] = true;
        whiteList[fundAddress] = true;
        whiteList[msg.sender] = true;

        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _tTotal = Supply * 10 ** Decimals;

        _balances[msg.sender] = _tTotal;

        emit Transfer(address(0), msg.sender, _tTotal);
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
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: Transfer from the zero address");
        require(to != address(0), "ERC20: Transfer to the zero address");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        uint256 txFee;

        if (from == mainPair || to == mainPair) {
            if (!whiteList[from] && !whiteList[to]) {
                txFee = _LPFee;

                if (to == mainPair) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > 0) {
                        swapTokenForFund(contractTokenBalance);
                    }
                } else {
                    require(isOpen, "trade is not open!");
                }
            }
        }

        _tokenTransfer(from, to, amount, txFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;
        if (fee > 0) {
            feeAmount = (tAmount * fee) / 1000;
            _takeTransfer(sender, address(this), feeAmount);
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        payable(fundAddress).transfer(address(this).balance);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    receive() external payable {}

    function claimBalance() public {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) public {
        IERC20(token).transfer(fundAddress, amount);
    }

    function setOpenStatus(bool _open) external onlyOwner {
        isOpen = _open;
    }

    function setWhiteList(address addr, bool enable) external onlyOwner {
        whiteList[addr] = enable;
    }
}

contract Lucky is AbsToken {
    constructor() AbsToken("Lucky", "LUCKY", 18, 1000000000000) {}
}