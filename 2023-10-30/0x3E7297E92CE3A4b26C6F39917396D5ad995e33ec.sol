// SPDX-License-Identifier: none
pragma solidity ^0.8.8;

interface BEP20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract  UMIIDO{
    
  struct Tariff {
    uint time;
    uint percent;
  }
  
  struct Deposit {
    uint tariff;
    uint amount;
    uint at;
  }
  
  struct Investor {
    bool registered;
   Deposit[] deposits;
    uint invested;
    uint paidAt;
    uint withdrawn;
  }

   struct RoundInfo {
        uint tokensPurchased;
        RoundStatus status;
    }


    enum RoundStatus { Inactive, Active, Completed }
  
  
  uint  MIN_DEPOSIT_USDT  ;
  address public buyTokenAddr = 0xC73ace061DF1160Af60ad007a2A2BAD75825433C; 

  uint public round1tokenPrice ;
  uint public round1tokenPriceDecimal;
  uint public round2tokenPrice ;
  uint public round2tokenPriceDecimal;
  uint public round3tokenprice;
  uint public round3tokenPriceDecimal;
  uint public round4tokenprice; 
  uint public round4tokenpriceDecimal;


    RoundStatus public round1Status = RoundStatus.Inactive;
    RoundStatus public round2Status = RoundStatus.Inactive;
    RoundStatus public round3Status = RoundStatus.Inactive;
    RoundStatus public round4Status = RoundStatus.Inactive;

 event OwnershipTransferred(address); 
  
  address public owner = msg.sender;
  address payable contractAddr = payable(address(this));

  Tariff[] public tariffs;
  uint public totalInvestors;
  uint public totalInvested;
  uint public totalWithdrawal;

    
    mapping (address => Investor) public investors;
    mapping (uint => RoundInfo) public roundInfo;
    event DepositAt(address user, uint tariff, uint amount);
    event Reinvest(address user, uint tariff, uint amount);
    event Withdraw(address user, uint amount);

  
  constructor() {
  }


 function buyTokenWithUSDT(uint256 _usdtAmount, uint256 _round) external {
    uint256 tokenVal  ;
    
    require(_round == getCurrentActiveRound(), "Tokens can only be purchased during the active round");
    
    if (_round == 1) {
        require(_usdtAmount == 1250 * 10**18, "Invalid investment amount for round 1");
        tokenVal = (_usdtAmount * 10**round1tokenPriceDecimal) / round1tokenPrice; 
        require((roundInfo[1].tokensPurchased + tokenVal) <= (6600000 * 10**18), "Exceeds the maximum token limit for round 1");        
         roundInfo[1].tokensPurchased += tokenVal;
    }else if (_round == 2) {
        require(_usdtAmount == 1250 * 10**18, "Invalid investment amount for round 2");
        // require(_usdtAmount >= 600 * 10**18 && _usdtAmount <= 1250 * 10**18, "Invalid investment amount for round 3");
        tokenVal = (_usdtAmount * 10**round2tokenPriceDecimal) / round2tokenPrice;
    } else if (_round == 3) {
        require(_usdtAmount >= 600 * 10**18, "Invalid investment amount for round 3");
        tokenVal = (_usdtAmount * 10**round3tokenPriceDecimal) / round3tokenprice;
    } else if (_round == 4) {
        require(_usdtAmount >= 105 * 10**18, "Invalid investment amount for round 4");
        tokenVal = (_usdtAmount * 10**round4tokenpriceDecimal) / round4tokenprice;
    } else {
        revert("Invalid round");    
    }
    // Check contract and user balances
    BEP20 sendToken = BEP20(buyTokenAddr);
    BEP20 receiveToken = BEP20(0x55d398326f99059fF775485246999027B3197955); // mainnet 

    require(sendToken.balanceOf(address(this)) >= tokenVal, "Insufficient contract balance");
    require(receiveToken.balanceOf(msg.sender) >= _usdtAmount, "Insufficient user USDT balance");

    // Transfer USDT from the user to the contract
   receiveToken.transferFrom(msg.sender, address(this), _usdtAmount);

    // Update investor information
    investors[msg.sender].invested += tokenVal;
    totalInvested += tokenVal;

    // Emit a deposit event
    emit DepositAt(msg.sender, _round, tokenVal);

    // Transfer tokens to the contract
    sendToken.transfer(msg.sender, tokenVal);
}


             // Set buy price  Stage1 
function setround1BuyPrice(uint _price, uint _decimal) public {
      require(msg.sender == owner, "Only owner");
      round1tokenPrice        = _price;
      round1tokenPriceDecimal = _decimal;
    }

            // Set buy price  Stage2
      function setround2BuyPrice(uint _price, uint _decimal) public {
      require(msg.sender == owner, "Only owner");
      round2tokenPrice        = _price;
      round2tokenPriceDecimal = _decimal;
    }

            // Set buy price  Stage3
     function setround3BuyPrice(uint _price, uint _decimal) public {
      require(msg.sender == owner, "Only owner");
      round3tokenprice        = _price;
      round3tokenPriceDecimal = _decimal;
    }

            // Set buy price  Stage4
     function setround4BuyPrice(uint _price, uint _decimal) public {
      require(msg.sender == owner, "Only owner");
      round4tokenprice        = _price;
      round4tokenpriceDecimal = _decimal;
    }

    
    // Owner Token Withdraw    
    // Only owner can withdraw token 
    function withdrawToken(address tokenAddress, address to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        BEP20 _token = BEP20(tokenAddress);
        _token.transfer(to, amount);
        return true;
    }
    
    // Owner BNB Withdraw
    // Only owner can withdraw BNB from contract
    function withdrawBNB(address payable to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        to.transfer(amount);
        return true;
    }
    
    // Ownership Transfer
    // Only owner can call this function
    function transferOwnership(address to) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot transfer ownership to zero address");
        owner = to;
        emit OwnershipTransferred(to);
        return true;
    }

 function getTokensPurchasedInRound(uint round) public view returns (uint) {
    require(round >= 1 && round <= 4, "Invalid round number");
    return roundInfo[round].tokensPurchased;
}



   function getCurrentActiveRound() public view returns (uint) {
        if (round1Status == RoundStatus.Active) {
            return 1;
        } else if (round2Status == RoundStatus.Active) {
            return 2;
        } else if (round3Status == RoundStatus.Active) {
            return 3;
        } else if (round4Status == RoundStatus.Active) {
            return 4;
        } else {
            return 0; // No round is currently active
        }
    }


function activateRound(uint round, bool active) public {
        require(msg.sender == owner, "Only owner can activate/deactivate rounds");
        require(round >= 1 && round <= 4, "Invalid round number");

        if (active) {
            round1Status = RoundStatus.Inactive;
            round2Status = RoundStatus.Inactive;
            round3Status = RoundStatus.Inactive;
            round4Status = RoundStatus.Inactive;
        }

        if (round == 1) {
            round1Status = active ? RoundStatus.Active : RoundStatus.Inactive;
        } else if (round == 2) {
            round2Status = active ? RoundStatus.Active : RoundStatus.Inactive;
        } else if (round == 3) {
            round3Status = active ? RoundStatus.Active : RoundStatus.Inactive;
        } else if (round == 4) {
            round4Status = active ? RoundStatus.Active : RoundStatus.Inactive;
        }
    }


function getTokenRoundprice(uint round) public view returns (uint price, uint decimal) {
    require(round >= 1 && round <= 4, "Invalid round number");
    if (round == 1) {
        price = round1tokenPrice;
        decimal = round1tokenPriceDecimal;
    } else if (round == 2) {
        price = round2tokenPrice;
        decimal = round2tokenPriceDecimal;
    } else if (round == 3) {
        price = round3tokenprice;
        decimal = round3tokenPriceDecimal;
    } else if (round == 4) {
        price = round4tokenprice;
        decimal = round4tokenpriceDecimal;
    }
}



}