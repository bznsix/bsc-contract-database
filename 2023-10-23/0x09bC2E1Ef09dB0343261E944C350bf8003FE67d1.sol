/**
 *Submitted for verification at testnet.bscscan.com on 2023-10-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

pragma solidity 0.5.10;

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract TradeMart {
	using SafeMath for uint256;
    IERC20 public token = IERC20(0x55d398326f99059fF775485246999027B3197955); 
	uint256 constant public INVEST_MIN_AMOUNT = 200e18; // 50 BUSD	
	uint256 constant public PROJECT_FEE = 1100;
	uint256 constant public PERCENT_STEP = 10;
	uint256 constant public PERCENTS_DIVIDER = 10000;
	
	
    
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }

    mapping(address => mapping (uint => RefUserDetail)) public RefUser;
    mapping(address => uint256) public referralCount_;
    
	
	mapping(address => address) internal referralLevel1Address;
    
	
    
	

	struct Deposit {
		uint256 amount;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
		
		address referrer;
		uint256[10] levels;
		uint256 retopupcount;
		uint256 totalBonus;
		uint256 withdrawn;
       
	}
	
	
	

	mapping (address => User) internal users;

	
	address payable public commissionWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address payable wallet) public {
		require(!isContract(wallet));
		commissionWallet = wallet;
	}
	
	function getDownlineRef(address senderAddress, uint dataId) public view returns (address,uint) { 
        return (RefUser[senderAddress][dataId].refUserAddress,RefUser[senderAddress][dataId].refLevel);
    }
    
    function addDownlineRef(address senderAddress, address refUserAddress, uint refLevel) internal {
        referralCount_[senderAddress]++;
        uint dataId = referralCount_[senderAddress];
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
    }

    
	
	
	 function distributeRef(address _referredBy,address _sender, bool _newReferral) internal {
       
          address _customerAddress        = _sender;
        // Level 1
        referralLevel1Address[_customerAddress]                     = _referredBy;
        if(_newReferral == true) {
            addDownlineRef(_referredBy, _customerAddress, 1);
        }
    
		
       
}
	
	
	function investtopup(address referrer,address child, uint256 amounts) public  {
	
	/*	if (!started) {
			if (msg.sender == commissionWallet) {
				started = true;
			} else revert("Not started yet");
		}*/

		require(amounts >= INVEST_MIN_AMOUNT);
        token.transferFrom(msg.sender, address(this), amounts);
        token.transfer(commissionWallet,amounts);
		//commissionWallet.transfer(fee);
		emit FeePayed(msg.sender, amounts);

		User storage user = users[child];
		
		
		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != child) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 10; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
			
		}
		 bool    _newReferral                = true;
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            referrer                     = referralLevel1Address[msg.sender];
            _newReferral                    = false;
        }
		
		

		if (user.deposits.length == 0) {
			
			emit Newbie(msg.sender);
		}
      
       
		user.deposits.push(Deposit(amounts, block.timestamp));
		emit NewDeposit(msg.sender, amounts);
	}

	function invest(address referrer, uint256 amounts) public  {
	
	/*	if (!started) {
			if (msg.sender == commissionWallet) {
				started = true;
			} else revert("Not started yet");
		}*/

		require(amounts >= INVEST_MIN_AMOUNT);
        token.transferFrom(msg.sender, address(this), amounts);
        token.transfer(commissionWallet,amounts);
		//commissionWallet.transfer(fee);
		emit FeePayed(msg.sender, amounts);

		User storage user = users[msg.sender];
		
		
		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 10; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
			
		}
		 bool    _newReferral                = true;
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            referrer                     = referralLevel1Address[msg.sender];
            _newReferral                    = false;
        }
		
		

		if (user.deposits.length == 0) {
			
			emit Newbie(msg.sender);
		}
      
       
		user.deposits.push(Deposit(amounts, block.timestamp));
		emit NewDeposit(msg.sender, amounts);
	}
    
	function retopup(uint256 retopupamount) public  {
	
	/*	if (!started) {
			if (msg.sender == commissionWallet) {
				started = true;
			} else revert("Not started yet");
		}*/

		require(retopupamount >= INVEST_MIN_AMOUNT);
        token.transferFrom(msg.sender, address(this), retopupamount);
        token.transfer(commissionWallet,retopupamount);
		//commissionWallet.transfer(fee);
		emit FeePayed(msg.sender, retopupamount);

		User storage user = users[msg.sender];
		user.retopupcount=user.retopupcount+1;
		
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}
	
	function getUserRetopupCount(address userAddress) public view returns(uint256) {
		return users[userAddress].retopupcount;
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}



	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
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