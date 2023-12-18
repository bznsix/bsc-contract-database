/**
 *Submitted for verification at BscScan.com on 2023-11-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IPancakeRouter {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IPancakePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

contract AITToken is IERC20, Ownable {
    string private _name = "AI Tools";
    string private _symbol = "AIT";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 11000000 * 10**uint256(_decimals);
    uint256 private _taxFee = 0; // 2% tax fee

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => uint256) private _buyBlock;
    bool public checkBot = true;

    address public feeAddress; // Fee recipient address
    IPancakeRouter public pancakeRouter;
    address public pancakePair;

    address public pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    //address public pancakeRouterAddressTesnet = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

    mapping(address => bool) private _isSwapPair;

    constructor(address _feeAddress) {
        _balances[msg.sender] = _totalSupply;
        feeAddress = _feeAddress;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view  returns (string memory) {
        return _name;
    }

    function symbol() public view  returns (string memory) {
        return _symbol;
    }

    function decimals() public view  returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
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
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function setFeeAddress(address _newFeeAddress) public onlyOwner {
        feeAddress = _newFeeAddress;
    }

    function setTaxFee(uint8 _newTaxFee) public onlyOwner {
        require(_newTaxFee <= 25, "Tax fee percentage must be less than or equal to 25");
        _taxFee = _newTaxFee;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[sender] >= amount, "Insufficient balance");

        _beforeTokenTransfer(sender, recipient);

        uint256 taxAmount = 0;

        if (isSwapPair(sender)|| isSwapPair(recipient)) {
            // Token is being sold (transferred from non-pair address to pair address)
            taxAmount = (amount * _taxFee) / 100;
            uint256 transferAmount = amount - taxAmount;

            _balances[sender] -= amount;
            _balances[recipient] += transferAmount;
            _balances[feeAddress] += taxAmount;

            emit Transfer(sender, recipient, transferAmount);
            emit Transfer(sender, feeAddress, taxAmount);
        } else {
            // Standard transfer without tax
            _balances[sender] -= amount;
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setCheckBot(bool _status) public onlyOwner {
        checkBot = _status;
    }

    function _beforeTokenTransfer(
        address from,
        address to
    ) internal  isBot(from, to) {
        _buyBlock[to] = block.number;
    }

    modifier isBot(address from, address to) {
        if (checkBot) require(_buyBlock[from] != block.number, "Bad bot!");
        _;
    }

    function isSwapPair(address pair) public view returns(bool){
        if(pair == address(0)){
            return false;
        }
        return IPancakeFactory(IPancakeRouter(pancakeRouterAddress).factory()).getPair(address(this), IPancakeRouter(pancakeRouterAddress).WETH()) == pair ||
        _isSwapPair[pair];
    }

    function addSwapPair(address swapPair) external onlyOwner {
        require(swapPair != address(0),"SwapPair can not be address 0");
        _isSwapPair[swapPair] = true;
    }

    function removeSwapPair(address swapPair) external onlyOwner {
        require(swapPair != address(0),"SwapPair can not be address 0");
        _isSwapPair[swapPair] = false;
    }
}