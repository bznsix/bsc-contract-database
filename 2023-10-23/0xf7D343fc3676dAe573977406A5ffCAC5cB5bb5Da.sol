// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

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

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function feeTo() external view returns (address);
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

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
}

abstract contract AbsToken is IERC20, Ownable {
    
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) private _isExcludedFromFees;

    uint256 private _tTotal;

    mapping(address => bool) private _swapPairList;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyTax = 200;
    uint256 public _sellTax = 300;

    uint256 public startTradeBlock;
    uint256 private startAddLPBlock;
    address private immutable _mainPair;


    uint256 private _startTradeTime;

    constructor (
        address RouterAddress, 
        address ReceiveAddress,
        address Token0Address,
        address FundAddress
    ){
        _name = "BTCX";
        _symbol = "BTCX";
        _decimals = 18;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);


        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address pair = swapFactory.createPair(address(this), Token0Address);

        _swapPairList[pair] = true;
        _mainPair = pair;

        uint256 tokenUnit = 10 ** _decimals;
        uint256 total = 21000000 * tokenUnit;
        _tTotal = total;

        uint256 receiveTotal = total;
        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);

        fundAddress = FundAddress;

        _isExcludedFromFees[ReceiveAddress] = true;
        _isExcludedFromFees[fundAddress] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(0)] = true;
        _isExcludedFromFees[address(0x000000000000000000000000000000000000dEaD)] = true;

        require(Token0Address < address(this),"!pool");
    
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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount && amount >=300, "BNE");

        bool takeFee;
        bool isAddLiquidity;
        bool isDelLiquidity;
        
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);

        if (isAddLiquidity || isDelLiquidity){
            takeFee = false;
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_isExcludedFromFees[from] && to == _mainPair) {
                    startAddLPBlock = block.number;
                }
            }
            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLiquidity && _isAddLper[from]);
                } else if (block.number < startTradeBlock) {
                    revert("!startTrade");
                }
                takeFee = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if(!_isExcludedFromFees[to] && !_swapPairList[to]  && _startTradeTime + 3600 > block.timestamp){
            require(balanceOf(to) <= 1000 * 10**18,"exceed wallet limit!");
        }
    }

    function _isLiquidity(address from,address to)internal view returns(bool isAdd,bool isDel){
        address token0 = ISwapPair(address(_mainPair)).token0();
        (uint r0,,) = ISwapPair(address(_mainPair)).getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(_mainPair));
        if( _swapPairList[to] ){
            if( token0 != address(this) && bal0 > r0 ){
                isAdd = bal0 - r0 > 0;
            }
        }
        if( _swapPairList[from] ){
            if( token0 != address(this) && bal0 < r0 ){
                isDel = r0 - bal0 > 0; 
            }
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 senderBalance = _balances[sender];
        senderBalance -= tAmount;
        _balances[sender] = senderBalance;
        uint256 feeAmount;
        if (takeFee) {
            bool isSell;
            uint256 swapFeeAmount;
            if (_swapPairList[sender]) {//Buy
                swapFeeAmount = tAmount * _buyTax / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                swapFeeAmount = tAmount * _sellTax / 10000;
            }

            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, fundAddress, swapFeeAmount);
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


    modifier onlyFunder() {
        address msgSender = msg.sender;
        require(_isExcludedFromFees[msgSender] && (msgSender == fundAddress || msgSender == _owner), "nw");
        _;
    }

    mapping(address => bool) public _isAddLper;

    function setAddLp(address addr,bool state)external onlyFunder {
        _isAddLper[addr] = state;
    }

    function setFees(uint256 fee1,uint256 fee2)external onlyFunder {
        _buyTax = fee1;
        _sellTax = fee2;
    }



    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _isExcludedFromFees[addr] = true;
    }



    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_isExcludedFromFees[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    receive() external payable {}

    function startTrade() external onlyFunder {
        require(0 == startTradeBlock, "T");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
    }
}

contract BTCX is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //Receive
        address(0xB2Ff4ef0AB868549b22DC7787263071cbe39A0C4),
    //Token0
        address(0xa21693A96CF0921b399E394fe3E8d62fa787D027),
    //FundAddress
        address(0xdd35Ef458c4f07Ad8145Ff4f0Ca92Cdda70A9C45)
    ){
    }
}