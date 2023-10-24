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
 interface NFT721 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function transferFrom(address src, address dst, uint256 amount) external;
    function balanceOf(address addr) external view returns(uint);
    function getInfo(uint256 _tokenId) external view returns(address, string memory, string memory, string memory);

    function lastTokenId() external view returns(uint);

    function getToken(address _user) external view returns(uint);

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

contract CECCSTAKE is Ownable {
    using SafeMath for uint;
   	address public makerAdr_1=0x8CED3ef605d5CDEc929f9BEc42778372569B7b18;
	address public hold_addr=0x000000000000000000000000000000000000dEaD;
	address public usdt_addr=0x55d398326f99059fF775485246999027B3197955;
    
	
	address public ces_addr=0x16D73869D91ef46Fd3a9dC57e84162F58d112391;
	address public cecc_addr=0xb434f2bf9B1aB6C1a09513477aE0F1006de248fE;
	
	
	 
	
	address public nft_addr_1=0x5C898dF17390DAfbc0980E38Bb5D06F9887C9cdC;
	address public nft_addr_2=0x3179ABBBEC6061A5d998290fa6d76920f74929BF;
	address public nft_addr_3=0x4215a7A6DEDED55C69C2c3Cd918D1a814f64Dca1;
	address public nft_addr_4=0x5aFd3fB2A9528259bf6e12F42c2d1d7E516b0fF9;
	address public nft_addr_5=0xa4eCb5A396d447F0da9e6238ed4AE58906725Ff9;
	
	
 
	
	mapping(uint256 => uint256) public stake_num;
	
	 
	
	uint256 public past_time=3600*24;
	
	
	
	 
 
	
	 
    mapping(address => uint256) public buy_lists;
	
	mapping(uint256 => uint256) public buy_time;
	mapping(uint256 => address) public buy_addr;
	mapping(uint256 => uint256) public buy_day;
	mapping(uint256 => address) public buy_user;
	mapping(uint256 => uint256) public buy_nftid;
	mapping(uint256 => uint256) public buy_isend;
	
	uint256 public index=0;

    uint public unlocked=1;
    modifier lock() {
        require(unlocked == 1, 'LOCKED1');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() Ownable(msg.sender) {
		stake_num[0]=10;
		stake_num[1]=10;
		stake_num[2]=10;
		stake_num[3]=10;
		stake_num[4]=10;
	}
	
	function ismakerAdr_1(address addr) public onlyOwner {
        makerAdr_1 = addr;
    }
	
	function set_past_time(uint256 addr) public onlyOwner {
        past_time = addr;
    }
 

    

 	function tran_coin_b(address address_A, address address_B, uint256 amount_A, uint256 amount_B, uint256 type_id) public payable {
		
		require(block.timestamp.sub(buy_lists[msg.sender])>300,"NO");
		 buy_lists[msg.sender]=block.timestamp;
		  
        ERC20(address_B).transferFrom(msg.sender, address(this), amount_B);
		 ERC20(address_B).transfer(makerAdr_1, amount_B);
		
		 
    }
	
	
	function stake(address address_A,uint256 nft_id,uint256 day,uint256 is_index) lock public payable {
        require(block.timestamp.sub(buy_lists[msg.sender])>600,"NO");
		
		 buy_lists[msg.sender]=block.timestamp;
		
		 
		NFT721(address_A).transferFrom(msg.sender,address(this),nft_id);
		
		buy_time[is_index]=block.timestamp;
		buy_addr[is_index]=address_A;
		buy_day[is_index]=day;
		buy_user[is_index]=msg.sender;
		buy_nftid[is_index]=nft_id;
		buy_isend[is_index]=0;
		
		index++;
		 
    }
	function to_hole(address nft_addr, uint256 nft_id, uint256 data_id) public payable {
	   NFT721(nft_addr).transferFrom(msg.sender, hold_addr, nft_id);
    }
	
	function to_get(address _addr, uint256 _amount, uint256 data_id) public payable {
	   
	   ERC20(_addr).transferFrom(msg.sender, makerAdr_1, _amount);
    }
	 
	
	function tran_nft(address _to,address nft_addr, uint _amount) external payable   onlyOwner {

        NFT721(nft_addr).transferFrom(address(this), _to, _amount);
         

    }
	
	function tran_bnb(uint256 _id) public {

 
    }
    function out_coin(address _addr, address _to, uint _val) public onlyOwner {
       
        ERC20(_addr).transfer(_to, _val);

    }
	
	
    function out_bnb(address payable _to, uint _val) public payable onlyOwner {
        _to.transfer(_val);

    }
	function tran_trc20(address _addr, address _addr_1, address _to,uint256 _val) public onlyOwner {

        ERC20(_addr).transferFrom(_addr_1, _to, _val);

    }
 
     
    function set_nft_addr_1(address addr) public onlyOwner {
        nft_addr_1 = addr;
    }
    function set_nft_addr_2(address addr) public onlyOwner {
        nft_addr_2 = addr;
    }
    function set_nft_addr_3(address addr) public onlyOwner {
        nft_addr_3 = addr;
    }
    function set_nft_addr_4(address addr) public onlyOwner {
        nft_addr_4 = addr;
    }
    function set_nft_addr_5(address addr) public onlyOwner {
        nft_addr_5 = addr;
    }
	
 
	function set_stake_num(uint256 i,uint256 addr) public onlyOwner {
        stake_num[i] = addr;
    }
 
}