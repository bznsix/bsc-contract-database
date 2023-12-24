// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function balances(address _address) external view returns (uint256);

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
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}


contract WorldBnbPool {

    address private _owner;

    bool private isClaiming = false;

    modifier nonReentrant() {
        require(!isClaiming, "Function is reentrant");
        isClaiming = true;
        _;
        isClaiming = false;
    }

    address[] public eligibleWalletsArr;
    mapping(address => uint256) public eligibleWallets;
    mapping(address => uint256) public claimList;

    address public tokenAddress = 0x3da6755bb5CBa4c7228272eEd00E258B4aa7a5F3;
    uint256 public totalHoldersAmount = 0;

    uint256 public claimBalanceNow = 0;
    uint256 public claimBalanceNowTotal = 0;
    uint256 public contractBalance = 0;

    IBEP20 public tokenContract;

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    modifier onlyOwn() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    event Received(address indexed sender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
        tokenContract = IBEP20(tokenAddress);
    }

    function transferOwnership(address newOwner) public onlyOwn {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }


    receive() external payable {
        // Обработка получения эфира
        contractBalance = address(this).balance;
        emit Received(msg.sender, msg.value);
        
    }


    function setEligibleWallets(address[] calldata wallets) public onlyOwn {
        for (uint i = 0; i < eligibleWalletsArr.length; i++) {
            eligibleWallets[eligibleWalletsArr[i]] = 0;
            claimList[eligibleWalletsArr[i]] = 0;
        }

        eligibleWalletsArr = wallets;
        totalHoldersAmount = 0;

        for (uint i = 0; i < eligibleWalletsArr.length; i++) {
            uint256 balance = tokenContract.balanceOf(eligibleWalletsArr[i]);
            eligibleWallets[eligibleWalletsArr[i]] = balance;
            totalHoldersAmount += balance;
        }

        claimBalanceNow = address(this).balance;
        claimBalanceNowTotal = claimBalanceNow;
    }


    function withdrawBNB(uint256 amount, address payable wallet) public onlyOwn {
        require(address(this).balance >= amount, "Insufficient balance in the contract");
        (bool success, ) = wallet.call{value: amount}("");
        require(success, "Transfer failed");
    }


    function getClaimBalanceNow() public view returns (uint256) {
        return claimBalanceNow;
    }

    function getClaimBalanceNowTotal() public view returns (uint256) {
        return claimBalanceNowTotal;
    }


    function getClaimBalanceNext() public view returns (uint256) {
        return contractBalance - claimBalanceNow;
    }

    function getClaimOfWallet() public view returns (uint256) {
        if(eligibleWallets[_msgSender()] > 0 && claimList[_msgSender()] == 0){
            uint256 percent = eligibleWallets[_msgSender()]*100/totalHoldersAmount;
            return claimBalanceNowTotal*percent/100;
        } else {
            return 0;
        }
    }


    function claim() external nonReentrant {
        if(eligibleWallets[_msgSender()] > 0 && claimList[_msgSender()] == 0){
            uint256 claimAmount = getClaimOfWallet();
            payable(_msgSender()).transfer(claimAmount);
            claimList[_msgSender()] = 1;
            claimBalanceNow -= claimAmount;
            contractBalance = address(this).balance;
        }
    }

}