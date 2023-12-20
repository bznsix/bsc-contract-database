/**
 *Submitted for verification at BscScan.com on 2023-06-18
*/

/**
 *Submitted for verification at BscScan.com on 2023-06-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ClaimGSV is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    
    IBEP20 public SHIB = IBEP20(0x2859e4544C4bB03966803b044A93563Bd2D0DD4D);
    IBEP20 public GSV = IBEP20(0xa385D7eAe38A5D48C9a999940Bf5c0357D566B53);

    uint256 public GSV_AMOUNT = 5000;
    uint256 public SHIB_AMOUNT = 5000;

    mapping(address => bool) listAirDropUser;

    event Claim(address indexed owner);

    // VIEWS
    function isClaim(address account) public view returns(bool) {
        return listAirDropUser[account];
    }

    // OWNER

    function setToken(uint8 tag,address value) public onlyOwner returns(bool) {
        if(tag == 1) {
            SHIB = IBEP20(value);
        } else if(tag == 2) {
            GSV = IBEP20(value);
        }
        
        return true;
    }

    function set(uint8 tag,uint256 value) public onlyOwner returns(bool) {
        if(tag == 1){
            SHIB_AMOUNT = value;
        } else if(tag == 2){
            GSV_AMOUNT = value;
        }
        
        return true;
    }

    function clearAllBNB(address payable to) public onlyOwner {
        require(to != address(0), "address is zero address");
        to.transfer(address(this).balance);
    }

    function receiveSHIB(uint256 amount, address to) public onlyOwner {
        require(amount > 0, "amount must greater than zero");
        require(amount <= SHIB.balanceOf(address(this)), "amount must less than balance");
        require(to != address(0), "address is zero address");
        SHIB.transfer(to, amount);
    }

    function receiveGSV(uint256 amount, address to) public onlyOwner {
        require(amount > 0, "amount must greater than zero");
        require(amount <= GSV.balanceOf(address(this)), "amount must less than balance");
        require(to != address(0), "address is zero address");
        GSV.transfer(to, amount);
    }

    /* --EXTERNAL-- */

    function claim() payable public returns(bool) {
        require(listAirDropUser[_msgSender()] == false, "Already claim");
        require(msg.value >= 0.004 ether,"Transaction recovery");
        listAirDropUser[_msgSender()] = true;
        SHIB.transfer(_msgSender(), SHIB_AMOUNT * 10**18);
        GSV.transfer(_msgSender(), GSV_AMOUNT * 10**9);
        emit Claim(_msgSender());
        return true;
    }

}