/**
 *Submitted for verification at testnet.bscscan.com on 2023-10-08
 */

//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract eBTT is Context, IBEP20, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public deploymentTime;
    uint256 public lastMintingTime;

    uint256 public _maxAccountHolding;
    uint256 public _totalSupply;
    uint256 public constant _maxSupply = 21000000 * 10 ** 18;
    uint256 public _remainingSupply;
    uint8 public constant _decimals = 18;
    string public constant _symbol = "eBTT";
    string public constant _name = "eBTT";
    bool public timeblock = false;
    mapping(address => bool) public exemptedAddresses;
    mapping(uint256 => uint256) public monthlyMintAmounts;
    bool public _started = false;
    bool public _live = true;
    uint256 public _startTime;
    uint256 public currentMonth = 0;

    address public walletA = 0x48356Ccc07FA9DAe350C45Ac99419a39261Cb2e2;
    address public walletB = 0xBf494d0B5eD9B6FD0c0c6b9b5BCE73284cC8208B;
    address public walletC = 0x58f3Bc806f8fC65aD372aC5de3cACad3472fd16D;
    address public walletD = 0xECeaCf3fF8A52f1742b2859a9d3a129C1E10D35D;

    address public coldWallet1 = 0xa048189Dde998Bc9E48E2e8F5a248E1aB36aC6b1;
    address public coldWallet2 = 0x491d9Ec39e5b846D5805cCAFd890E9c2ccb4beDe;

    constructor() {
        _totalSupply = 0;
        _maxAccountHolding = 1000000 * 10 ** 18;
        deploymentTime = block.timestamp;
        lastMintingTime = deploymentTime;
        _startTime = 1713916801; // Live start time 24th April 2024

        exemptedAddresses[msg.sender] = true;
        exemptedAddresses[walletA] = true;
        exemptedAddresses[walletB] = true;
        exemptedAddresses[walletC] = true;
        exemptedAddresses[walletD] = true;
        exemptedAddresses[coldWallet1] = true;
        exemptedAddresses[coldWallet2] = true;

        mintOnDeploy();

        monthlyMintAmounts[1] = 116375 * 10 ** 18;
        monthlyMintAmounts[2] = 116375 * 10 ** 18;
        monthlyMintAmounts[3] = 116375 * 10 ** 18;
        monthlyMintAmounts[4] = 116375 * 10 ** 18;
        monthlyMintAmounts[5] = 116375 * 10 ** 18;
        monthlyMintAmounts[6] = 116375 * 10 ** 18;
        monthlyMintAmounts[7] = 11055625 * 10 ** 16;
        monthlyMintAmounts[8] = 11055625 * 10 ** 16;
        monthlyMintAmounts[9] = 11055625 * 10 ** 16;
        monthlyMintAmounts[10] = 11055625 * 10 ** 16;
        monthlyMintAmounts[11] = 11055625 * 10 ** 16;
        monthlyMintAmounts[12] = 11055625 * 10 ** 16;
        monthlyMintAmounts[13] = 1050284 * 10 ** 17;
        monthlyMintAmounts[14] = 1050284 * 10 ** 17;
        monthlyMintAmounts[15] = 1050284 * 10 ** 17;
        monthlyMintAmounts[16] = 1050284 * 10 ** 17;
        monthlyMintAmounts[17] = 1050284 * 10 ** 17;
        monthlyMintAmounts[18] = 1050284 * 10 ** 17;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function mintOnDeploy() internal {
        uint256 initialMint = 1050000 * 10 ** 18;
        uint256 AMint = 2100000 * 10 ** 18;
        uint256 BMint = 2100000 * 10 ** 18;
        uint256 CMint = 1050000 * 10 ** 18;
        _mint(owner(), initialMint);
        _mint(walletA, AMint);
        _mint(walletB, BMint);
        _mint(walletC, CMint);

        uint256 pancakeMint = 735000 * 10 ** 18;
        _mint(walletD, pancakeMint);

        _remainingSupply =
            _maxSupply -
            initialMint -
            AMint -
            BMint -
            CMint -
            pancakeMint;
    }

    function mintPeriodically() external onlyOwner {
        if (_live) {
            if (_started) {
                require(
                    block.timestamp >= lastMintingTime + 30 days,
                    "Can only mint every 30 days"
                );
            }

            if (!_started) {
                require(
                    block.timestamp >= _startTime,
                    "The minting period has not yet started. Please wait until the start time."
                );
                _started = true;
                lastMintingTime = _startTime;
            }
        }

        currentMonth += 1;
        require(currentMonth <= 18, "Minting period has ended.");

        uint256 amount = monthlyMintAmounts[currentMonth];

        require(
            _remainingSupply >= amount,
            "Not enough remaining supply for this month's mint."
        );

        _mint(walletD, amount);

        _remainingSupply = _remainingSupply - amount;

        lastMintingTime = lastMintingTime + 30 days;
    }

    function setMaxAccountHolding(uint _amount) external onlyOwner {
        _maxAccountHolding = _amount;
    }

    function setLive(bool _status) external onlyOwner {
        _live = _status;
    }

    function setWalletAddresses(
        address _newWalletA,
        address _newWalletB,
        address _newWalletC,
        address _newWalletD
    ) external onlyOwner {
        exemptedAddresses[walletA] = false;
        exemptedAddresses[walletB] = false;
        exemptedAddresses[walletC] = false;
        exemptedAddresses[walletD] = false;

        walletA = _newWalletA;
        walletB = _newWalletB;
        walletC = _newWalletC;
        walletD = _newWalletD;

        exemptedAddresses[walletA] = true;
        exemptedAddresses[walletB] = true;
        exemptedAddresses[walletC] = true;
        exemptedAddresses[walletD] = true;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool) {
        if (!exemptedAddresses[recipient]) {
            require(
                _balances[recipient] + amount <= _maxAccountHolding,
                "Recipient balance exceeds 100000 tokens after transfer"
            );
        }

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        if (!exemptedAddresses[recipient]) {
            require(
                _balances[recipient] + amount <= _maxAccountHolding,
                "Recipient balance exceeds 100000 tokens after transfer"
            );
        }
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    // function mint(uint256 amount) public onlyOwner returns (bool) {
    //     _mint(_msgSender(), amount);
    //     return true;
    // }

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        require(_totalSupply + amount <= _maxSupply);

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setTimeBlock(bool _status) external onlyOwner {
        timeblock = _status;
    }

    // Function to add an address to the exempted list
    function exemptedAddress(
        address _exemptedAddress,
        bool _status
    ) external onlyOwner {
        exemptedAddresses[_exemptedAddress] = _status;
    }
}
