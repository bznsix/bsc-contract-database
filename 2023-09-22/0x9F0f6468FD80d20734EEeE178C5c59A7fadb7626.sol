//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19; 


/*
    @dev the Interface require for the Standard ERC20 Token 


*/ 



interface IERC20 {

    function totalSupply() external view returns(uint256); 
    function balanceOf(address account) external view returns(uint256); 
    function transfer(address recipient, uint256 amount) external returns(bool); 
    function allowance(address owner, address spender) external view returns(uint256); 
    function approve(address spender, uint256 amount) external returns(bool); 
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    event Transfer(address indexed owner, address indexed to, uint256 value);
    event Approval (address indexed owner, address spender, uint256 value); 
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

library safeMath {


    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a + b; 
        require(c >= a, "SafeMath: Addition Overflow");
        return c; 
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256)
    {
        require(b <= a, "SafeMath Subraction Underflow");
        uint256 c = a - b;
        return c; 
    }

    function mul(uint256 a, uint256 b) internal pure returns(uint256)
    {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b; 
        require(c / a == b, "SafeMath Mulipilication Overflow");
        return c; 
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256)
    {
        require(b > 0, "SafeMath Divison by Zero" );
        uint256 c = a / b; 
        return c; 
    }

}


/*
     @title Token Name and Implementation of the IERC20 Interface
    @title  This contract defines all essential token functions.
   
    @dev The Contract Functions provides methods to retrieve the total supply,
         balance, name, symbol, allowance, and approval status.
    



*/ 



contract emojiMoney is IERC20 {

    using safeMath for uint256; 

    address public owner; 
    uint256 private _totalSupply;
    string private _name; 
    string private _symbol; 
    uint256 private _decimals; 
    mapping(address => uint256) private _balances; 
    mapping(address => mapping(address => uint256)) private _allowances; 

    event Burn(address indexed burner, uint256); 


    /*
        @dev the deployment only call once, when the contract is been deployed!

        @dev the Name, symbol, decimal and the Transfer of the Token is been
            TRanfer when the contract being deployed!

    */

    constructor() {
        owner = msg.sender; 
        _name = "emojiMoney";
        _symbol = "emoji";
        _decimals = 18; 
        _totalSupply = 10000000 * 10 **uint256(_decimals);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }


    /*

    @dev All the Basic Functions for the Token to Work!

    */ 

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
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

    function allowance(address _owner, address spender) public view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }


     function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

 

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: Transfer from the zero address");
        require(recipient != address(0), "ERC20: Transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: Insufficient balance"); 
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address _owner, address spender, uint256 amount) internal {
        require(_owner != address(0), "ERC20: Approve from the zero address");
        require(spender != address(0), "ERC20: Approve to the zero address");
        
        _allowances[owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
    


    /*

    @dev the calling of specfic Contract that have restrictions!

    */ 

    modifier onlyOnwer () {

        require(msg.sender == owner, "Only Owner can call this Function!"); 
        _;
    }
}