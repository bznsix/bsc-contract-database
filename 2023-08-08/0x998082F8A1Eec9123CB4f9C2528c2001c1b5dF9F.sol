/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

// SPDX-License-Identifier: MIT License
pragma solidity 0.8.9;

interface IERC20 {    
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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
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
    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract Testyield is Context, Ownable {
    using SafeMath for uint256;
	using SafeERC20 for IERC20;

    IERC20 public USD;
    address public paymentTokenAddress;

    event _Deposit(address indexed addr, uint256 amount, uint40 tm);
    event _Payout(address indexed addr, uint256 amount);
    event _Refund(address indexed addr, uint256 amount);
		
    address payable public creator;
    address payable public dev;   
   
    uint8 public isDepoPaused = 0;
    uint8 public isPayoutPaused = 0;
	
    uint8 public isScheduled = 1;
    uint256 private constant DAY = 24 hours;
    uint256 public numDays = 7;    
    uint256 public numDays2 = 0;    
    
    uint256 public creatorFee = 30; //3%   
    uint256 public devFee = 20; //2%
    uint256 public refundFee = 50; //5%
    uint16 constant FEE_DIVIDER = 1000; 
    uint16 constant PERCENT_DIVIDER = 100;
    uint16[1] private ref_bonuses = [0]; // No referral
  
    uint256 public invested;
    uint256 public withdrawn;
    uint256 public refunds;
    uint256 public ref_bonus;
    uint256 public trading;
    uint256 public inject;
        
    struct Tarif {
        uint256 life_days;
        uint256 percent;
    }

    struct Depo {
        uint256 tarif;
        uint256 amount;
        uint40 time;
    }

     struct Downline {
        uint8 level;    
        address invite;
    }

	struct Player {
        address upline;
        uint256 dividends;
                
        uint256 total_invested;
        uint256 total_withdrawn;
	    uint256 total_refunded;
         uint256 total_ref_bonus;
        
        uint40 lastWithdrawn;
        uint40 lastDeposit;
        
        Depo[] deposits;
        Downline[] downlines1;
        uint256[1] structure; 
     }

    mapping(address => Player) public players;
    mapping(address => uint8) public banned;
    mapping(address => uint8) public pausedInvest;
    mapping(address => uint8) public pausedClaim;    
    
    mapping(uint256 => Tarif) public tarifs;
       
    uint public nextMemberNo;
    uint public nextPausedWallet;
    uint public nextBannedWallet;

    constructor() {         
	    dev = payable(0x823Ff39DD0B3255598872d138F1f7e45771d1202);		
	    creator = payable(msg.sender);		
        
        tarifs[0] = Tarif(36135, 72270);
        
        paymentTokenAddress = 0x55d398326f99059fF775485246999027B3197955; //USDT
		USD = IERC20(paymentTokenAddress);       
    }   
	
    
    function Invest(uint256 amount) external {
        require(isDepoPaused <= 0, 'Deposit Transaction is Paused!');
		require(pausedInvest[msg.sender] == 0, "Wallet is paused for Investing");

        require(amount >= 1 ether, "Minimum Deposit is 100 USDC!");
    
        USD.safeTransferFrom(msg.sender, address(this), amount);

        if(players[msg.sender].total_invested <= 0) {
            nextMemberNo++;    
        }

        Player storage player = players[msg.sender];

        player.deposits.push(Depo({
            tarif: 0,
            amount: amount,
            time: uint40(block.timestamp)
        }));  
        player.lastDeposit = uint40(block.timestamp);

        emit _Deposit(msg.sender, amount, uint40(block.timestamp));
		
		uint256 teamFee = SafeMath.div(SafeMath.mul(amount, devFee), FEE_DIVIDER);
        USD.safeTransfer(dev, teamFee);
        
		 
        player.total_invested += amount;
        
        invested += amount;
        withdrawn += teamFee;
    }
     

    function Claim() external {     
		require(isPayoutPaused <= 0, 'Payout Transaction is Paused!');
        require(banned[msg.sender] == 0,'Banned Wallet!');
        
        require(pausedClaim[msg.sender] == 0, "Wallet is paused for claiming!");

        Player storage player = players[msg.sender];

        if(isScheduled >= 1) {
            require (block.timestamp >= (player.lastWithdrawn + (DAY * numDays)), "Not due yet for next payout!");
        }     

        getPayout(msg.sender);

        require(player.dividends >= 0 ether, "Minimum payout is 50 USDC.");

        uint256 amount =  player.dividends;
        player.dividends = 0;
        
        player.total_withdrawn += amount;
        
		USD.safeTransfer(msg.sender, amount);
		emit _Payout(msg.sender, amount);
		
		uint256 teamFee = SafeMath.div(SafeMath.mul(amount, creatorFee), FEE_DIVIDER);
        USD.safeTransfer(creator, teamFee);
        
		withdrawn += amount + teamFee;    
    }
	

    function exit() external {     
	    require(banned[msg.sender] == 0, "Already Refunded and Wallet is Banned!");

        Player storage player = players[msg.sender];    
		
        require (block.timestamp >= (player.lastDeposit + (DAY * numDays2)), "Not eligible for refund yet!");
        
		uint256 refund = player.total_invested;
		player.total_refunded += refund;
		withdrawn += refund;
		refunds += refund;
	    nextBannedWallet++;
        
		uint256 fee = SafeMath.div(SafeMath.mul(refund, refundFee), FEE_DIVIDER);
        if(refund - fee > 0){
			refund = refund - fee;
		}
		USD.safeTransfer(msg.sender, refund);
		emit _Refund(msg.sender, refund);
		banned[msg.sender] = 1;
    }

    function computePayout(address _addr) view external returns(uint256 value) {
        if(banned[_addr] == 1){ return 0; }
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Depo storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.lastWithdrawn > dep.time ? player.lastWithdrawn : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

            if(from < to) {
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }
        return value;
    }

 
    function getPayout(address _addr) private {
        uint256 payout = this.computePayout(_addr);

        if(payout > 0) {            
            players[_addr].lastWithdrawn = uint40(block.timestamp);
            players[_addr].dividends += payout;
        }
    }      

    function setUpline(address _addr, address _upline) private {
        if(players[_addr].upline == address(0) && _addr != owner()) {     
            
            if(players[_upline].total_invested <= 0) {
                _upline = owner();
            }
            
            players[_addr].upline = _upline;
            players[_upline].structure[0]++;

            Player storage up = players[_upline];
            up.downlines1.push(Downline({
                level: 1,
                invite: _addr
            }));  
        }
    }   
    
        
    function commissionPayouts(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        if(up == address(0)) return;
		{
			uint256 bonus = _amount * ref_bonuses[0] / PERCENT_DIVIDER;
		    
			USD.safeTransfer(up, bonus);
			
			players[up].total_ref_bonus += bonus;
			players[up].total_withdrawn += bonus;

			ref_bonus += bonus;
			withdrawn += bonus;
		}    
    }

		function Trading(uint256 amount) public onlyOwner returns (bool success) {
	    USD.safeTransfer(msg.sender, amount);
		withdrawn += amount;
        trading += amount;
        return true;
    }
	    
    function Injected(uint256 amount) external {
        require(amount >= 1 ether, "Minimum is 100 USDC!");
        USD.safeTransferFrom(msg.sender, address(this), amount);
        inject += amount;
    }


    function nextWithdraw(address _addr) view external returns(uint40 next_sked) {
        if(banned[_addr] == 1) { return 0; }
        Player storage player = players[_addr];
        if(player.deposits.length > 0)
        {
          return uint40(player.lastWithdrawn + (DAY * numDays));
        }
        return 0;
    }
	
    function getContractBalance() public view returns (uint256) {
        return IERC20(paymentTokenAddress).balanceOf(address(this));
    }

    function PauseInvest(address wallet) public onlyOwner returns (bool success) {
        pausedInvest[wallet] = 1;
        nextPausedWallet++;
        return true;
    }
	
	function unpausInvest(address wallet) public onlyOwner returns (bool success) {
        pausedInvest[wallet] = 0;
        if(nextPausedWallet > 0){ nextPausedWallet--; }
        return true;
    }	
    
    function pauseClaim(address wallet) public onlyOwner returns (bool success) {
        pausedClaim[wallet] = 1;
        nextPausedWallet++;
        return true;
    }
	
	function unpauseClaim(address wallet) public onlyOwner returns (bool success) {
        pausedClaim[wallet] = 0;
        if(nextPausedWallet > 0){ nextPausedWallet--; }
        return true;
    }	

	function setPercentage(uint256 total_perc) public onlyOwner returns (bool success) {
	    tarifs[0] = Tarif(36135, total_perc);
        return true;
    }
    
   
    function setCreatorFee(uint256 newfee) public onlyOwner returns (bool success) {
	    creatorFee = newfee;
        return true;
    }
	
	function setRefundFee(uint256 newfee) public onlyOwner returns (bool success) {
		refundFee = newfee;
        return true;
    }
   

	function setDepoPause(uint8 newval) public onlyOwner returns (bool success) {
        isDepoPaused = newval;
        return true;
    }   
	
	function setPayoutPause(uint8 newval) public onlyOwner returns (bool success) {
        isPayoutPaused = newval;
        return true;
    }   
   
    function setcreator(address payable newval) public onlyOwner returns (bool success) {
        creator = newval;
        return true;
    }    
	  
   
    function setScheduled(uint8 newval) public onlyOwner returns (bool success) {
        isScheduled = newval;
        return true;
    }   
   
    function setDays(uint newval) public onlyOwner returns (bool success) {    
        numDays = newval;
        return true;
    }    
    
    function setDays2(uint newval) public onlyOwner returns (bool success) {    
        numDays2 = newval;
        return true;
    }    

    function unban(address wallet) public onlyOwner returns (bool success) {
        banned[wallet] = 0;
        if(nextBannedWallet > 0){ nextBannedWallet--; }
        return true;
    }	

		
    function userInfo(address _addr) view external returns(uint256 for_withdraw, 
                                                            uint256 numDeposits,
                                                            uint256 downlines1,
                                                            uint256[1] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.computePayout(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends,
            player.deposits.length,
            player.downlines1.length,
             structure
        );
    } 
    function memberDownline(address _addr, uint8 level, uint256 index) view external returns(address downline)
    {
        Player storage player = players[_addr];
        Downline storage dl = player.downlines1[0];
        if(level==1){
            dl  = player.downlines1[index];
        }
        return(dl.invite);
    }

    function memberDeposit(address _addr, uint256 index) view external returns(uint40 time, uint256 amount, uint256 lifedays, uint256 percent)
    {
        Player storage player = players[_addr];
        Depo storage dep = player.deposits[index];
        Tarif storage tarif = tarifs[dep.tarif];
        return(dep.time, dep.amount, tarif.life_days, tarif.percent);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

}


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

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