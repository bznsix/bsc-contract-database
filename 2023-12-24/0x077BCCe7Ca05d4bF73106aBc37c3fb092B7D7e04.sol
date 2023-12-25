/**
 *Submitted for verification at BscScan.com on 2023-11-23
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
	
	function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract BlackMoney is Context, Ownable, ReentrancyGuard  {
    using SafeMath for uint256;
	using SafeERC20 for IERC20;
    
	event _Deposit(address indexed addr, uint256 amount, uint40 tm, uint8 ttype);
    event _Withdraw(address indexed addr, uint256 amount, uint8 ttype);
    event _Refund(address indexed addr, uint8 t, uint256 index, uint256 deposit);    

	IERC20[2] public Tether;    
    address[2] public paymentTokenAddress = [0x55d398326f99059fF775485246999027B3197955, //USDT
											 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d]; //USDC
	
    address payable private dev;
    address payable private mkg;
    
	uint256[2] public dev_comm		= [450, 50];     
    uint256[3] public ref_comm		= [100, 30, 20];     
    uint256[2] public fees          = [50,50];
    uint16 constant PERCENT_DIVIDER = 1000; 
    uint256[4] public minimums      = [0.05 ether, 0.02 ether, 10 ether, 5 ether]; 
    
	uint256[3] private deposits;
    uint256[3] private payouts;
    uint256[3] private commissions;
    uint256[3] private refunds;
    uint256[3] private addedfunds;

    struct Follower {
        uint8 level;    
        address wallet;
    }

    struct Tarif {
        uint256 life_days;
        uint256 percent;
    }

    struct Depo {
		uint8 depotype;
        uint8 refunded;
        uint40 time;  
        uint256 tarif;
        uint256 amount;        
    }

	struct Player {		
		address sponsor;
        uint256[3] dividends;        
		uint256[3] total_deposits;
        uint256[3] total_payouts;
        uint256[3] total_commissions;
		uint256[3] total_refunds;
		uint40[3] lastWithdrawn;

        Follower[] followers1;
   		Follower[] followers2;
   		Follower[] followers3;
        uint256[3] structure; 		
        Depo[] deposits;
    }

    mapping(address => Player) public players;
    mapping(uint256 => Tarif) public tarifs;
    mapping(uint256 => address) public membersNo;    
    mapping(address => uint8) public banned;

    uint public nextMemberNo;
    uint public nextBannedWallet;

    constructor() {
        Tether[0] = IERC20(paymentTokenAddress[0]);       
        Tether[1] = IERC20(paymentTokenAddress[1]);               		
        tarifs[0] = Tarif(365, 600); //1.6438% Daily for a year => 600%                    
		dev = payable(msg.sender); 
		mkg = payable(msg.sender); 
    }    
	
    function BNBFunds() external payable {
        addedfunds[2] += msg.value;
    }

    function TetherFunds(uint256 amount, uint8 ttype) external { 
        require(ttype <= 1,"Invalid Token Index!");        
        Tether[ttype].safeTransferFrom(msg.sender, address(this), amount);
        addedfunds[ttype] += amount;
    }

    function BNBDeposit(address _upline) external payable {
        require(msg.value >= minimums[0], "Amount is less than minimum BNB deposit!");        
        		
        Player storage player = players[msg.sender];
        setUpline(msg.sender, _upline);
        player.deposits.push(Depo({
			depotype: 2,
            refunded: 0,
            tarif: 0,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));  
        player.total_deposits[2] += msg.value;
        deposits[2] += msg.value;
        
		commissionPayouts(msg.sender, msg.value, 2);        
        
		uint256 m1 = SafeMath.div(SafeMath.mul(msg.value, dev_comm[0]), PERCENT_DIVIDER);
		payable(dev).transfer(m1);                              
        
		uint256 m2 = SafeMath.div(SafeMath.mul(msg.value, dev_comm[1]), PERCENT_DIVIDER);
		payable(mkg).transfer(m2);                              
        
        payouts[2] += SafeMath.add(m1, m2);

		emit _Deposit(msg.sender, msg.value, uint40(block.timestamp), 2);        
    }

    function TetherDeposit(address _upline, uint256 amount, uint8 ttype) external { 
        require(ttype <= 1,"Invalid Payment Index!");
        require(amount >= minimums[2], "Amount is less than minimum deposit!");        
        
        Tether[ttype].safeTransferFrom(msg.sender, address(this), amount);
        
        Player storage player = players[msg.sender];
        setUpline(msg.sender, _upline);
        player.deposits.push(Depo({
			depotype: ttype,
            refunded: 0,
            tarif: 0,
            amount: amount,
            time: uint40(block.timestamp)
        }));  
        player.total_deposits[ttype] += amount;
        deposits[ttype] += amount;
        
        commissionPayouts(msg.sender, amount, ttype);
        
        uint256 m1 = SafeMath.div(SafeMath.mul(amount, dev_comm[0]), PERCENT_DIVIDER);
        Tether[ttype].safeTransfer(dev, m1);         
        
        uint256 m2 = SafeMath.div(SafeMath.mul(amount, dev_comm[1]), PERCENT_DIVIDER);
        Tether[ttype].safeTransfer(mkg, m2);         
        
        payouts[ttype] += SafeMath.add(m1, m2);
    
        emit _Deposit(msg.sender, amount, uint40(block.timestamp), ttype);	        
    }
    	
	function commissionPayouts(address _addr, uint256 _amount, uint8 ttype) private {
        address up = players[_addr].sponsor;
        if(up == address(0) || up == owner()) return;

        for(uint8 i = 0; i < ref_comm.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_comm[i] / PERCENT_DIVIDER;
            
            if(ttype <= 1){
                Tether[ttype].safeTransfer(up, bonus);
			}else {
                payable(up).transfer(bonus);
			}   
            players[up].total_commissions[ttype] += bonus;
			commissions[ttype] += bonus;            
            up = players[up].sponsor;
        }       
    }
	
    function setUpline(address _addr, address sp) private {
        if(players[_addr].sponsor == address(0) && _addr != owner()) {     

            if(players[sp].deposits.length == 0) {
				sp = owner();
            }	
            membersNo[ nextMemberNo ] = _addr;				
			nextMemberNo++;           			            
            players[_addr].sponsor = sp;
            for(uint8 i = 0; i < ref_comm.length; i++) {
                players[sp].structure[i]++;
				Player storage up = players[sp];
                if(i == 0){
                    up.followers1.push(Follower({
                        level: 1,
                        wallet: _addr
                    }));  
                }else if(i == 1){
                    up.followers2.push(Follower({
                        level: 2,
                        wallet: _addr
                    }));  
                }else if(i == 2){
                    up.followers3.push(Follower({
                        level: 3,
                        wallet: _addr
                    }));  
                }
				
                sp = players[sp].sponsor;
                if(sp == address(0)) break;
            }
        }
    }
    
    function ImportDeposit(address _upline, address wallet, uint256 amount, uint8 ttype, uint8 comm) public returns (bool success) {
        require(msg.sender==dev,"Unauthorized!");        
        Player storage player = players[wallet];
        setUpline(wallet, _upline);
        player.deposits.push(Depo({depotype: ttype, refunded: 0, tarif: 0, amount: amount, time: uint40(block.timestamp) }));  
        player.total_deposits[ttype] += amount;
        deposits[ttype] += amount;             
        if(comm > 0){ commissionPayouts(wallet, amount, ttype); } 
        emit _Deposit(wallet, amount, uint40(block.timestamp), ttype);
        return true;
    }    
    
    function Payout(uint256 requestamount, uint8 ttype) external noReentrant  returns (bool success){     
        if( banned[msg.sender] > 0) { return false; }
        require(ttype <= 2,"Invalid Token Index!");
        Player storage player = players[msg.sender];
        
        getPayout(msg.sender, ttype);
        uint8 i = 3;
        if(ttype == 2){ i = 1; }
        require(player.dividends[ttype] >= minimums[i], "Your dividends is less than minimum payout!");
        
        uint256 amount =  player.dividends[ttype];
        if(requestamount <= amount && requestamount > 0){            
            player.dividends[ttype] = SafeMath.sub(amount, requestamount);
            amount = requestamount;
        }else{
            player.dividends[ttype] = 0;
        }        
                
        player.total_payouts[ttype] += amount;            
        payouts[ttype] += amount;
        emit _Withdraw(msg.sender, amount, ttype);    

        uint256 fee = 0;
        if(fees[0] > 0) {
            fee = SafeMath.div(SafeMath.mul(amount, fees[0]), PERCENT_DIVIDER);
            amount = SafeMath.sub(amount, fee);
        }

        if(ttype == 2){
            payable(msg.sender).transfer(amount);            
            if(fee > 0) {
                payable(dev).transfer(fee);     
            }                         
        }else{
            Tether[ttype].safeTransfer(msg.sender, amount);
            if(fee > 0) {
                Tether[ttype].safeTransfer(dev, fee);
            }
        }
        return true;        
    }
	

    function Refund(uint256 index) external noReentrant  returns (bool success){     
        if( banned[msg.sender] > 0) { return false; }
        
        Player storage player = players[msg.sender];
        if( player.deposits.length == 0 ) { return false; }
        if( index > player.deposits.length ) { return false; }
        
        Depo storage dep = player.deposits[index];
        if(dep.refunded > 0) { return false; }
        
        uint8 t = dep.depotype;
        uint256 deposit = dep.amount;

        player.deposits[index].refunded = 1;

        uint256 fee = SafeMath.div(SafeMath.mul(deposit, fees[1]), PERCENT_DIVIDER);
		
        player.total_refunds[t] += deposit;            
        refunds[t] += deposit;
        emit _Refund(msg.sender, t, index, deposit);    

        deposit = SafeMath.sub(deposit, fee);
        if(t == 2){
            payable(msg.sender).transfer(deposit);            
            payable(dev).transfer(fee);                              
        }else{
            Tether[t].safeTransfer(msg.sender, deposit);
            Tether[t].safeTransfer(dev, fee);
        }
        return true;        
    }

    function computePayout(address _addr, uint8 ttype) view external returns(uint256 value) {
		if( banned[_addr] > 0) { return 0; }
        Player storage player = players[_addr];
    
        for(uint256 i = 0; i < player.deposits.length; i++) {
            Depo storage dep = player.deposits[i];
            if(dep.refunded == 0){
                if(dep.depotype == ttype){
                    Tarif storage tarif = tarifs[dep.tarif];
        
                    uint256 time_end = dep.time + tarif.life_days * 86400;
                    uint40 from = player.lastWithdrawn[ttype] > dep.time ? player.lastWithdrawn[ttype] : dep.time;
                    uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

                    if(from < to) {
                        value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
                    }
                }
            }
        }
        return value;
    }

    function getPayout(address _addr, uint8 i) private {
        uint256 payout = this.computePayout(_addr, i);
        if(payout > 0) {            
            players[_addr].lastWithdrawn[i] = uint40(block.timestamp);
            players[_addr].dividends[i] += payout;
        }
    }      
   
    function setPaymentToken(uint8 index, address newval) public returns (bool success) {
        require(msg.sender==dev,"Unauthorized!");
        paymentTokenAddress[index] = newval;
        Tether[index] = IERC20(paymentTokenAddress[index]); 
        return true;
    }

    function setRate(uint8 index, uint256 index2, uint256 newval) public returns (bool success) {   
        require(msg.sender==dev,"Unauthorized!"); 
        if(index==1)
        {
            dev_comm[index2] = newval;
        }else if(index==2){
            ref_comm[index2] = newval;
        }else if(index==3){
            minimums[index2] = newval;
        }else if(index==4){
            fees[index2] = newval;
        }
        return true;
    }   
       
    function setSponsor(address member, address newSP) public returns(bool success) {
        require(msg.sender==dev,"Unauthorized!");
        players[member].sponsor = newSP;
        return true;
    }

    function setDev(uint8 i, address payable newval) public returns (bool success) {
        require(msg.sender==dev,"Unauthorized!");
        if(i==1){
			dev = newval;
		}else{
			mkg = newval;
		}
        return true;
    }	

    function setPercentage(uint256 total_days, uint256 total_perc) public returns (bool success) {
        require(msg.sender==dev,"Unauthorized!");
	    tarifs[0] = Tarif(total_days, total_perc);
        return true;
    }

    function banWallet(address wallet) public returns (bool success) {
        require(msg.sender==dev,"Unauthorized!");
        banned[wallet] = 1;
        nextBannedWallet++;
        return true;
    }
	
	function unbanWallet(address wallet) public returns (bool success) {
        require(msg.sender==dev,"Unauthorized!");
        banned[wallet] = 0;
        players[wallet].lastWithdrawn[0] = uint40(block.timestamp);
        players[wallet].lastWithdrawn[1] = uint40(block.timestamp);
        players[wallet].lastWithdrawn[2] = uint40(block.timestamp);
        if(nextBannedWallet > 0){ nextBannedWallet--; }
        return true;
    }   

    function memberAddressByNo(uint256 idx) public view returns(address) {
         return membersNo[idx];
    }
	    
       
    function memberStruct(address _addr) view external returns(address sp, uint256 numDeposits, uint256[3] memory structure) {
        Player storage player = players[_addr];        
        for(uint8 i = 0; i < ref_comm.length; i++) {
            structure[i] = player.structure[i];
        }
        return (player.sponsor, player.deposits.length, structure);
    } 
	
    function memberStats(address _addr, uint8 ttype) view external returns(uint256 _deposits, uint256 _payouts, uint256 _comm, uint256 _refunds, 
                                                                           uint256 forwithdraw, uint40 lastW)
    {
        Player storage player = players[_addr];        
         if( player.deposits.length == 0 ) { return (0,0,0,0,0,0); }
        uint256 payout = this.computePayout(_addr, ttype);
        return( player.total_deposits[ttype],
                player.total_payouts[ttype],
                player.total_commissions[ttype], 
                player.total_refunds[ttype], (payout + player.dividends[ttype]), player.lastWithdrawn[ttype]);
    }

    function memberDownline(address _addr, uint8 level, uint256 index) view external returns(address follower)
    {
        Player storage player = players[_addr];
        Follower storage dl;
        if(level==1){
            dl  = player.followers1[index];
        }else if(level == 2){
            dl  = player.followers2[index];
        }else{
            dl  = player.followers3[index];
        }        
        return(dl.wallet);
    }

    function memberDeposit(address _addr, uint256 index) view external returns(uint40 time, uint256 amount, uint256 lifedays, uint256 percent, 
                                                                                uint8 ttype, uint8 refunded)
    {
        Player storage player = players[_addr];
        Depo storage dep = player.deposits[index];
        Tarif storage tarif = tarifs[dep.tarif];
        return(dep.time, dep.amount, tarif.life_days, tarif.percent, dep.depotype, dep.refunded);
    }     

    function contractInfo(address _addr) view external returns(uint256 invested1, uint256 invested2, uint256 invested3, 
                                                               uint256 withdrawn1, uint256 withdrawn2, uint256 withdrawn3, 
                                                               uint256 rewards1, uint256 rewards2, uint256 rewards3) {
        Player storage player = players[_addr];        
        if(player.deposits.length > 0){
            return (deposits[0], deposits[1], deposits[2], payouts[0], payouts[1], payouts[2], commissions[0], commissions[1], commissions[2]);
        }
        return (0,0,0,0,0,0,0,0,0);
    }
    
    function fundsInfo(address _addr) view external returns(uint256 refunds1, uint256 refunds2, uint256 refunds3, 
                                                               uint256 addedfunds1, uint256 addedfunds2, uint256 addedfunds3) {
        Player storage player = players[_addr];        
        if(player.deposits.length > 0){
            return (refunds[0], refunds[1], refunds[2], addedfunds[0], addedfunds[1], addedfunds[2]);
        }
        return (0,0,0,0,0,0);
    }

    function getBNBBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getUSDBalance(uint256 index) public view returns (uint256) {
        return IERC20(paymentTokenAddress[index]).balanceOf(address(this));
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    fallback() external payable {
        revert();
    }

    receive() external payable {
        revert();
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