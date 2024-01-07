/**
 * @title OUR AWESOME TOKEN - The Shit you never saw before
 *
 *      TG: MY_AWESOME_TG
 *      TWITTER: MY_AWESOME_TWITTER
 *      WEB_SITE: MY_AWESOME_WEBSITE.COM
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @dev removed context dependency.
/// @author OpenZeppelin https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
abstract contract Ownable {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
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
        if (owner() != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
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

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
/// @dev edits: pass initial pause state in constructor and removed context dependency.
/// @author OpenZeppelin https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol
abstract contract Pausable {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor(bool initialPaused) {
        _paused = initialPaused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract NotThatSimplePoo is Ownable, Pausable {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    // ERC20 events.
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    // This token specific events.
    event BlacklistStatusUpdated(address wallet, bool isBlacklisted);
    event MarketPairUpdated(address pair, bool isMarketPair);
    event ExcludedFromFeesUpdated(address wallet, bool isExcluded);
    event TaxRecipientUpdated(address recipient);
    event TaxesUpdated(uint256 buyTax, uint256 sellTax, uint256 transferTax);
    event LimitsUpdated(uint256 maxBuy, uint256 maxSell, uint256 maxWallet);
    event NumTokensToSwapUpdated(uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name = "NotThatSimplePoo";

    string public symbol = "NTSP";

    uint8 public constant decimals = 18;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    // No mint or burn means we can just use a constant.
    // Total supply must fit in uint128.
    uint256 public constant totalSupply = 1_000_000 * 10**decimals;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                              TOKEN-SPECIFIC
    //////////////////////////////////////////////////////////////*/

    address public taxRecipient = address(0x30f566A68cad355C5EdD447267EF088B4c059C07);

    // When accessing the buy tax, we also access buy limit, and the same applies for
    // sell tax and limit. We pack them into a struct to save on gas.

    uint256 public buyTax = 2_000;
    uint256 public sellTax = 2_500;
    uint256 public transferTax = 0;
    uint256 public maxWallet = totalSupply;

    /// @dev totalSupply * maxTax cannot exceed uint256.
    /// @dev maxTax cannot exceed taxDenominator.
    uint256 private constant taxDenominator = 10_000; // 500/10000 = 5%

    // Pack it into a struct instead of individual mappings to save on gas.
    struct walletState {
        bool isMarketPair;
        bool isExcludedFromFees;
    }
    mapping (address => walletState) public _walletState;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    // Start paused.
    constructor() Ownable(msg.sender) Pausable(true) {
        // Require supply to be less than the max uint128 value.
        require(totalSupply < type(uint128).max, "TOTAL_SUPPLY_EXCEEDS_MAX");

        // Setup for EIP-2612.
        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();

        // Exclude owner and the contract from fees.
        _walletState[msg.sender] = walletState({
            isMarketPair: false,
            isExcludedFromFees: true
        });
        emit ExcludedFromFeesUpdated(msg.sender, true);
        _walletState[address(this)] = walletState({
            isMarketPair: false,
            isExcludedFromFees: true
        });
        emit ExcludedFromFeesUpdated(taxRecipient, true);
        _walletState[address(this)] = walletState({
            isMarketPair: false,
            isExcludedFromFees: true
        });

        // Mint the initial supply.
        unchecked {
            balanceOf[msg.sender] += totalSupply;
        }

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function transfer(address to, uint256 amount) public whenNotPaused returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public whenNotPaused returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        if (allowed != type(uint256).max) {
            require(allowed >= amount, "ERC20: insufficient allowance");
            // Won't overflow since allowed >= amount.
            unchecked {
                allowance[from][msg.sender] = allowed - amount;
            }
        }

        _transfer(from, to, amount);

        return true;
    }

    function _buyTransfer(address to, uint256 amount) internal view returns (uint256) {
        // balanceOf[to]+amount can't exceed uint256 as it can't exceed totalSupply.
        // Taxes are capped at 10k and totalSupply is <= uint(128).max, overflow is impossible.
        unchecked {
            uint256 fees = (amount * buyTax) / taxDenominator;

            require(balanceOf[to] + amount <= maxWallet, "balance exceeds max wallet");

            return fees;
        }
    }

    function _sellTransfer(uint256 amount) internal view returns (uint256) {
        unchecked {

            uint256 fees = (amount * sellTax) / taxDenominator;

            // Do not check max wallet as market pairs are allowed to exceed it.

            return fees;
        }
    }

    function _baseTransfer(address to, uint256 amount) internal view returns (uint256) {
        unchecked {
            require(balanceOf[to] + amount <= maxWallet, "balance exceeds max wallet");

            return (amount * transferTax) / taxDenominator;
        }
    }

    function _calcFees(address to, uint256 amount, bool isBuy, bool isSell) internal view returns (uint256) {
        if(isBuy) {
            return _buyTransfer(to, amount);
        }
        if(isSell) {
            return _sellTransfer(amount);
        }
        return _baseTransfer(to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 balance = balanceOf[from];
        require(balance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            balanceOf[from] = balance - amount;
        }

        walletState memory fromWalletState = _walletState[from];
        walletState memory toWalletState = _walletState[to];

        uint256 fees = 0;
        bool takeFee = !fromWalletState.isExcludedFromFees && !toWalletState.isExcludedFromFees;

        // Tax and enforce limits appriopriately.
        if(takeFee) {
            bool isBuy = fromWalletState.isMarketPair;
            bool isSell = toWalletState.isMarketPair;

            fees = _calcFees(to, amount, isBuy, isSell);
        }

        // Add the amount minus fees to the receiver.
        uint256 amountMinusFees;
        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        // fees is less than amount, so it can't overflow.
        unchecked {
            amountMinusFees = amount - fees;
            balanceOf[to] += amountMinusFees;
        }
        emit Transfer(from, to, amountMinusFees);

        // Add any fees collected to the contract.
        if(fees > 0) {
            emit Transfer(from, taxRecipient, fees);
            unchecked {
                balanceOf[taxRecipient] += fees;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                             OWNER-ONLY
    //////////////////////////////////////////////////////////////*/

    function setMarketPair(address account, bool value) external onlyOwner {
        require(account != address(this), "cant change contract");
        _walletState[account].isMarketPair = value;
        emit MarketPairUpdated(account, value);
    }

    function setExcludedFromFees(address account, bool value) external onlyOwner {
        require(account != address(this), "cant change contract");
        _walletState[account].isExcludedFromFees = value;
        emit ExcludedFromFeesUpdated(account, value);
    }

    function setTaxRecipient(address account) external onlyOwner {
        taxRecipient = account;
        emit TaxRecipientUpdated(account);
    }

    function Unpause() external onlyOwner {
        _unpause();
    }

    function Pause() external onlyOwner {
        _pause();
    }

    /*//////////////////////////////////////////////////////////////
                             PAUSABLE OVERRIDES
    //////////////////////////////////////////////////////////////*/

    // Override the requireNotPaused implementation to allow the owner
    // to interact with the contract while it is paused. This allows the
    // owner to airdrop tokens or add liquidity while in a paused state.
    function _requireNotPaused() internal view override{
        if(paused()) {
            if(tx.origin != owner() && msg.sender != owner()) {
                revert EnforcedPause();
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }
}