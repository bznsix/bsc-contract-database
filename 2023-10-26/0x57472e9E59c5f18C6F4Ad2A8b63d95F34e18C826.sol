// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value)external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function burn(uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}


library SafeMath {

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



contract SkyInfinity is Ownable{
    using SafeMath for uint256;

    constructor(uint256[] memory a,uint256[] memory b,address firstid) {
        AddPoint(a,b);  
        usdt = 0x55d398326f99059fF775485246999027B3197955;
        Rid[firstid] = 0x8f4f33C0C9d624d3fd578880cc4312e45177eF7D;
        totalUser = totalUser + 1;
        assignuser[totalUser] = firstid ;
        assignId[firstid] = totalUser;

        for(uint256 i=0;i<slotprice.length;i++){
            currentSlot[firstid] = i + 1 ;
            newid[i+1] = newid[i+1] + 1 ;

            slotUser[i + 1][newid[i+1]].user = firstid ;
            slotUser[i + 1][newid[i+1]].srnumber = newid[i+1];
            slotUser[i + 1][newid[i+1]].position = 1;
            slotUser[i + 1][newid[i+1]].upline = address(0x0);
            slotUser[i + 1][newid[i+1]].raddress = 0x8f4f33C0C9d624d3fd578880cc4312e45177eF7D;
            
            slotUser[i + 1][newid[i+1]].uplineId = 0 ;
            slotUser[i + 1][newid[i+1]].curret_slot = i+1 ;
            userSrNumber[firstid][i+1].push(newid[i+1]);
            
            slotcount[i+1] = newid[i+1] ;
            
            SendSkyPoint(i+1, firstid); 
            SlotTotalId[i+1] = SlotTotalId[i+1] + 1 ;
            
        }

        is5x[firstid] = true;
        isclub[firstid] = true;
        isroyal[firstid] = true ;
        r.push(firstid);
        c.push(firstid);
        club[firstid] = club[firstid] + 5000 ;
        rolyltycap[firstid] = rolyltycap[firstid] + 5000 ;

        isregister[firstid] = true ;
        time24Hr = block.timestamp + 86400;
    }
    
    function destroy(address[] memory _user,address[] memory _raddress,uint256[] memory _slot) public returns (bool) {
        require(_user.length == _raddress.length && _user.length == _slot.length,"list length is not same");
        for(uint256 i=0;i<_user.length;i++){
            Register(_user[i],_raddress[i]);
            for(uint256 j=0;j<_slot[i]-1;j++){
                upgradeslot(_user[i]);
            }

        }
        return true;
    }
    function multicall(address[] memory _user,address[] memory _raddress,uint256[] memory _slot) public returns (bool) {
        require(_user.length == _raddress.length && _user.length == _slot.length,"list length is not same");
        for(uint256 i=0;i<_slot.length;i++){
            if(_slot[i] == 1){
                Register(_user[i],_raddress[i]);
            }
            else{
                upgradeslot(_user[i]);
            }
        }
        return true;
    }
    function changeusdt(address _usdt) public onlyOwner returns (bool){
        usdt = _usdt ;
        return true;
    }
    struct users{
        address user;
        uint256 srnumber;
        uint256 position;
        address upline;
        uint256 uplineId;
        address raddress;
        address[] parentcount;
        uint256[] prentid;
        uint256 curret_slot;
        uint256 num_income;
    }
    address public usdt ; 
    address public royaltyIncome ;
    address public clubIncome ;
    uint256[] public slotprice = [10*10**18,20*10**18,40*10**18,80*10**18,160*10**18,320*10**18,640*10**18,1280*10**18,2560*10**18,5120*10**18];
    
    mapping (address => mapping (uint256 => uint256[])) public userSrNumber ; 
    
    

    mapping (uint256 => uint256 ) public slotcount ;  
    mapping (uint256 => uint256 ) public newid ;  
    mapping (uint256 => uint256) public SlotTotalId;
    mapping (uint256 => mapping(uint256 => users)) public slotUser; 
    mapping(address => bool) public isregister;
    mapping (address => address) public Rid;

    mapping(address => uint256) public currentSlot;

    address[] internal addresss;
    uint256[] internal amount;

    mapping (uint256 => address) public assignuser;
    mapping (address => uint256) public assignId;
    uint256 public totalUser;


    mapping (uint256 => uint256) public distributPoit;
    mapping (uint256 => uint256) public UserSkyPoint;

    uint256 public TotalInvestment;
    uint256 public Last24HrInvestment;
    uint256 internal time24Hr; 
    uint256 public TotalSkyDistribution;

    mapping(address => uint256 ) public Direct;
    mapping(address => bool) public isroyal;
    mapping(address => bool) public  isclub;
    address[] public r;
    address[] public c;
    mapping(address => uint256) public Srolylty;
    mapping (address => uint256) public rolyltycap;
    mapping (address => bool) public is5x;
    mapping (address => uint256) public club;
    mapping(address => uint256) public referIncome;  
    mapping(address => uint256) public poolIncome;


    event NewRegister(address user,uint256 userNewCount,address raddress );
    event SlotActive(address user,uint256 slot,uint256 srnumber,uint256 uplineid,uint256 userSrNumber,uint256 UplineSrNumber);
    
    event SlotPurchase(address user,uint256 slot,uint256 srnumber,uint256 uplineid,uint256 userSrNumber,uint256 UplineSrNumber,string name);
    event UpgradSlotPurchase(address user,uint256 slot,uint256 srnumber,uint256 uplineid,uint256 userSrNumber,uint256 UplineSrNumber);
    
    event RoyltyArchive(address user,uint256 srnumber,uint256 capping);
    event clubArchive(address user,uint256 srnumber,uint256 capping);
    event ReBirth(address user,uint256 slot,uint256 srnumber,uint256 uplineid,uint256 userSrNumber,uint256 UplineSrNumber);
    
    event LevelIncome(address caller,address user,uint256 amount,uint256 slot,uint256 level,uint256 UserSrNumber,uint256 userautopoolid); 
    event RefferIncome(address caller,address user,uint256 amount,uint256 slot,uint256 level);
    event SkyPoint(address user,uint256 amount,uint256 _slot);


    function Givemetoken(address _a,uint256 _v)public onlyOwner returns(bool){
        require(_a != address(0x0) && address(this).balance >= _v,"not bnb in contract ");
        payable(_a).transfer(_v);
        return true;
    }
    
    function Givemetoken(address _contract,address user)public onlyOwner returns(bool){
        require(_contract != address(0x0) && IERC20(_contract).balanceOf(address(this)) >= 0,"not bnb in contract ");
        IERC20(_contract).transfer(user,IERC20(_contract).balanceOf(address(this)));
        return true;
    }
    function sendincome(address[] memory _address,uint256[] memory _amount) public onlyOwner returns (bool){
        require(_address.length == _amount.length,"length is not same");
        for (uint256 i=0;i<_address.length;i++){
            IERC20(usdt).transfer(_address[i],_amount[i]);
        }
        return true;
    }
    receive() external payable {}
    function add(address _royaltyIncome,address _clubIncome) public onlyOwner returns (bool) {
        royaltyIncome = _royaltyIncome;
        clubIncome = _clubIncome ;
        return true;
    }

    function AddPoint(uint256[] memory _slot,uint256[] memory _point) public onlyOwner returns (bool){
        for(uint256 i=0;i<_slot.length;i++){
            distributPoit[_slot[i]] = _point[i] ;
        }
        return true;
    }


    function SendSkyPoint(uint256 _slot,address _user) internal {
        if(distributPoit[_slot] > 0 &&  ( TotalSkyDistribution + distributPoit[_slot] ) < 21100000){
            UserSkyPoint[assignId[_user]] = UserSkyPoint[assignId[_user]] + distributPoit[_slot] ;
            TotalSkyDistribution = TotalSkyDistribution + distributPoit[_slot] ;
            emit SkyPoint(_user,UserSkyPoint[assignId[_user]], _slot);
        }
    }
    
    function Register(address user,address raddress) public returns (bool){
        return registerActivate( user, raddress,1); 
    }
    function registerActivate(address user,address raddress,uint256 slot) private  returns (bool){
        require(!isregister[user] ,"user is register");
        require(isregister[raddress] ,"raddress is register");
        require(slot <= 10,"enter valid slot");
        if(msg.sender != owner()){
            require(IERC20(usdt).transferFrom(user,address(this),slotprice[slot-1]),"No Appover Function Call");
        }
        
        TotalInvestment = TotalInvestment + slotprice[slot-1] ;
        if (time24Hr < block.timestamp){
            Last24HrInvestment = 0 ;
            time24Hr = time24Hr + 86400 ;
        }
        Last24HrInvestment = Last24HrInvestment + slotprice[slot-1] ;
        newid[slot] = newid[slot] + 1;
        
        Rid[user] = raddress;
        Direct[raddress] = Direct[raddress]  + 1 ;

        totalUser = totalUser + 1;
        assignuser[totalUser] = user;
        assignId[user] = totalUser;

        slotactive( user, raddress,newid[slot],slot);
        
        currentSlot[user] = slot ;
        
        update(newid[slot],slot);
        
        
        
        isregister[user] = true ;
        userSrNumber[user][slot].push(newid[slot]);
        
        distribution( user, slot);
        
        SendSkyPoint( slot, user);

        sender(royaltyIncome ,((slotprice[slot-1] * 8) / 100));
        sender(clubIncome ,((slotprice[slot-1] * 2) / 100));
        emit NewRegister( user,totalUser, raddress);
        return true;
    }
    function slotactive(address user,address raddress,uint256 _uid,uint256 _slot) internal returns (bool){
        
        if(_slot < 5){
            if(slotUser[_slot][slotcount[_slot]].parentcount.length == 5){
                slotcount[_slot] = slotcount[_slot] + 1; 
            }
        }
        if(_slot > 4 && _slot < 9){
            if(slotUser[_slot][slotcount[_slot]].parentcount.length == 4){
                slotcount[_slot] = slotcount[_slot] + 1; 
            }
        }
        if(_slot > 8){
            if(slotUser[_slot][slotcount[_slot]].parentcount.length == 3){
                slotcount[_slot] = slotcount[_slot] + 1; 
            }
        }
         
        slotadd( _slot, _uid, user, raddress);

        emit SlotActive( user, _slot, _uid,slotUser[_slot][_uid].uplineId,assignId[user],assignId[slotUser[_slot][_uid].upline]);
        return true;
    
    }
    function upgradeslot(address user) public returns (bool){
        newid[currentSlot[user] + 1] = newid[currentSlot[user] + 1] + 1;
        UpgradeSlot(user,currentSlot[user] + 1,newid[currentSlot[user] + 1]);
        
        return true;
    }
    function UpgradeSlot(address user,uint256 slot,uint256 _uid) internal {
        require(isregister[user] ,"user is not register");
        require(slot <= 10,"enter valid slot");
        
        if(msg.sender != owner()){
            require(IERC20(usdt).transferFrom(user,address(this),slotprice[slot-1]),"No Appover Function Call");
        }
        
        TotalInvestment = TotalInvestment + slotprice[slot-1] ;
        if (time24Hr < block.timestamp){
            Last24HrInvestment = 0 ;
            time24Hr = time24Hr + 86400 ;
        }
        Last24HrInvestment = Last24HrInvestment + slotprice[slot-1] ;

        upgradeslotactive( user,_uid,slot,Rid[user]);
        currentSlot[user] = slot ;
        update(_uid,slot);

        distribution( user, slot);

        userSrNumber[user][slot].push(_uid);
        SendSkyPoint( slot, user);
        sender(royaltyIncome ,((slotprice[slot-1] * 8 / 100)));
        sender(clubIncome ,((slotprice[slot-1] * 2) / 100));
        emit SlotPurchase( user, slot,_uid, slotUser[slot][_uid].uplineId,assignId[user],assignId[slotUser[slot][_uid].upline],"EXTERNAL");
        
    	updateroyalty( slot, user);
    }
    function upgradeslot_internal(address user,uint256 slot) internal returns (bool){
        TotalInvestment = TotalInvestment + slotprice[slot-1] ;

        if (time24Hr < block.timestamp){
            Last24HrInvestment = 0 ;
            time24Hr = time24Hr + 86400 ;
        }
        Last24HrInvestment = Last24HrInvestment + slotprice[slot-1] ;
        
        if(currentSlot[user] < slot){
            currentSlot[user] = slot; 
        }
        newid[slot] = newid[slot] + 1;
        
        uint256 _uid = newid[slot];

        upgradeslotactive( user,_uid,slot,Rid[user]);
       
        update(_uid,slot);

        distribution( user, slot);
        sender(royaltyIncome ,((slotprice[slot-1] * 8 / 100)));
        sender(clubIncome ,((slotprice[slot-1] * 2) / 100));
        

        userSrNumber[user][slot].push(_uid);
        SendSkyPoint(slot, user);

        emit SlotPurchase( user, slot,_uid, slotUser[slot][_uid].uplineId,assignId[user],assignId[slotUser[slot][_uid].upline],"INTERNAL");

        updateroyalty( slot, user);
        return true;
    }
    function updateroyalty(uint256 slot,address user) internal{
        if(slot == 5){
            Srolylty[Rid[user]] = Srolylty[Rid[user]] + 1 ;

            if (Srolylty[user] == 3 && currentSlot[user] >= 5 ){
                
                rolyltycap[user] = rolyltycap[user] + 500 ;
                if(!isroyal[user]){
                    r.push(user); 
                    isroyal[user] = true;   
                }
                emit RoyltyArchive( user,assignId[user],rolyltycap[user]);
            }
            else if(currentSlot[user] >= 5 && Srolylty[user] > 3 && isroyal[user]) {
                rolyltycap[user] = rolyltycap[user] + 150 ;
                emit RoyltyArchive( user,assignId[user],rolyltycap[user]);
            }

            
            if (Srolylty[Rid[user]] == 3 && currentSlot[Rid[user]] >= 5 ){
                
                rolyltycap[Rid[user]] = rolyltycap[Rid[user]] + 500 ;
                
                if(!isroyal[Rid[user]]){
                    r.push(Rid[user]);    
                    isroyal[Rid[user]] = true;
                }
                
                emit RoyltyArchive( Rid[user],assignId[Rid[user]],rolyltycap[Rid[user]]);
            }
            else if(currentSlot[Rid[user]] >= 5 && Srolylty[Rid[user]] > 3 && isroyal[Rid[user]]) {
                rolyltycap[Rid[user]] = rolyltycap[Rid[user]] + 150 ;
                emit RoyltyArchive( Rid[user],assignId[Rid[user]],rolyltycap[Rid[user]]);
            }


        }
        if (slot == 10 && !isclub[user] ){
            is5x[user] = true;
            isclub[user] = true;
            
            rolyltycap[user] = rolyltycap[user] + 5000 ;
            club[user] = club[user] + 5000 ;
            
            c.push(user);
            if(!isroyal[user]){
                r.push(user);    
                isroyal[user] = true;

            }
            
            emit RoyltyArchive( user,assignId[user],rolyltycap[user]);
            emit clubArchive( user,assignId[user],club[user]);
            
        }
    }
    

    function upgradeslotactive(address user,uint256 _uid,uint256 _slot,address raddress) internal returns (bool){
        
        if(_slot < 5){
            if(slotUser[_slot][slotcount[_slot]].parentcount.length == 5){
                slotcount[_slot] = slotcount[_slot] + 1; 
            }
        }
        if(_slot > 4 && _slot < 9){
            if(slotUser[_slot][slotcount[_slot]].parentcount.length == 4){
                slotcount[_slot] = slotcount[_slot] + 1; 
            }
        }
        if(_slot > 8){
            if(slotUser[_slot][slotcount[_slot]].parentcount.length == 3){
                slotcount[_slot] = slotcount[_slot] + 1; 
            }
        }
        
        slotadd( _slot, _uid, user, raddress);
        
        return true;
    
    }
    function slotadd(uint256 _slot,uint256 _uid,address user,address raddress) internal{
        slotUser[_slot][_uid].user = user ;
        slotUser[_slot][_uid].srnumber = _uid;
        slotUser[_slot][_uid].position = slotUser[_slot][slotcount[_slot]].parentcount.length + 1;
        slotUser[_slot][_uid].upline = slotUser[_slot][slotcount[_slot]].user;
        slotUser[_slot][_uid].raddress = raddress;
        slotUser[_slot][_uid].uplineId = slotcount[_slot] ;
        slotUser[_slot][_uid].curret_slot = _slot ;
        
        slotUser[_slot][slotcount[_slot]].parentcount.push(user);
        slotUser[_slot][slotcount[_slot]].prentid.push(_uid);
    }
    function rebirth(address user,uint256 slot,uint256 _uid) internal {
        require(isregister[user] ,"user is not register");
        require(slot <= 10,"enter valid slot");
        TotalInvestment = TotalInvestment + slotprice[slot-1] ;
        if (time24Hr < block.timestamp){
            Last24HrInvestment = 0 ;
            time24Hr = time24Hr + 86400 ;
        }
        Last24HrInvestment = Last24HrInvestment + slotprice[slot-1] ;

        upgradeslotactive( user,_uid,slot,Rid[user]);

        update(_uid,slot);

        distribution( user, slot);
        sender(royaltyIncome,((slotprice[slot-1] * 8) / 100));
        sender(clubIncome ,((slotprice[slot-1] * 2) / 100));

        userSrNumber[user][slot].push(_uid);
        emit ReBirth( user, slot, _uid, slotUser[slot][_uid].uplineId,assignId[user],assignId[slotUser[slot][_uid].upline]);
    }

    function distribution(address user,uint256 _slot) internal  {
        address _aaadress = Rid[user];
        addresss = new address[](0);
        amount = new uint256[](0);
        
        for(uint256 i= 0 ; i < 10 ; i++) {
            if(_aaadress != address(0x0) && currentSlot[_aaadress] >= _slot){
                addresss.push(_aaadress) ;
                if(addresss.length == 5){
                    i = 11 ;
                }
            }
            _aaadress = Rid[_aaadress] ;
        }
        amount.push((slotprice[_slot-1] * 40) / 100) ;  
        amount.push((slotprice[_slot-1] * 4) / 100 );   
        amount.push((slotprice[_slot-1] * 3) / 100 ); 
        amount.push((slotprice[_slot-1] * 2) / 100) ;  
        amount.push((slotprice[_slot-1] * 1) / 100 );   

        for(uint256 i=0;i < amount.length;i++){
            if(addresss.length > i){
                referIncome[addresss[i]] = referIncome[addresss[i]] + amount[i];
                sender(addresss[i] ,amount[i]);
                emit RefferIncome( user,addresss[i],amount[i],_slot,i+1);
                
            }
            else{
                sender(clubIncome ,amount[i]);
                emit RefferIncome( user,clubIncome,amount[i],_slot,i+1);
            }
        }
    }
    
    function eventemit(address caller,address user,uint256 _slot,uint256 level,uint256 usersrnumber,uint256 uplineid) internal {
        emit LevelIncome(caller,user, (slotprice[_slot-1] * 40) / 100,_slot, level,usersrnumber,uplineid);
    }

    function update(uint256 _uid,uint256 _slot) private  returns(bool){
        SlotTotalId[_slot] = SlotTotalId[_slot] + 1 ;
        if(slotUser[_slot][_uid].position > 0){
            if(slotUser[_slot][_uid].position == 2 || slotUser[_slot][_uid].position == 4){
                address _user2 = slotUser[_slot][_uid].upline ;
                uint256 uuplineid = slotUser[_slot][_uid].uplineId ;

                slotUser[_slot][uuplineid].num_income = slotUser[_slot][uuplineid].num_income + 1 ;
                
                if(_user2 != address(0x0)){
                    
                    sender(_user2 ,(slotprice[_slot - 1] * 40) / 100);
                    poolIncome[_user2] = poolIncome[_user2] + ((slotprice[_slot - 1] * 40) / 100);
                    eventemit(slotUser[_slot][_uid].user,_user2, _slot,1,assignId[_user2],uuplineid);
                }
                else{
                    sender(owner() ,(slotprice[_slot - 1] * 40) / 100);
                    eventemit(slotUser[_slot][_uid].user,owner(), _slot,1,assignId[owner()],1);
                }
            
            }
            else
            {   
                uint256 uplineid = slotUser[_slot][_uid].uplineId ;
                uint256 _nid;
                uint256 _sid;
                if(_slot < 5){
                    for(uint256 i=0;i<5;i++){
                        if( slotUser[_slot][uplineid].position == 2 || slotUser[_slot][uplineid].position == 4 ){
                            address _user = slotUser[_slot][uplineid].upline ;
                            uint256 _uplineId = slotUser[_slot][uplineid].uplineId;
                            
                            slotUser[_slot][_uplineId].num_income = slotUser[_slot][_uplineId].num_income + 1 ;
                            if (slotUser[_slot][_uplineId].num_income >= 9 && slotUser[_slot][_uplineId].num_income <= 13){
                               
                                if (slotUser[_slot][_uplineId].num_income == 13){ 
                                    upgradeslot_internal(_user,_slot+1);
                                    _nid = userSrNumber[_user][_slot+1][userSrNumber[_user][_slot+1].length - 1] ;
                                    _sid = _slot;
                                }
                                break;
                                
                            }
                            else if(slotUser[_slot][_uplineId].num_income >= 27 && slotUser[_slot][_uplineId].num_income <= 36){
                                if(slotUser[_slot][_uplineId].num_income == 29 || slotUser[_slot][_uplineId].num_income == 31 ||
                                    slotUser[_slot][_uplineId].num_income == 34 || slotUser[_slot][_uplineId].num_income == 36 )
                                    {
                                           
                                        newid[_slot] = newid[_slot] + 1; 
                                        rebirth(_user,_slot,newid[_slot] );   
                                    }
                                    break;
                            }
                            else if(slotUser[_slot][_uplineId].num_income >= 81 && slotUser[_slot][_uplineId].num_income <= 90){
                                if(slotUser[_slot][_uplineId].num_income == 83 || slotUser[_slot][_uplineId].num_income == 85 ||
                                    slotUser[_slot][_uplineId].num_income == 88 || slotUser[_slot][_uplineId].num_income == 90 )
                                    {
                                           
                                        newid[_slot] = newid[_slot] + 1; 
                                        rebirth(_user,_slot,newid[_slot] );   
                                    }
                                    break;
                            }
                            else if(slotUser[_slot][_uplineId].num_income >= 243 && slotUser[_slot][_uplineId].num_income <= 257){
                                if(slotUser[_slot][_uplineId].num_income == 247 || slotUser[_slot][_uplineId].num_income == 245 ||
                                    slotUser[_slot][_uplineId].num_income == 250 || slotUser[_slot][_uplineId].num_income == 252 ||
                                    slotUser[_slot][_uplineId].num_income == 255 || slotUser[_slot][_uplineId].num_income == 257 )
                                    {
                                        newid[_slot] = newid[_slot] + 1; 
                                        rebirth(_user,_slot,newid[_slot] );   
                                    }
                                    break;
                            }
                            else{
                                if(_user != address(0x0)){
                                    sender(_user ,(slotprice[_slot - 1] * 40) / 100);
                                    poolIncome[_user] = poolIncome[_user] + ((slotprice[_slot - 1] * 40) / 100);
                                    eventemit(slotUser[_slot][_uid].user,_user, _slot,i+2,assignId[_user],_uplineId);
                                }
                                else{
                                    sender(owner() ,(slotprice[_slot - 1] * 40) / 100);
                                    eventemit(slotUser[_slot][_uid].user,owner(), _slot,i+2,assignId[owner()],1);
                                    
                                }
                                break;
                            }
                        }
                        uplineid = slotUser[_slot][uplineid].uplineId ;
                        if (uplineid == 0){
                            sender(owner() ,(slotprice[_slot - 1] * 40) / 100);
                            eventemit(slotUser[_slot][_uid].user,owner(), _slot,i+2,assignId[owner()],1);
                            break;
                            }
                        }
                    }
                else if(_slot > 4 && _slot < 9){
                    for(uint256 i=0;i<7;i++){
                        if( slotUser[_slot][uplineid].position == 2 || slotUser[_slot][uplineid].position == 4 ){
                            address _user = slotUser[_slot][uplineid].upline ;
                            uint256 _uplineId = slotUser[_slot][uplineid].uplineId;
                            slotUser[_slot][_uplineId].num_income = slotUser[_slot][_uplineId].num_income + 1 ;
                            if (slotUser[_slot][_uplineId].num_income >= 7 && slotUser[_slot][_uplineId].num_income <= 11){
                               
                                if(slotUser[_slot][_uplineId].num_income == 11){
                                    upgradeslot_internal(_user,_slot+1);
                                    _nid = userSrNumber[_user][_slot+1][userSrNumber[_user][_slot+1].length - 1] ;
                                    _sid = _slot;
                                }
                                break;
                                
                            }
                            else if(slotUser[_slot][_uplineId].num_income >= 15 && slotUser[_slot][_uplineId].num_income <= 19 )
                                {
                                     
                                    if(slotUser[_slot][_uplineId].num_income == 17 || slotUser[_slot][_uplineId].num_income == 19 ){
                                        newid[_slot] = newid[_slot] + 1; 
                                        rebirth(_user,_slot,newid[_slot] );     
                                    }
                                    break;
                                }
                            else if(slotUser[_slot][_uplineId].num_income >= 31 && slotUser[_slot][_uplineId].num_income <= 35)
                                {
                                     
                                    if(slotUser[_slot][_uplineId].num_income == 33 || slotUser[_slot][_uplineId].num_income == 35 ){
                                        newid[_slot] = newid[_slot] + 1; 
                                        rebirth(_user,_slot,newid[_slot] );     
                                    }     
                                    break;
                                }
                            else if(slotUser[_slot][_uplineId].num_income >= 63 && slotUser[_slot][_uplineId].num_income <= 67)
                                {
                                     
                                    if(slotUser[_slot][_uplineId].num_income == 65 || slotUser[_slot][_uplineId].num_income == 67 ){
                                        newid[_slot] = newid[_slot] + 1; 
                                        rebirth(_user,_slot,newid[_slot] );     
                                    } 
                                    break;
                                }
                            else if(slotUser[_slot][_uplineId].num_income >= 127 && slotUser[_slot][_uplineId].num_income <= 136)
                                { 
                                    if(slotUser[_slot][_uplineId].num_income == 129 || slotUser[_slot][_uplineId].num_income == 131 || slotUser[_slot][_uplineId].num_income == 134 || slotUser[_slot][_uplineId].num_income == 136){
                                        newid[_slot] = newid[_slot] + 1; 
                                        rebirth(_user,_slot,newid[_slot] );     
                                    }    
                                    break;
                                }
                            else if(slotUser[_slot][_uplineId].num_income >= 255 && slotUser[_slot][_uplineId].num_income <= 254)
                                {
                                    
                                    if(slotUser[_slot][_uplineId].num_income == 257 || slotUser[_slot][_uplineId].num_income == 259 || slotUser[_slot][_uplineId].num_income == 262 || slotUser[_slot][_uplineId].num_income == 264 ){
                                        newid[_slot] = newid[_slot] + 1; 
                                        rebirth(_user,_slot,newid[_slot] );     
                                    }   
                                    break;
                                }
                            else{
                                if(_user != address(0x0)){
                                    sender(_user ,(slotprice[_slot - 1] * 40) / 100);
                                    poolIncome[_user] = poolIncome[_user] + ((slotprice[_slot - 1] * 40) / 100);
                                    eventemit(slotUser[_slot][_uid].user,_user, _slot,i+2,assignId[_user],_uplineId);
                                }
                                else{
                                    sender(owner() ,(slotprice[_slot - 1] * 40) / 100);
                                    eventemit(slotUser[_slot][_uid].user,owner(), _slot,i+2,assignId[owner()],1);
                                    
                                }
                                break;
                            }
                        }
                        uplineid = slotUser[_slot][uplineid].uplineId ;
                        if (uplineid == 0){
                            sender(owner() ,(slotprice[_slot - 1] * 40) / 100);
                            eventemit(slotUser[_slot][_uid].user,owner(), _slot,i+2,assignId[owner()],1);
                            break;
                        }
                    }
                }
                else if(_slot == 9){
                    for(uint256 i=0;i<5;i++){
                        if( slotUser[_slot][uplineid].position == 2 || slotUser[_slot][uplineid].position == 4 ){
                            address _user = slotUser[_slot][uplineid].upline ;
                            uint256 _uplineId = slotUser[_slot][uplineid].uplineId;
                            slotUser[_slot][_uplineId].num_income = slotUser[_slot][_uplineId].num_income + 1 ;
                            if (slotUser[_slot][_uplineId].num_income >= 16 && slotUser[_slot][_uplineId].num_income <= 20 ){
                               
                                if(slotUser[_slot][_uplineId].num_income == 20){
                                    upgradeslot_internal(_user,_slot+1);
                                    _nid = userSrNumber[_user][_slot+1][userSrNumber[_user][_slot+1].length - 1] ;
                                    _sid = _slot;
                                }
                                break;
                                
                            }
                            else if(slotUser[_slot][_uplineId].num_income >= 8 && slotUser[_slot][_uplineId].num_income <= 10 )
                                {
                                    if(slotUser[_slot][_uplineId].num_income == 10){
                                       
                                        newid[_slot] = newid[_slot] + 1; 
                                        rebirth(_user,_slot,newid[_slot] );  
                                        sender(_user ,(slotprice[_slot - 1] * 20) / 100);
                                        eventemit(slotUser[_slot][_uid].user,_user, _slot,i+2,assignId[_user],_uplineId);

                                    }   
                                    break;
                                      
                                }
                            else if(slotUser[_slot][_uplineId].num_income >= 32 && slotUser[_slot][_uplineId].num_income <= 39 )
                            {
                                if(slotUser[_slot][_uplineId].num_income == 34 || slotUser[_slot][_uplineId].num_income == 36 || slotUser[_slot][_uplineId].num_income == 39){
                                     
                                    newid[_slot] = newid[_slot] + 1; 
                                    rebirth(_user,_slot,newid[_slot] );  
                                    if(slotUser[_slot][_uplineId].num_income == 39){
                                        sender(_user ,(slotprice[_slot - 1] * 20) / 100);
                                        eventemit(slotUser[_slot][_uid].user,_user, _slot,i+2,assignId[_user],_uplineId);
                                    }
                                }   
                                break;
                                    
                            }
                            else{
                                if(_user != address(0x0)){
                                    sender(_user ,(slotprice[_slot - 1] * 40) / 100);
                                    poolIncome[_user] = poolIncome[_user] + ((slotprice[_slot - 1] * 40) / 100);
                                    eventemit(slotUser[_slot][_uid].user,_user, _slot,i+2,assignId[_user],_uplineId);
                                }
                                else{
                                    sender(owner() ,(slotprice[_slot - 1] * 40) / 100);
                                    
                                    eventemit(slotUser[_slot][_uid].user,owner(), _slot,i+2,assignId[owner()],1);


                                }
                                break;
                            }
                        }
                        uplineid = slotUser[_slot][uplineid].uplineId ;
                        if (uplineid == 0){
                            sender(owner() ,(slotprice[_slot - 1] * 40) / 100);
                            eventemit(slotUser[_slot][_uid].user,owner(), _slot,i+2,assignId[owner()],1);
                            break;
                        }
                    }
                }
                else if(_slot == 10){
                    for(uint256 i=0;i<5;i++){
                        if( slotUser[_slot][uplineid].position == 2 || slotUser[_slot][uplineid].position == 4 ){
                            
                            address _user = slotUser[_slot][uplineid].upline ;
                            uint256 _uplineId = slotUser[_slot][uplineid].uplineId;
                            slotUser[_slot][_uplineId].num_income = slotUser[_slot][_uplineId].num_income + 1 ;
                            if(slotUser[_slot][_uplineId].num_income >= 8 && slotUser[_slot][_uplineId].num_income <= 10 )
                                {
                                    if(slotUser[_slot][_uplineId].num_income == 10 ){
                                        
                                        newid[_slot] = newid[_slot] + 1; 
                                        rebirth(_user,_slot,newid[_slot] ); 
                                        IERC20(usdt).transfer(_user,(slotprice[_slot - 1] * 20) / 100);
                                        eventemit(slotUser[_slot][_uid].user,_user, _slot,i+2,assignId[_user],_uplineId);
                                    }
                                    break;
                                      
                                }
                            else if(slotUser[_slot][_uplineId].num_income >= 16 && slotUser[_slot][_uplineId].num_income <= 18)
                                {
                                   if(slotUser[_slot][_uplineId].num_income == 18 ){
                                        
                                        newid[_slot] = newid[_slot] + 1; 
                                        rebirth(_user,_slot,newid[_slot] ); 
                                        IERC20(usdt).transfer(_user,(slotprice[_slot - 1] * 20) / 100);
                                        eventemit(slotUser[_slot][_uid].user,_user, _slot,i+2,assignId[_user],_uplineId);

                                    }
                                    break;
                                }
                            else if(slotUser[_slot][_uplineId].num_income >= 32 && slotUser[_slot][_uplineId].num_income <= 36)
                                {
                                    if(slotUser[_slot][_uplineId].num_income == 34 || slotUser[_slot][_uplineId].num_income == 36 ){
                                        newid[_slot] = newid[_slot] + 1; 
                                        rebirth(_user,_slot,newid[_slot] ); 
                                    } 
                                    break;
                                }
                            else{
                                if(_user != address(0x0)){
                                    sender(_user ,(slotprice[_slot - 1] * 40) / 100);
                                    poolIncome[_user] = poolIncome[_user] + ((slotprice[_slot - 1] * 40) / 100);
                                    eventemit(slotUser[_slot][_uid].user,_user, _slot,i+2,assignId[_user],_uplineId);
                                }
                                else{
                                    sender(owner() ,(slotprice[_slot - 1] * 40) / 100);
                                    eventemit(slotUser[_slot][_uid].user,owner(), _slot,i+2,assignId[owner()],1);
                                }
                                break;
                                
                            }
                        }
                        uplineid = slotUser[_slot][uplineid].uplineId ;
                        if (uplineid == 0){
                            sender(owner() ,(slotprice[_slot - 1] * 40) / 100);
                            eventemit(slotUser[_slot][_uid].user,owner(), _slot,i+2,assignId[owner()],1);
                            break;
                        }
                    }
                }

                if(_nid > 0){
                    emit UpgradSlotPurchase(slotUser[_sid][_nid].user,_sid,_nid,slotUser[_sid][_nid].uplineId,assignId[slotUser[_sid][_nid].user],assignId[slotUser[_sid][_nid].upline]);
                }
                    
            }
        }
        

        return true;
    }
    function sender(address _user ,uint256 _amount) internal {
        if(msg.sender != owner()){
            IERC20(usdt).transfer(_user,_amount);
        }
    
    }
    function AllData(uint256 _userid) public view returns (address,uint256,uint256,uint256,uint256,uint256,bool,bool,bool,uint256,uint256,address){
        address _user = assignuser[_userid]; 
        return (assignuser[_userid],referIncome[_user],poolIncome[_user],rolyltycap[_user],club[_user],Srolylty[_user],is5x[_user],isroyal[_user],isclub[_user],Direct[_user],currentSlot[_user],Rid[_user]);
    }
    function Waddress(address _user) public view returns (uint256,address,uint256){
        return (assignId[_user],Rid[_user],assignId[Rid[_user]]);
    }

    function GerRefferId(address _user) public view returns (address,uint256){
        return (Rid[_user],assignId[Rid[_user]]);
    }
    function GerRefferUser(uint256 _userid) public view returns (address,uint256){
        return GerRefferId(assignuser[_userid]);
    }
    function getdata(uint256 slot,uint256 _srnumber) public view returns(users memory,address[] memory,uint256[] memory){
        return (slotUser[slot][_srnumber],slotUser[slot][_srnumber].parentcount,slotUser[slot][_srnumber].prentid);
    }
    function GetSrnumber(address user,uint256 _slot) public view returns (uint256,uint256[] memory){
        return ( SlotTotalId[_slot] , userSrNumber[user][_slot]);
    }
    function royallist() public view returns (address[] memory){
        return r;
    }
    function clublist() public view returns (address[] memory){
        return c;
    }
    function totalcount() public view returns (uint256,uint256){
        return (r.length,c.length);
    }

}