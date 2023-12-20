// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^ 0.8 .20;
abstract contract Context {
	function _msgSender() internal view virtual returns(address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns(bytes calldata) {
		return msg.data;
	}
}
abstract contract Ownable is Context {
	address private _owner;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor() {
		_transferOwnership(_msgSender());
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
	function owner() public view virtual returns(address) {
		return _owner;
	}
	/**
	 * @dev Throws if the sender is not the owner.
	 */
	function _checkOwner() internal view virtual {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
	}
	/**
	 * @dev Leaves the contract without owner. It will not be possible to call
	 * `onlyOwner` functions anymore. Can only be called by the current owner.
	 *
	 * NOTE: Renouncing ownership will leave the contract without an owner,
	 * thereby removing any functionality that is only available to the owner.
	 */
	function renounceOwnership() public virtual onlyOwner {
		_transferOwnership(address(0));
	}
	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 * Can only be called by the current owner.
	 */
	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
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
interface IERC20 {
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	function totalSupply() external view returns(uint256);
	function balanceOf(address account) external view returns(uint256);
	function transfer(address to, uint256 amount) external returns(bool);
	function allowance(address owner, address spender) external view returns(uint256);
	function approve(address spender, uint256 amount) external returns(bool);
	function transferFrom(address from, address to, uint256 amount) external returns(bool);
}
 
contract FALCON is Ownable {
  
    address USDT = 0x55d398326f99059fF775485246999027B3197955;
	address pool;
    constructor() { 
		pool = msg.sender;   
    }
	struct deposit_log {
	    uint256 pid;
		address sp;
		address addr; 
		uint256 time;
		uint256 amount;
	}
    mapping (uint256 => deposit_log ) public deposit_logs;
    uint256 public starting = 800;
	
	function set(address p) public {
		require(msg.sender == pool);
		pool = p;
	}
 
	function deposit(uint256 pid,uint256 amount, address sponsor) public {
		
		require(pid>=0 && pid<=4,"Invalid pid");
		require(amount >= 10e18, "Minimum invest 10" );
	 
		IERC20(USDT).transferFrom(msg.sender,pool,(amount*25)/1000);
		IERC20(USDT).transferFrom(msg.sender,owner(),(amount*975)/1000);
		starting++;
		deposit_log storage st = deposit_logs[starting];
			  st.pid=pid;
			  st.sp=sponsor;
			  st.addr=msg.sender;
		      st.time=block.timestamp;
		      st.amount=amount;    
	}

}