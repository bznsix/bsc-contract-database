pragma solidity ^0.8.7;

interface OldContract {
    
    function userInfo(address _addr) view external returns( 
        uint256 for_withdraw, 
        uint256 totalInvested, 
        uint256 totalWithdrawn, 
        uint256 totalBonus,
        uint256 giveawayBonus,
         uint256[5] memory structure
        );
}
interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    
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


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}



struct daysPercent {
    uint8 life_days;
    uint8 percent;
}

struct DepositStruct {
    uint8 lockUp;
    uint256 amount;
    uint40 time;
    uint256 finish;
}

struct Investor {
    address daddy;
    uint256 dividends;
    uint256 matchBonus;
    uint40 lastPayout;
    uint256 totalInvested;
    uint256 totalWithdrawn;
    uint256 totalBonus;
    uint256 giveawayBonus;
    DepositStruct [] depositsArray;
    uint256[5] structure;
}

contract BFarmV2 {
    using SafeMath for uint256;
    using SafeMath for uint40;
    using SafeERC20 for IERC20;

    uint256 public contractInvested;
    uint256 public contractWithdrawn;
    uint256 public matchBonus;

    uint8 constant BonusLinesCount = 5;
    uint16 constant percentDivider = 1000;
    uint256 constant public ceoFee = 150;
    uint8[BonusLinesCount] public referralBonus = [50, 30, 20, 5,5];
    uint40 public TIME_STEP = 86400;
    IERC20 public BUSD;

    OldContract public oldContract = OldContract(0x45C32dcB2dA837A142a3B57Fb59532302978EcA8);

    mapping(uint8 => daysPercent) public WPR;
    mapping(address => Investor) public investorsMap;
    mapping(address => bool) public isClaimed;
    mapping(address=>uint256) public lossAmount;


    address payable public ceoWallet;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount); 

        constructor(address payable ceoAddr) {
        require(!isContract(ceoAddr));
        ceoWallet = ceoAddr;

        uint8 percentage = 140;
        for (uint8 daysInvested = 8; daysInvested <= 25; daysInvested++) {
            WPR[daysInvested] = daysPercent(daysInvested, percentage);
            percentage+= 6;
        }
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }

   
    function claimableAmount() public view returns(uint256)
    {
        (uint256 for_withdraw, 
        uint256 totalInvested, 
        uint256 totalWithdrawn, 
        uint256 totalBonus,
        uint256 giveawayBonus,
         uint256[5] memory structure) = oldContract.userInfo(msg.sender);
         if(totalInvested>totalWithdrawn){
            return (totalInvested-totalWithdrawn);
         }
         else
         {
             return 0;
         }    
        
         
    }

    function _payInvestor(address _addr) private {
        uint256 payout = this.calcPayout(_addr);

        if (payout > 0) {
            investorsMap[_addr].lastPayout = uint40(block.timestamp);
            investorsMap[_addr].dividends += payout;
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = investorsMap[_addr].daddy;

        for (uint i = 0; i < BonusLinesCount; i ++) {
            if(up == address(0)) break;

            uint256 bonus = _amount * referralBonus[i] / percentDivider;

            investorsMap[up].matchBonus += bonus;
            investorsMap[up].totalBonus += bonus;

            matchBonus += bonus;

            emit MatchPayout(up, _addr, bonus);

            up = investorsMap[up].daddy;
        }
    }

     function _setUpdaddy(address _addr, address _upline) private {
        if (investorsMap[_addr].daddy == address(0) && _addr != ceoWallet && investorsMap[_upline].depositsArray.length > 0) {

            investorsMap[_addr].daddy = _upline;

            for(uint i = 0; i < BonusLinesCount; i++) {
                investorsMap[_upline].structure[i]++;

                _upline = investorsMap[_upline].daddy;

                if(_upline == address(0)) break;
            }

        }
    }

    function deposit(uint8 _lockUp, address _upline, uint256 amount) external { 
        uint256 currentBlockTimestamp = uint256(block.timestamp);
        bool hasLaunchPassed = currentBlockTimestamp > 1643428800;
        require(WPR[_lockUp].life_days >= 8, "Tarif not found");
        require(amount >= 10 ether, "Minimum deposit amount is 10 BUSD");
        require(hasLaunchPassed == true, "We still havent launched yet!");

        BUSD.safeTransferFrom(msg.sender, address(this), amount);
        Investor storage investor = investorsMap[msg.sender];
        require(investor.depositsArray.length < 100, "Max 100 deposits per address");

        uint256 cfee  = amount.mul(ceoFee).div(percentDivider);
        if(investor.depositsArray.length==0)
        {
            lossAmount[msg.sender] = claimableAmount();
        }

        if(lossAmount[msg.sender]>0)
        {
            if(lossAmount[msg.sender]>cfee){
                BUSD.safeTransfer(msg.sender, cfee);
                lossAmount[msg.sender]-=cfee;
            }
            else{
                BUSD.safeTransfer(msg.sender, lossAmount[msg.sender]);
                lossAmount[msg.sender]=0;
            }
        }
        else{
            BUSD.safeTransfer(ceoWallet, cfee);
        }
 
        uint256 giveaway = 0;
        if(WPR[_lockUp].life_days>=25)
        {
            giveaway = amount.mul(3).div(100);
        }
        else if(WPR[_lockUp].life_days>=16)
        {
            giveaway = amount.mul(2).div(100);
        }
        if(giveaway>0){
            BUSD.safeTransfer(msg.sender,giveaway);  
            investor.giveawayBonus = investor.giveawayBonus.add(giveaway);
        }

        _setUpdaddy(msg.sender, _upline);

        investor.depositsArray.push(DepositStruct({
            lockUp: _lockUp,
            amount: amount,
            time: uint40(block.timestamp),
            finish : block.timestamp.add(_lockUp*TIME_STEP)
        }));

        investor.totalInvested += amount;
        contractInvested += amount;

        _refPayout(msg.sender, amount);

        emit NewDeposit(msg.sender, amount, _lockUp);

    }

    function getInfo() view external returns ( 
        uint256 leLockup, 
        uint256 leTime, 
        uint256 leCurrent, 
        bool leTimeLess
        ){
        
        Investor storage investor = investorsMap[msg.sender];
        
        uint256 lastDeposit = investor.depositsArray.length - 1;
        uint256 sendDepositLockup = uint256(investor.depositsArray[lastDeposit].lockUp);
        uint256 sendDepositBlocktime = uint256(investor.depositsArray[lastDeposit].time);
        uint256 sendCurrentTime = uint256(block.timestamp);
        bool isCurrenTimeLess = sendCurrentTime < sendDepositBlocktime + sendDepositLockup*TIME_STEP;
    
        return(
            sendDepositLockup,
            sendDepositBlocktime,
            sendCurrentTime,
            isCurrenTimeLess
            );
    }

    function withdraw() external { 
        Investor storage investor = investorsMap[msg.sender];

        _payInvestor(msg.sender);

        require(investor.dividends > 0);

        uint256 amount = investor.dividends;

        investor.dividends = 0;
        investor.totalWithdrawn += amount;

        contractWithdrawn += amount;

        BUSD.safeTransfer(msg.sender, amount);

    }

    function withdrawReferral() external
    {
        Investor storage investor = investorsMap[msg.sender];
        require(investor.matchBonus > 0,"No earning found");
        BUSD.safeTransfer(msg.sender, investor.matchBonus);
        investor.totalWithdrawn += investor.matchBonus;
        contractWithdrawn += investor.matchBonus;

        investor.matchBonus = 0;
    }

    function depositHalf(uint8 _lockUp, address _upline, uint256 amount) internal {
        require(WPR[_lockUp].life_days > 0, "Tarif not found");
        require(amount >= 5 ether, "Minimum deposit amount is 5 BUSD");

        Investor storage investor = investorsMap[msg.sender];

        require(investor.depositsArray.length < 100, "Max 100 deposits per address");

        uint256 cfee  = amount.mul(100).div(percentDivider);
  
        BUSD.safeTransfer(ceoWallet, cfee);

 
        emit FeePayed (msg.sender, cfee);

        _setUpdaddy(msg.sender, _upline);

        investor.depositsArray.push(DepositStruct({
            lockUp: _lockUp,
            amount: amount,
            time: uint40(block.timestamp),
            finish : block.timestamp.add(_lockUp*TIME_STEP)
        }));

        investor.totalInvested += amount;
        contractInvested += amount;

        _refPayout(msg.sender, amount);

        emit NewDeposit(msg.sender, amount, _lockUp);

    }

    function withdrawHalf() external { 
        Investor storage investor = investorsMap[msg.sender];

        _payInvestor(msg.sender);
        
        require(investor.dividends > 0 || investor.matchBonus > 0, "Zero Amount");

        uint256 amount = (investor.dividends + investor.matchBonus) / 2;
        
        investor.dividends = 0;
        investor.matchBonus = 0;
        investor.totalWithdrawn += amount;
        contractWithdrawn += amount;

            
        address bigDaddy = investor.daddy;

        depositHalf(16, bigDaddy, amount);

        BUSD.safeTransfer(msg.sender, amount);
    }

    function calcPayout(address _addr) view external returns (uint256 value) {
        Investor storage investor = investorsMap[_addr];

        for (uint256 i = 0; i < investor.depositsArray.length; i++) {
                if (investor.lastPayout < investor.depositsArray[i].finish) {
                    DepositStruct storage iterDeposits = investor.depositsArray[i];
                    if(iterDeposits.finish<=block.timestamp){
                        value += iterDeposits.amount * WPR[iterDeposits.lockUp].percent / 100;
                    }
            }
        }

        return value;

        }


    function userInfo(address _addr) view external returns( 
        uint256 for_withdraw, 
        uint256 totalInvested, 
        uint256 totalWithdrawn, 
        uint256 totalBonus,
        uint256 giveawayBonus,
         uint256[BonusLinesCount] memory structure
        ) {
        Investor storage investor = investorsMap[_addr];

        uint256 payout = this.calcPayout(_addr);

        for(uint8 i = 0; i <BonusLinesCount; i++) {
            structure[i] = investor.structure[i];
        }
        
        return (
            payout + investor.dividends + investor.matchBonus,
            investor.totalInvested,
            investor.totalWithdrawn,
            investor.totalBonus,
            investor.giveawayBonus,
             structure
            );
    }

    function depositeInfo(address user) view external returns( DepositStruct[] memory deposits)
    {
        return investorsMap[user].depositsArray;
    }

    function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return investorsMap[userAddress].depositsArray.length;
	}

    function depositeInfoSingle(address user,uint256 index) view external returns( DepositStruct memory deposits)
    {
        return investorsMap[user].depositsArray[index];
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus) {
        return (contractInvested, contractWithdrawn, matchBonus);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}