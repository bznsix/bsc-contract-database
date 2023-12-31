// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@openzeppelin/contracts/interfaces/IERC20.sol';

contract BUSDShareDistributor {

    address[] private holders;
    uint[] private shares;
    mapping(address => bool) public admins;
    IERC20 public BUSD;

    modifier onlyOwner() {
        require(admins[msg.sender] == true, "Not allowed");
        _;
    }

    constructor(address _BUSDAddr) {
        admins[msg.sender] = true;
        BUSD = IERC20(_BUSDAddr);
    }
    
    receive() external payable {}

    event NewDistribution(uint amount);
    event NewHolderAdded(address holder, uint share);
    event NewHolderRemoved(address holder);

    function distributeFunds() external onlyOwner {
        uint256 contractBal = contractBUSDBalance();
        require(contractBal > 0, "No funds in contract");
        
        //Check if total share is 100% before proceeding
        uint totalSharePercent = 0;
        for(uint8 i=0; i < shares.length; i++) {
            totalSharePercent += shares[i];
        }
        require(totalSharePercent == 10000, "All shares do not add up to 100%");

        //Distribute
        for(uint8 i=0; i < holders.length; i++) {
            BUSD.transfer(holders[i], contractBal*shares[i]/10000);
        }

        emit NewDistribution(contractBal);
    }

    //Add holders
    function addHolders(address[] calldata _holders, uint[] calldata _shares) public onlyOwner {
        require(_holders.length == _shares.length, "Mismatch arrays");
        
        for(uint8 i=0; i < _holders.length; i++) {
            holders.push(_holders[i]);
            shares.push(_shares[i]);
            emit NewHolderAdded(holders[i], _shares[i]);
        }

    }
    
    //remove holder
    function removeHolders(uint[] calldata _holderIndex) external onlyOwner {
        for(uint8 i=0; i < _holderIndex.length; i++) {
            require(_holderIndex[i] < holders.length, "Invalid holder index");
            emit NewHolderRemoved(holders[_holderIndex[i]]);
            holders[_holderIndex[i]] = holders[holders.length-1];
            holders.pop();
            shares[_holderIndex[i]] = shares[shares.length-1];
            shares.pop();
        }
    }

    function deleteAllHolders() public onlyOwner {
        holders = new address[](0);
        shares = new uint[](0);
    }

    function updateAdmin(address _admin, bool _status) external onlyOwner {
        admins[_admin] = _status;
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function contractBUSDBalance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    function showHolders() public view returns (address[] memory) {
        return holders;
    }

    function showShares() public view returns (uint[] memory) {
        return shares;
    }

}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
