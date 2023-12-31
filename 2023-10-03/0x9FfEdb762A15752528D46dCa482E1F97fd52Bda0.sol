/**
 *Submitted for verification at testnet.bscscan.com on 2023-09-26
*/

/**
 *Submitted for verification at testnetstage.bscscan.com on 2023-09-25
*/

/**
 *Submitted for verification at testnetstage.bscscan.com on 2023-09-22
*/

/**
 *Submitted for verification at BscScan.com on 2023-07-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

/**
 *Submitted for verification at polygonscan.com on 2022-10-19
*/

/**
 *Submitted for verification at polygonscan.com on 2022-10-10
*/

/**
 *Submitted for verification at polygonscan.com on 2022-10-01
*/

/**
 *Submitted for verification at polygonscan.com on 2022-09-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

pragma solidity ^ 0.8.0;

// SPDX-License-Identifier: UNLICENSED

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 value) external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
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

contract RSPMTOKEN {
    using SafeMath for uint256;
    event Reinvestment(address indexed user,uint256 amountBuy,string  sponcer_id,string  sponsor_name);
    event MemberPayment(address indexed  investor,uint netAmt,uint256 Withid);
    event Payment(uint256 NetQty);

    IBEP20 private USDT; 
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address ownerAddress,IBEP20 _USDT) {
        owner = ownerAddress; 
        USDT = _USDT;    
    }
    
    function upgrade(uint256 _amount,string memory sponsor_name, string memory sponcer_id) external {
        require(_amount==50 || _amount==100 || _amount==200 || _amount==500 || _amount==1000 || _amount==2500 || _amount==5000,"invalid package");
    	uint256 tot_amt = (_amount*1e18);   
        require(USDT.balanceOf(msg.sender) >= tot_amt,"Low USDT Balance");
        require(USDT.allowance(msg.sender,address(this)) >= tot_amt,"Invalid allowance ");
        USDT.transferFrom(msg.sender, owner, tot_amt);
        emit Reinvestment(msg.sender,_amount,sponcer_id,sponsor_name);
	}

    function multisendToken(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 totalQty,uint256[] memory WithId,IBEP20 _TKN) public payable {
    	uint256 total = totalQty;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            _TKN.transferFrom(msg.sender, _contributors[i], _balances[i]);
			      emit MemberPayment(_contributors[i],_balances[i],WithId[i]);
        }
		emit Payment(totalQty);
        
    }
    
    function withdrawToken(IBEP20 _token ,uint256 _amount) external onlyOwner {
        _token.transfer(owner,_amount);
    }

    function withdraw(uint256 _amount) external onlyOwner {
        payable(owner).transfer(_amount);
    }
	
}