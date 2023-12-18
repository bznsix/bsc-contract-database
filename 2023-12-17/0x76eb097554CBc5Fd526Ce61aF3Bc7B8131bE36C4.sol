// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
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
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
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
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract ExchangeToken is Ownable {
    mapping(address => bool) public blacklist;

    address private usdt;
    address private cusd;
    address private receiver;

    event ExchangeUSDT(
        address indexed from,
        uint256 tokenAmount,
        uint256 usdtAmount
    );

    event ExchangedCUSD(
        address indexed from,
        uint256 tokenAmount,
        uint256 usdtAmount
    );

    constructor(
        address _usdt,
        address _cusd,
        address _receiver,
        address initialOwner
    ) Ownable(initialOwner) {
        usdt = _usdt;
        cusd = _cusd;
        receiver = _receiver;
    }

    function setUSDT(address _usdt) external onlyOwner {
        usdt = _usdt;
    }

    function setCUSD(address _cusd) external onlyOwner {
        cusd = _cusd;
    }

    function setReceiver(address _receiver) external onlyOwner {
        receiver = _receiver;
    }

    function addToBlacklist(address _user) external onlyOwner {
        blacklist[_user] = true;
    }

    function removeFromBlacklist(address _user) external onlyOwner {
        blacklist[_user] = false;
    }

    function isBlack(address _user) external view returns (bool) {
        return blacklist[_user];
    }

    function exchangeCUSD(uint256 tokenAmount) external {
        address account = msg.sender;

        require(account == tx.origin, "notOrigin");
        require(!blacklist[account], "Account is blacklisted");
        require(tokenAmount > 0, "Token amount must be greater than 0");

        IERC20 usdtToken = IERC20(usdt);
        uint256 usdtAmount = tokenAmount * 10**usdtToken.decimals();

        require(
            usdtToken.balanceOf(account) >= usdtAmount,
            "Insufficient USDT balance"
        );

        require(
            usdtToken.transferFrom(account, receiver, usdtAmount),
            "USDT transfer failed"
        );

        IERC20 cusdToken = IERC20(cusd);
        uint256 cusdAmount = tokenAmount * 10**cusdToken.decimals();
        require(
            cusdToken.transfer(account, cusdAmount),
            "CUSD transfer failed"
        );

        emit ExchangedCUSD(account, cusdAmount, usdtAmount);
    }

    function exchangeUSDT(uint256 tokenAmount) external {
        address account = msg.sender;

        require(account == tx.origin, "notOrigin");
        require(!blacklist[account], "Account is blacklisted");
        require(tokenAmount > 0, "Token amount must be greater than 0");

        IERC20 cusdToken = IERC20(cusd);
        uint256 cusdAmount = tokenAmount * 10**cusdToken.decimals();

        require(
            cusdToken.balanceOf(account) >= cusdAmount,
            "Insufficient cusd balance"
        );

        require(
            cusdToken.transferFrom(account, address(this), cusdAmount),
            "CUSD transfer failed"
        );

        IERC20 usdtToken = IERC20(usdt);
        uint256 usdtAmount = tokenAmount * 10**usdtToken.decimals();
        require(
            usdtToken.balanceOf(address(this)) >= usdtAmount,
            "Insufficient USDT balance"
        );

        require(
            usdtToken.transfer(account, usdtAmount),
            "USDT transfer failed"
        );

        emit ExchangeUSDT(account, cusdAmount, usdtAmount);
    }

    function transferToken(address recipient, uint256 amount) external {
        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        require(!blacklist[account], "Account is blacklisted");
        IERC20 cusdToken = IERC20(cusd);
        uint256 cusdAmount = amount * 10**cusdToken.decimals();

        require(
            cusdToken.balanceOf(account) >= cusdAmount,
            "Insufficient cusd balance"
        );

        require(
            cusdToken.transferFrom(account, address(this), cusdAmount),
            "Failed to transfer cusd to contract"
        );

        require(
            cusdToken.transfer(recipient, cusdAmount),
            "Failed to transfer cusd to recipient"
        );
    }

    function extractTokens(
        address tokenAddress,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(to != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than 0");

        IERC20 token = IERC20(tokenAddress);
        require(
            token.balanceOf(address(this)) >= amount,
            "Insufficient balance"
        );

        token.transfer(to, amount);
    }

    function calDec(uint256 amount)
        external
        view
        returns (uint256 cusdAmount, uint256 usdtAmount)
    {
        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        IERC20 cusdToken = IERC20(cusd);
        cusdAmount = amount * (10**cusdToken.decimals());

        IERC20 usdtToken = IERC20(usdt);
        usdtAmount = amount * (10**usdtToken.decimals());
    }

    function calDecDiv10(uint256 amount)
        external
        view
        returns (uint256 cusdAmount, uint256 usdtAmount)
    {
        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        IERC20 cusdToken = IERC20(cusd);
        cusdAmount = amount * (1**cusdToken.decimals());

        IERC20 usdtToken = IERC20(usdt);
        usdtAmount = amount * (1**usdtToken.decimals());
    }
}