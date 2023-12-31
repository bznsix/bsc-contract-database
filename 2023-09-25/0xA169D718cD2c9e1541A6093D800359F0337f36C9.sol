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
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSale {
    IERC20 public token;
    address payable public owner;
    uint256 public tokensPerBnb = 5000;
    uint256 public minPurchaseBnb = 1e17; // 0.1 BNB

    uint256 public saleStartTime;
    uint256 public saleEndTime;

    event Purchase(address buyer, uint256 amount, address referrer);

    constructor(IERC20 _token) {
        token = _token;
        owner = payable(msg.sender);
    }

    function setSaleTime(uint256 _startTime, uint256 _endTime) external {
        require(msg.sender == owner, "Only owner can set the sale time");
        require(_startTime < _endTime, "Start time must be before end time");
        require(_endTime > block.timestamp, "End time must be in the future");
        saleStartTime = _startTime;
        saleEndTime = _endTime;
    }

    function buyTokens(address referrer) external payable {
        require(block.timestamp >= saleStartTime && block.timestamp <= saleEndTime, "Sale not active");
        require(msg.value >= minPurchaseBnb, "Not enough BNB sent");

        uint256 tokensToBuy = msg.value * tokensPerBnb;
        require(token.balanceOf(address(this)) >= tokensToBuy, "Not enough tokens left for sale");

        // transfer tokens to buyer
        token.transfer(msg.sender, tokensToBuy);

        // transfer referral rewards
        if (referrer != address(0)) { // Check if referrer is not the zero address
            uint256 referralBnb = msg.value / 10; // 10% of BNB
            uint256 referralTokens = tokensToBuy / 10; // 10% of tokens
            payable(referrer).transfer(referralBnb);
            token.transfer(referrer, referralTokens);
        }

        // transfer remaining BNB to owner
        owner.transfer(address(this).balance);

        emit Purchase(msg.sender, tokensToBuy, referrer);
    }

    // in case of any remaining tokens after sale ends
    function withdrawTokens() external {
        require(msg.sender == owner, "Only owner can withdraw");
        token.transfer(owner, token.balanceOf(address(this)));
    }
}
