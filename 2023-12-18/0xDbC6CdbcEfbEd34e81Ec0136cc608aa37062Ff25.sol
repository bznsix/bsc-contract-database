// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract TokenPresale {
    IERC20 public token;
    address public owner;
    uint256 public price;
    bool public presaleActive;
    mapping(address => uint256) public balances;
    uint256 public stage;
    uint256 public token_limit;
    uint256 public token_sold;

    constructor(uint256 _stage, uint256 _token_limit, uint256 _price) {
        owner = msg.sender;
        stage = _stage;
        token_limit = _token_limit;
        price = _price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function setToken(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0), "Token address cannot be the zero address");
        token = IERC20(_tokenAddress);
    }

    function setPrice(uint256 _price, uint256 _stage, uint256 _token_limit) external onlyOwner {
        require(_price > 0, "Price must be greater than zero");
        price = _price;
        stage = _stage;
        token_limit = _token_limit;
    }

    function buyTokens() external payable {
        require(presaleActive, "Presale is not active");
        require(msg.value > 0, "Amount must be greater than zero");
        require(token_sold < token_limit, "Token limit reached");
        uint256 amountToBuy = msg.value / price * 10 ** 18;
        balances[msg.sender] += amountToBuy;
        token_sold += amountToBuy;
    }

    function withdrawTokens() external {
        require(presaleActive == false, "Presale is still active");
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No tokens to withdraw");
        balances[msg.sender] = 0;
        token.transfer(msg.sender, amount);
    }

    function withdrawEther() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No Ether to withdraw");
        payable(owner).transfer(balance);
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function changePresaleStatus() external onlyOwner {
        presaleActive = !presaleActive;
    }
}