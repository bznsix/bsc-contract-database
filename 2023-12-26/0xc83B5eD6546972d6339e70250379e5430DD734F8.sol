/**
 *Submitted for verification at BscScan.com on 2023-12-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor(address _addr) {
        _owner = _addr;
        emit OwnershipTransferred(address(0), _addr);
    }
    function owner() public view returns(address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ERC20 {

    function totalSupply() external view returns(uint256);

    function balanceOf(address account) external view returns(uint256);

    function transfer(address recipient, uint256 amount) external returns(bool);

    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract NET is Ownable {
    using SafeMath for uint;
   	address public makerAdr_1=0xB29132A21f982A538F58C93310B6336E907A871C;
	address public makerAdr_2=0xB29132A21f982A538F58C93310B6336E907A871C;
	address public makerAdr_3=0xB29132A21f982A538F58C93310B6336E907A871C;
    address public makerAdr_4=0x000000000000000000000000000000000000dEaD;
 
    mapping(address => uint256) public buy_lists;
	
	mapping(address => uint256) public buy_lists_one;

    uint public unlocked=1;
    modifier lock() {
        require(unlocked == 1, 'LOCKED1');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() Ownable(msg.sender) {
	}
	
	function ismakerAdr_1(address addr) public onlyOwner {
        makerAdr_1 = addr;
    }
	function ismakerAdr_2(address addr) public onlyOwner {
        makerAdr_2= addr;
    }
	function ismakerAdr_3(address addr) public onlyOwner {
        makerAdr_3= addr;
    }

    
 	 
	
	
	function Deposit(address address_A, address address_B, uint256 amount_A, uint256 amount_B, uint256 type_id) lock public payable {
        require(block.timestamp.sub(buy_lists[msg.sender])>300,"NO");
        buy_lists[msg.sender]=block.timestamp;
       
	    ERC20(address_A).transferFrom(msg.sender, address(this), amount_A);
		ERC20(address_B).transferFrom(msg.sender, address(this), amount_B);
 
		
		uint256 a_1_1=amount_A.mul(100).div(90).mul(70).div(100);
		uint256 a_1_2=amount_A.sub(a_1_1);
		
		
		uint256 a_2_1=amount_B.mul(90).div(100);
		uint256 a_2_2=amount_B.sub(a_2_1);
		 
		ERC20(address_A).transfer(makerAdr_1, a_1_1);
		ERC20(address_B).transfer(makerAdr_1, a_2_1);	
		
		
		ERC20(address_A).transfer(makerAdr_2, a_1_2);
		ERC20(address_B).transfer(makerAdr_2, a_2_2);	
	 
 
    }
    function Deposit_fee(address address_A, address address_B, uint256 amount_A, uint256 amount_B, uint256 amount_C, uint256 type_id) lock public payable {
        require(block.timestamp.sub(buy_lists[msg.sender])>300,"NO");
        buy_lists[msg.sender]=block.timestamp;
       
	    ERC20(address_A).transferFrom(msg.sender, address(this), amount_A);
		ERC20(address_B).transferFrom(msg.sender, address(this), amount_B.add(amount_C));
 
		
		uint256 a_1_1=amount_A.mul(100).div(90).mul(70).div(100);
		uint256 a_1_2=amount_A.sub(a_1_1);
		
		
		uint256 a_2_1=amount_B.mul(90).div(100);
		uint256 a_2_2=amount_B.sub(a_2_1);
		 
		ERC20(address_A).transfer(makerAdr_1, a_1_1);
		ERC20(address_B).transfer(makerAdr_1, a_2_1);	
		
		
		ERC20(address_A).transfer(makerAdr_2, a_1_2);
		ERC20(address_B).transfer(makerAdr_3, a_2_2);	

        ERC20(address_B).transfer(makerAdr_4, amount_C);	
	 
 
    }
	function Deposit_one(address address_A, uint256 amount_A) lock public payable {
        require(block.timestamp.sub(buy_lists_one[msg.sender])>300,"NO");
        buy_lists_one[msg.sender]=block.timestamp;
       
	    ERC20(address_A).transferFrom(msg.sender, address(this), amount_A);
		 
		 
		ERC20(address_A).transfer(makerAdr_3, amount_A);
		 
		 
		 
		
 
    }
	
	
	function tran_bnb(uint256 _id) public {

 
    }
    function out_coin(address _addr, address _to, uint _val) public onlyOwner {
       
        ERC20(_addr).transfer(_to, _val);

    }
	
	 
	
    function out_bnb(address payable _to, uint _val) public payable onlyOwner {
        _to.transfer(_val);

    }
	 

}