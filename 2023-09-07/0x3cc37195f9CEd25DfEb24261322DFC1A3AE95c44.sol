// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "./ozeppelin/Ownable.sol";
import "./MasterHonorInc/IBEP20.sol";

contract HnrAirdrop is Ownable {

    struct SaleToken
    {
        uint32  maxPerUser;
        uint32  maxSold;
        uint32  soldToken;
        uint256  startPrice;
        uint256  priceIncrement;
        uint  startBlock;
        uint  duration;
        uint blockPeriod;
    }
 

    mapping(address=>SaleToken) public _saleTokens;

    mapping(address => mapping(address=>uint32)) _userBalances;



    event TokenPurchased(address indexed buyer, address indexed tokenAddress,uint32 amount);

    function getUserBalance(address token,address user) public view returns(uint32) {
        return _userBalances[token][user];
    }
    
    function createSaleToken(address tokenAddress,uint32 maxPerUser,uint32 maxSold,
    uint256 startPrice,uint256 priceInc,uint256 startBlock,uint256 duration,uint256 blockPeriod) public onlyOwner {
        
        SaleToken storage saleToken=_saleTokens[tokenAddress];
        saleToken.maxPerUser=maxPerUser;
        saleToken.maxSold=maxSold;
        saleToken.startPrice=startPrice;
        saleToken.priceIncrement=priceInc;
        saleToken.startBlock=startBlock;
        saleToken.duration=duration;
        saleToken.blockPeriod=blockPeriod;

    }

    function getCurrentPrice(address tokenAddress) public view returns(uint256) {
         SaleToken memory saleToken=_saleTokens[tokenAddress];
         
        uint currentBlock=block.number;
        uint blocktime=currentBlock - saleToken.startBlock;
        uint periodCount=blocktime/saleToken.blockPeriod;
        uint256 priceIncrement=saleToken.priceIncrement * periodCount;
        return saleToken.startPrice + priceIncrement;
    }

    function getTotalPrice(address tokenAddress,uint32 amount) public view returns(uint256) {
        uint256 currentPrice=getCurrentPrice(tokenAddress);
        return currentPrice * amount;
    }
    function buyToken(address tokenAddress,uint32 amount) public payable {
        require(amount > 0, "Amount should be greater than zero");
        SaleToken storage saleToken=_saleTokens[tokenAddress];
        require((_userBalances[tokenAddress][msg.sender] + amount) <= saleToken.maxPerUser , "Exceeded maximum amount per address");
        require((saleToken.soldToken + amount) <= saleToken.maxSold, "Not enough tokens left for sale");
        require(block.number <= (saleToken.startBlock + saleToken.duration), "Sale Finished");

        uint256 currentPrice=getCurrentPrice(tokenAddress);
        uint256 totalPrice = currentPrice * uint256(amount);

        require(msg.value>=totalPrice,"Insufficient Balance");

        uint256 sendAmount = uint256(amount) * (10**18);

        IBEP20(tokenAddress).transfer(msg.sender,sendAmount);
        saleToken.soldToken += amount;

        _userBalances[tokenAddress][msg.sender] += amount;


        emit TokenPurchased(msg.sender, tokenAddress, amount);
    }
 


    // Contract owner can withdraw the BNB balance in the contract
    function withdrawFunds() external onlyOwner {
        require(address(this).balance > 0, "No BNB balance to withdraw");
        payable(owner()).transfer(address(this).balance);
    }

    // Contract owner can withdraw any remaining unsold tokens after the sale ends
    function withdrawUnsoldTokens(address token) external onlyOwner {
        IBEP20(token).transfer(owner(),IBEP20(token).balanceOf(address(this)));
    }
}// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Context.sol";
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}