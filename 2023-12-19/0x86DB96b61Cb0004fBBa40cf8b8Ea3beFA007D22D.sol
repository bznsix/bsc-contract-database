/**
 *Submitted for verification at BscScan.com on 2023-11-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() 
    {   _status = _NOT_ENTERED;     }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
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
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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

contract metaSwiftWithdrawl is Ownable, ReentrancyGuard{
    using SafeMath for uint256;

    IERC20 public USDT;

    event TokensSent(address indexed contributor, uint256 amount);

    constructor(address _token)
    { 
        USDT = IERC20(_token); 
    }
    
    function multisendToken(address[] calldata contributors, uint256[] calldata balances) 
    external 
    onlyOwner
    {
        require(contributors.length == balances.length, "Array lengths must match");
        for (uint256 i = 0; i < contributors.length; i++) 
        { 
            USDT.transfer(contributors[i], balances[i]);
            emit TokensSent(contributors[i], balances[i]);
        }
    }

    function emergencyWithdrawUSDTToken()
    external
    onlyOwner
    {   require(USDT.transfer(owner(),(USDT.balanceOf(address(this)))),"transfer failed!");   }

    function rescueToken(uint256 _amount)
    external 
    onlyOwner
    {
        require(USDT.balanceOf(address(this)) >= _amount, "insufficient Balance!");
        require(USDT.transfer(msg.sender,_amount),"transfer failed!");
    }

}