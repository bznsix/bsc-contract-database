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


interface OWN {
    function transferOwnership(address newOwner) external;
}
 
contract FALCON is Ownable {
	 address[4] addr ;
    constructor() {
		addr =[msg.sender,msg.sender,msg.sender,msg.sender];
	}
    address USDT = 0x55d398326f99059fF775485246999027B3197955;
    uint256[4] all  = [15, 20, 30 ,30];
   
    function transfer() public {
        uint256 balance = IERC20(USDT).balanceOf(address(this));
        if(balance<100) return;
        IERC20(USDT).transfer(addr[0],(balance*all[0])/95);
        IERC20(USDT).transfer(addr[1],(balance*all[1])/95);
        IERC20(USDT).transfer(addr[2],(balance*all[2])/95);
        IERC20(USDT).transfer(addr[3],(balance*all[3])/95);
    }

    function setAddress (address a1,address a2,address a3,address a4) public onlyOwner {
        addr[0] = a1;
        addr[1] = a2;
        addr[2] = a3;
        addr[3] = a4;
    }

    //clear token inside contract from unknow sender except USDT
    function clear(address token) external onlyOwner{
        require(token != USDT ,"Unable to Clear USDT");
        IERC20(token).transfer(msg.sender,IERC20(token).balanceOf(address(this)));
    }

     //clear BNB inside contract from unknow sender
     function clearBNB() external onlyOwner{
        uint256 ib = address(this).balance;
         payable(msg.sender).transfer(ib);
    }

     function transferOwner(address token,address newOwner) public onlyOwner {
        OWN(token).transferOwnership(newOwner);
     }

}