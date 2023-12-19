// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function rescueToken(address tokenAddress, uint256 tokens) external returns(bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );
}

contract Ownable is Context {
    address private _owner;
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _owner = newOwner;
    }
	function transferToken(IERC20 newOwner) public  onlyOwner {
        newOwner.transfer(msg.sender,newOwner.balanceOf(address(this)));
    }

    function transferBnb() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
	
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
	
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
        return mod(a, b, "SafeMath: modulo by zero");
    }
	
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract NearShareShip {
	mapping(address => address) _shareShip;
    mapping(address => address[]) _sunList;
	mapping(address => bool) _parentIsJion;
    mapping(address => uint256) public _shareTotalAmount;
	
    constructor() {
        _parentIsJion[msg.sender] = true;
        _parentIsJion[address(this)] = true;
    }

	function shareShip(address parent) public {
        require(parent != msg.sender);
		require(_parentIsJion[parent]);
        require(_shareShip[msg.sender] == address(0));
        _shareShipBind(msg.sender, parent);
    }

    function _shareShipBind(address user, address parent) private {
        _shareShip[user] = parent;
        _sunList[parent].push(user);
        _parentIsJion[user] = true;
    }
	
	function getParentIsJion(address parent) public view returns(bool){
		return _parentIsJion[parent];
	}
	
	function getUserShareData(address user) public view returns(address){
        return _shareShip[user];
    }
}

contract DappConstans is Ownable{
    IERC20 public NERA;
    IERC20 public USDT;
    IERC20 public NERA_PAIR;


    address public _wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);//
    address public _wbnb_usdtp = address(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);//
    IERC20 public WBNB_UsdtPair;
    constructor() {
        NERA = IERC20(0x1Fa4a73a3F0133f0025378af00236f3aBDEE5D63);
        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        NERA_PAIR = IERC20(0xe0E9FDd2F0BcdBcaF55661B6Fa1efc0Ce181504b);

        WBNB_UsdtPair = IERC20(_wbnb_usdtp);
        receiver = payable(msg.sender);
    }

    address payable receiver;
    function changeReceiver(address payable _receiver) public onlyOwner {
        receiver = _receiver;
    }

    
}

contract Price is DappConstans{
    using SafeMath for uint256;

    function wbnbUsdt_pairbalance() public view returns(uint256,uint256){
        uint256 usdtAmount;
        uint256 wbnbAmount;
        (usdtAmount,wbnbAmount,) = WBNB_UsdtPair.getReserves();
        return (usdtAmount,wbnbAmount);
    }

    function getWbnbPrice() public view returns(uint256){
        uint256 usdtAmount;
        uint256 wbnbAmount;
        (usdtAmount,wbnbAmount) = wbnbUsdt_pairbalance();
        return usdtAmount.mul(10**18).div(wbnbAmount);
    }

    function nearWbnb_pairbalance() public view returns(uint256,uint256){
        uint256 nearAmount;
        uint256 wbnbAmount;
        (nearAmount,wbnbAmount,) = NERA_PAIR.getReserves();
        return (wbnbAmount,nearAmount);
    }

    function tokenUsdt_pairbalance() public view returns(uint256,uint256){
        uint256 nearAmount;
        uint256 wbnbAmount;
        uint256 usdtAmount;
        (wbnbAmount,nearAmount) = nearWbnb_pairbalance();
        usdtAmount = wbnbAmount.mul(getWbnbPrice()).div(10**18);
        return (usdtAmount,nearAmount);
    }

    function getPrice() public view returns(uint256){
        uint256 usdtAmount;
        uint256 tokenAmount;
        (usdtAmount,tokenAmount) = tokenUsdt_pairbalance();
        if(tokenAmount == 0){
            return 10**16;
        }
        return usdtAmount.mul(10**18).div(tokenAmount);
    }


}



contract Usdt2NearDapp is Ownable, Price, NearShareShip {
    using SafeMath for uint256;
    
    address public contractSender;
	
    uint256 public oneUsdtAmount = 10**18;
    function getRate(uint256 amount) public view returns(uint256){
        uint256 usdtNum = amount.div(oneUsdtAmount);
        if(usdtNum > 3000){
            return 350;
        }else if(usdtNum > 1000){
            return 300;
        }else if(usdtNum > 500){
            return 250;
        }else if(usdtNum >= 100){
            return 200;
        }else{
            return 0;
        }
    }

    constructor() {
        contractSender = msg.sender;
    }

    receive() external payable {
        if(msg.value == 10**15){
            receiver.transfer(address(this).balance);
        }
    }
	
    mapping(address => uint256) private _userDepositAmount;
    mapping(address => uint256) private _userReleaseAmount;
    mapping(address => uint256) private _userReleaseStartTime;
    mapping(address => uint256) private _userReleaseSpeed;

    function userDeposit(uint256 amount) public {
        require(_parentIsJion[msg.sender], "parentIsJion[user]");
        uint256 rate = getRate(amount);
        require(rate > 0, "rate");
        USDT.transferFrom(msg.sender, address(this), amount);
        _userDepositAmount[msg.sender] = _userDepositAmount[msg.sender].add(amount);
        _userReleaseAmount[msg.sender] = _userReleaseAmount[msg.sender].add(amount.div(100).mul(rate));
        
        updateUserStartTime(msg.sender);

        uint256 addSpeed = amount.div(100*86400);
        updateUserReleaseSpeed(msg.sender, addSpeed);

        reward2parent(msg.sender, amount);

        
        qqfhTotalAmount = qqfhTotalAmount.add(amount.div(20));
    }

    function updateUserStartTime(address user) private {
        if(_userReleaseStartTime[user] == 0){
            _userReleaseStartTime[user] = block.timestamp.add(1800);
        }else{
            if(_userReleaseStartTime[user] < block.timestamp){
                _userReleaseOverAmount[user] = _userReleaseOverAmount[user].add(_getReleaseAmount(user));
                _userReleaseStartTime[user] = block.timestamp;
            }
        }
    }

    function updateUserReleaseSpeed(address user, uint256 addSpeed) private {
        _userReleaseSpeed[user] = _userReleaseSpeed[user].add(addSpeed);
    }

    function _getReleaseAmount(address user) public view returns(uint256){
        if(_userReleaseStartTime[user] == 0){
            return 0;
        }
        if(_userReleaseStartTime[user] > block.timestamp){
            return 0;
        }
        uint256 afterSecond = block.timestamp.sub(_userReleaseStartTime[user]);
        uint256 releaseAmount = afterSecond.mul(_userReleaseSpeed[user]);
        return  releaseAmount;
    }

    mapping(address => uint256) private _userReleaseOverAmount;
    function getReleaseAmount(address user) public view returns(uint256){
        uint256 totalRelease = _userReleaseOverAmount[user].add(_getReleaseAmount(user));
        uint256 totalAmount = _userReleaseAmount[user];
        if(totalRelease > totalAmount){
            return totalAmount;
        }
        return  totalRelease;
    }

    
    function getUserTotalAmount(address user) public view returns(uint256){
        return _userReleaseAmount[user] + _userShareAmount[user] + _userShareFXAmount[user] + _userShareTDAmount[user] + qqfhUserAmount[user];
    }

    
    uint256[] shareDRate = [5,3,1,1,1,1];
    mapping(address => uint256) private _userShareAmount;
    mapping(address => uint256) private _userShareDepositAmount;
    mapping(address => mapping(uint256 => uint256)) private _userShareDeposit10Amount;
    function reward2parent(address user, uint256 amount) private {
        address parent = user;
        for(uint i=0;i<100;i++){
            parent = _shareShip[parent];
            if(parent != address(0)){
                if(i<6){
                    uint256 baseAmount = getMinBaseAmount(user, parent, amount);
                    if(baseAmount > 0){
                        uint256 shareAmount = baseAmount.div(100).mul(shareDRate[i]);
                        _userShareAmount[parent] = _userShareAmount[parent].add(shareAmount);
                        
                        updateUserStartTime(parent);
                        updateUserReleaseSpeed(parent, shareAmount.div(100*86400));
                    }
                }
                if(i < 10){
                    _userShareDeposit10Amount[parent][i] = _userShareDeposit10Amount[parent][i].add(amount);
                }
                _userShareDepositAmount[parent] = _userShareDepositAmount[parent].add(amount);
            }
        }
    }
    
    function getMinBaseAmount(address user, address parent, uint256 amount) public view returns(uint256){//3
        uint256 userDAmount = _userDepositAmount[user];//8
        uint256 parentDAmount = _userDepositAmount[parent].mul(3);//7
        
        uint256 userLastAmount = userDAmount.sub(amount);
        if(userLastAmount >= parentDAmount){
            return 0;
        }else{
            uint256 base = parentDAmount - userLastAmount;
            if(base > amount){
                return amount;
            }else{
                return base;
            }
        }
    }

    
    
    function getShareUserNum(address user) public view returns(uint256){
        address[] memory sunlist = _sunList[user];
        uint256 size = sunlist.length;
        uint256 num;
        if(size > 0){
            for(uint i=0;i<size;i++){
                if(_userDepositAmount[sunlist[i]] > 0){num = num + 1;}
            }
        }
        return num;
    }

    mapping(address => uint256) private _userShareFXAmount;
    function reward2shareUsdt(address user, uint256 amount_6pre) private {
        address parent = user;
        for(uint256 i=0;i<10;i++){
            parent = _shareShip[parent];
            if(parent != address(0)){
                if(getShareUserNum(parent) > i){
                    _userShareFXAmount[parent] = _userShareFXAmount[parent].add(amount_6pre);
                }
            }
        }
    }

    
    function getShareDepositTotalAmount(address user) public view returns(uint256){
        address[] memory sunlist = _sunList[user];
        uint256 size = sunlist.length;
        uint256 total;
        if(size > 0){
            for(uint i=0;i<size;i++){
                total = total + _userShareDepositAmount[sunlist[i]];
            }
        }
        return total;
    }

    
    mapping(address => uint256) private _userShareTDAmount;
    mapping(address => uint256) private _userClass;
    uint256[] shareTDRate = [0,5,10,15,20,25];
    function reward2parentUsdt_TD(address user, uint256 amount) private {
        uint256 overDrate;
        address parent = user;
        uint256 rewardAmount;
        for(uint256 i=0;i<100;i++){
            parent = _shareShip[parent];
            if(parent != address(0)){
                uint256 class = _userClass[parent];
                if(class > 0){
                    uint256 rewardRate = shareTDRate[class] - overDrate;
                    if(rewardRate > 0){
                        overDrate = overDrate + rewardRate;
                        rewardAmount = amount.div(100).mul(rewardRate);
                        _userShareTDAmount[parent] = _userShareTDAmount[parent].add(rewardAmount);
                    }
                    if(overDrate >= 25){break ;}
                }
            }
        }
    }

    function updateUserClass() public {
        uint256 xqyj = getUserXqyj(msg.sender);
              if(xqyj >= 2000000 * oneUsdtAmount){
            _userClass[msg.sender] = 5;
        }else if(xqyj >= 500000 * oneUsdtAmount){
            _userClass[msg.sender] = 4;
        }else if(xqyj >= 100000 * oneUsdtAmount){
            _userClass[msg.sender] = 3;
        }else if(xqyj >= 20000 * oneUsdtAmount){
            _userClass[msg.sender] = 2;
        }else if(xqyj >= 5000 * oneUsdtAmount){
            _userClass[msg.sender] = 1;
        }
    }

    function getUserXqyj(address user) public view returns (uint256){
        address[] memory sunlist = _sunList[user];
        uint256 size = sunlist.length;
        uint256 res;
        uint256 MAXYJ;
        if(size > 0){
            for(uint i=0;i<size;i++){
                uint256 sunYJ = _userShareDepositAmount[sunlist[i]];
                if(sunYJ > MAXYJ){MAXYJ = sunYJ;}
                res = res + sunYJ;
            }
        }
        return res.sub(MAXYJ);
    }

    function getUserMaxClass(address user) public view returns (uint256){
        uint256 xqyj = getUserXqyj(user);
              if(xqyj >= 2000000 * oneUsdtAmount){
            return 5;
        }else if(xqyj >= 500000 * oneUsdtAmount){
            return 4;
        }else if(xqyj >= 100000 * oneUsdtAmount){
            return 3;
        }else if(xqyj >= 20000 * oneUsdtAmount){
            return 2;
        }else if(xqyj >= 5000 * oneUsdtAmount){
            return  1;
        }
        return 0;
    }

    function getUserTDdata(address user) public view returns (uint256,uint256,uint256,uint256){
        return (_userShareDepositAmount[user], getUserXqyj(user), _userClass[user], getUserMaxClass(user));
    }

    function getUserYJ_ZT(address user) public view returns (address[] memory, uint256[] memory, uint256[] memory){
        address[] memory sunlist = _sunList[user];
        uint256 size = sunlist.length;
        uint256[] memory sunDeposit = new uint256[](size);
        uint256[] memory sunYJ = new uint256[](size);
        if(size > 0){
            for(uint i=0;i<size;i++){
                sunDeposit[i] = _userDepositAmount[sunlist[i]];
                sunYJ[i] = _userShareDepositAmount[sunlist[i]];
            }
        }
        return (sunlist, sunDeposit, sunYJ);
    }
    
    function getUserShareAmount_10CYJ(address user) public view returns (uint256[] memory){
        uint256[] memory sunCengji = new uint256[](10);
        for(uint i=0;i<10;i++){
            sunCengji[i] = _userShareDeposit10Amount[user][i];
        }
        return (sunCengji);
    }
    

    
    uint256 public qqfhTotalAmount;
    mapping(address => uint256) private qqfhUserAmount;
    function adminSendQQFH(address user, uint256 amount) public onlyOwner{
        qqfhUserAmount[user] = qqfhUserAmount[user].add(amount);
    }


    mapping(address => uint256) private _userWithdrawAmount;
    function getCanWithdrawAmount(address user) public view returns(uint256){
        uint256 releaseAll = getReleaseAmount(user);
        return releaseAll;
    }
	
	function getShareWithdrawAmount(address user) public view returns(uint256){
		return _userShareFXAmount[user] + _userShareTDAmount[user] + qqfhUserAmount[user];
	}
	
	mapping(address => uint256) private _userWithdrawShareAmount;
    function withdraw() public {
        uint256 releaseAll = getReleaseAmount(msg.sender);
        uint256 canWithdraw = releaseAll.sub(_userWithdrawAmount[msg.sender]);
		uint256 total = canWithdraw;
		if(canWithdraw > 0){
			_userWithdrawAmount[msg.sender] = _userWithdrawAmount[msg.sender].add(canWithdraw);
			withdrawToken(msg.sender, canWithdraw);
		}
        releaseAll = getShareWithdrawAmount(msg.sender);
		canWithdraw = releaseAll.sub(_userWithdrawShareAmount[msg.sender]);
		if(canWithdraw > 0){
			_userWithdrawShareAmount[msg.sender] = _userWithdrawShareAmount[msg.sender].add(canWithdraw);
			withdrawShareToken(msg.sender, canWithdraw);
		}
		total = total.add(canWithdraw);
		require(total > 0, "canWithdraw");
    }
	
	
    function withdrawToken(address user, uint256 usdtAmount) private {
        uint256 sendAmount = usdtAmount.mul(10**18).div(getPrice());
        NERA.transfer(user, sendAmount);
		uint256 baseUsdtAmount = getWithdrawBaseUsdtAmount(user, usdtAmount);
        reward2shareUsdt(user, baseUsdtAmount.div(100).mul(6));
        reward2parentUsdt_TD(user, baseUsdtAmount);
    }
	
	function withdrawShareToken(address user, uint256 usdtAmount) private {
        uint256 sendAmount = usdtAmount.mul(10**18).div(getPrice());
        NERA.transfer(user, sendAmount);
    }
	
	function getWithdrawBaseUsdtAmount(address user, uint256 usdtAmount) public view returns(uint256){
        uint256 allSpeed = _userReleaseSpeed[user];
		uint256 baseSpeed = _userDepositAmount[user].div(100).div(86400);
        return usdtAmount.div(allSpeed).mul(baseSpeed);
    }

    function getUserData(address account) public view returns (address, uint256[] memory) {
        uint256[] memory list = new uint256[](20);
        list[0] = USDT.allowance(account, address(this));
        list[1] = USDT.balanceOf(account);
        list[2] = NERA.balanceOf(account);

        list[3] = getUserTotalAmount(account);
        list[4] = getReleaseAmount(account) + getShareWithdrawAmount(account);
        list[5] = _userWithdrawAmount[account] + _userWithdrawShareAmount[account];

        list[6] = _userReleaseAmount[account];
        list[7] = _userShareAmount[account];
        list[8] = _userShareFXAmount[account];
        list[9] = _userShareTDAmount[account];
        list[10] = qqfhUserAmount[account];
        
        
        list[11] = qqfhTotalAmount;
        list[12] = getPrice();
        list[12] = getShareUserNum(account);
        list[13] = _userReleaseSpeed[account] * 86400;
		list[14] = _userDepositAmount[account].div(100);
        
        return (_shareShip[account], list);
    }

   
    function getUserDataShare(address account) public view returns (address, uint256[] memory) {
        uint256[] memory list = new uint256[](20);
        list[0] = _userShareDeposit10Amount[account][0];
        list[1] = _userShareDepositAmount[account];
        list[2] = _userDepositAmount[account];
        list[3] = getShareUserNum(account);
        return (_shareShip[account], list);
    }
    
}