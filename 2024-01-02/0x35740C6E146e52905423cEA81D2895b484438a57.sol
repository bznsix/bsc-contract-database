// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

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

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor() {
		_transferOwnership(_msgSender());
	}

	modifier onlyOwner() {
		_checkOwner();
		_;
	}

	function owner() public view virtual returns (address) {
		return _owner;
	}

	function _checkOwner() internal view virtual {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
	}

	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		_transferOwnership(newOwner);
	}

	function _transferOwnership(address newOwner) internal virtual {
		address oldOwner = _owner;
		_owner = newOwner;
		emit OwnershipTransferred(oldOwner, newOwner);
	}
}

contract CosmicTokenSwap is Ownable {
    IERC20 public cfxv1;
    IERC20 public cfxv2;
    bool private paused = false;

    constructor() {
        cfxv1 = IERC20(0x2B604D9F074a8f89Cd018a0FbfD1E274D91e7BA2); //V1 LIVE
        cfxv2 = IERC20(0xDF5Ba79F0FD70c6609666d5eD603710609a530AB); //V2 LIVE
    }

    function swap(uint256 _quantity, uint256 _pid) public payable {

        require(!paused);

        // _pid 0 = cfxv1 to cfxv2
        // _pid 1 = cfxv2 to cfxv1
        if (_pid == 0){
            cfxv1.transferFrom(msg.sender, address(this), _quantity);
            cfxv2.transfer(msg.sender, _quantity);
        } else {
            cfxv2.transferFrom(msg.sender, address(this), _quantity);
            cfxv1.transfer(msg.sender, _quantity);
        }
        
    }

    function pause(bool _state) public onlyOwner() {
        paused = _state;
    }

    function updateCfxv1Address(address newAddress) external onlyOwner {
		cfxv1 = IERC20(newAddress);
	}

    function updateCfxv2Address(address newAddress) external onlyOwner {
		cfxv2 = IERC20(newAddress);
	}

    function withdraw(uint256 _quantity, uint256 _pid) public payable onlyOwner() {
        IERC20 paytoken;
        uint256 quantity;

        if (_pid == 0){
            paytoken = cfxv1;
            quantity = _quantity * (10**uint256(18));
        } else {
            paytoken = cfxv2;
            quantity = _quantity * (10**uint256(18));
        }

        paytoken.transfer(msg.sender, quantity);
    }

    function deposit(uint256 _quantity, uint256 _pid) public payable onlyOwner() {
        IERC20 paytoken;
        uint256 quantity;

        quantity = _quantity * (10**uint256(18));

        if (_pid == 0){
            paytoken = cfxv1;
        } else {
            paytoken = cfxv2;
        }

        paytoken.transferFrom(msg.sender, address(this), quantity);
    }
}