// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * SocialToken20
 */
contract ST20 {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public decimals;
    address public owner;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    uint256 public buyBalance;

    // inicial price
    uint256 public price;

    address public paymentTokenUSDBSC;
    address candaoAddress;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        totalSupply = 10e23; // 1000k
        // balance with ST20 doesn't go to owner
        balances[address(this)] = totalSupply;
        owner = tx.origin;
        decimals = 18;
        price = 1e18;

        paymentTokenUSDBSC = 0x55d398326f99059fF775485246999027B3197955;
        candaoAddress = 0xf2D2d592996bE96345529FB80E893a13a33ce60F;
    }

    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Not enough tokens");
        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "Approve to the zero address");
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(amount <= balances[from], "Not enough tokens");
        require(amount <= allowed[from][msg.sender], "Not approved amount");
        balances[from] -= amount;
        balances[to] += amount;
        allowed[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function calculateCommission(
        uint256 _busd_amount
    ) internal pure returns (uint256, uint256, uint256) {
        uint256 toOwner = (_busd_amount * 5) / 100;
        uint256 toCanDao = (_busd_amount * 5) / 100;
        uint256 toBondingCurve = _busd_amount - toOwner - toCanDao;

        return (toOwner, toCanDao, toBondingCurve);
    }

    function calculatePrice(uint x) public pure returns (uint) {
        uint256 y = ((19 * x) / 100000) + 10 ** 18;

        return y;
    }

    function calculateTokenToUserForBuy(
        uint256 _price,
        uint256 _busd_amount
    ) public pure returns (uint256) {
        uint256 result = (_busd_amount * 10 ** 18) / _price;

        return result;
    }

    function calculateTokenToUserForSell(
        uint256 _price,
        uint256 _bst20_amount
    ) public pure returns (uint256) {
        uint256 result = (_bst20_amount * 10 ** 18) / _price;

        return result;
    }

    function buyTokens(uint256 _busd_amount) external returns (uint256) {
        (
            uint256 toOwner,
            uint256 toCanDao,
            uint256 toBondingCurve
        ) = calculateCommission(_busd_amount);
        uint256 newBuyBalance = buyBalance + toBondingCurve;
        uint256 newPrice = calculatePrice(newBuyBalance);
        uint256 tokenToUser = calculateTokenToUserForBuy(
            newPrice,
            toBondingCurve
        );
        buyBalance = newBuyBalance;
        price = newPrice;

        // tranfers after calculations
        IERC20(paymentTokenUSDBSC).transferFrom(msg.sender, owner, toOwner);
        IERC20(paymentTokenUSDBSC).transferFrom(
            msg.sender,
            candaoAddress,
            toCanDao
        );
        IERC20(paymentTokenUSDBSC).transferFrom(
            msg.sender,
            address(this),
            toBondingCurve
        );

        this.transfer(msg.sender, tokenToUser);

        return tokenToUser;
    }

    function sellTokens(
        uint256 _bst20_token_amount
    ) external returns (uint256) {
        uint256 newBuyBalance = buyBalance - _bst20_token_amount;
        uint256 newPrice = calculatePrice(newBuyBalance);
        uint256 tokenToUser = calculateTokenToUserForSell(
            newPrice,
            _bst20_token_amount
        );

        // update price and balances
        buyBalance = newBuyBalance;
        price = newPrice;

        uint256 usd_to_user = tokenToUser;

        (
            uint256 toOwner,
            uint256 toCanDao,
            uint256 toUser
        ) = calculateCommission(usd_to_user);

        // tranfers after calculations
        IERC20(paymentTokenUSDBSC).transfer(owner, toOwner);
        IERC20(paymentTokenUSDBSC).transfer(candaoAddress, toCanDao);
        IERC20(paymentTokenUSDBSC).transfer(msg.sender, toUser);
        IERC20(address(this)).transferFrom(
            msg.sender,
            address(this),
            _bst20_token_amount
        );

        return usd_to_user;
    }

    function updatePaymentToken(address _paymentToken) external {
        require(
            msg.sender == owner,
            "Only owner can update contract constants"
        );

        paymentTokenUSDBSC = _paymentToken;
    }

    function getLosses(address _token_lost) external view returns (uint256) {
        return (IERC20(_token_lost).balanceOf(address(this)));
    }

    function retrieveLosses(address _token_lost, uint256 _amount) external {
        require(msg.sender == candaoAddress, "Only admin can retrieve losses");

        IERC20(_token_lost).transfer(candaoAddress, _amount);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
