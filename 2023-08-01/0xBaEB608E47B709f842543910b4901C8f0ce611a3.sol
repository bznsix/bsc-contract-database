// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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

contract Presale {
    address public owner;
    IERC20 public token;
    IERC20 public usdt;

    uint256 public startTime;
    uint256[10] public pricesInUsdt = [10000000000000000000, 5000000000000000000, 3333333333333333500, 2500000000000000000, 2000000000000000000, 1666666666666666700, 1428571428571428600, 1250000000000000000, 1111111111111111200, 1000000000000000000]; // Prices for each time interval
    uint256 public constant INCREMENT_INTERVAL = 30 days; // 1 minute in seconds
    uint256 public constant bnb_price = 250; // 1 minute in seconds
    uint256 public tokenPurchased = 0;
    constructor(address _token, address _usdt) {
        owner = 0x26F4a4B3BE6F5cd4c8a705b8ec6Cd7C6394d926b;
        token = IERC20(_token);
        usdt = IERC20(_usdt);
        startTime = block.timestamp;

    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    function currentPrice() public view returns (uint256) {
        if (block.timestamp < startTime) {
            return pricesInUsdt[0]; // Convert to wei
        }

        uint256 minutesSinceStart = (block.timestamp - startTime) / INCREMENT_INTERVAL;
        if (minutesSinceStart >= pricesInUsdt.length) {
            return pricesInUsdt[pricesInUsdt.length - 1]; // Convert to wei
        }

        return pricesInUsdt[minutesSinceStart]; // Convert to wei
    }

   
    function buyTokens(uint256 usdtAmountInWei) external {

        uint256 currentPrices = currentPrice();
        uint256 tokensToBuy = (usdtAmountInWei * currentPrices)/1000000000000000000;

        require(token.balanceOf(address(this)) >= tokensToBuy/1000000000000000000, "Not enough tokens in the contract");

        usdt.transferFrom(msg.sender, address(this), usdtAmountInWei);
        token.transfer(msg.sender, tokensToBuy/1000000000000000000);
        tokenPurchased += tokensToBuy/1000000000000000000;
    }
  function buyTokensNative() external payable  {
        uint256 currentPrices = currentPrice();
        uint256 tokensToBuyinDollar = msg.value * bnb_price;
    uint256 tokensToBuy = (tokensToBuyinDollar * currentPrices)/1000000000000000000;

        token.transfer(msg.sender, tokensToBuy/1000000000000000000);
         address payable contractOwner = payable(owner);
        contractOwner.transfer(msg.value);
                tokenPurchased += tokensToBuy/1000000000000000000;

    }
    function withdrawFunds() external onlyOwner {
        usdt.transfer(owner, usdt.balanceOf(address(this)));
    }

    function withdrawTokens() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "Presale: No tokens to withdraw");

        token.transfer(owner, balance);
    }
}