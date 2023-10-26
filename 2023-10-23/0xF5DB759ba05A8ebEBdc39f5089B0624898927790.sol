pragma solidity ^ 0.8.0;
// SPDX-License-Identifier: UNLICENSED
interface IERC20 {
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

contract BITYCOON {

address[] public tokens;
     mapping(address=>bool) public restakeTokens;
      mapping(address=>uint) public tokenprice;
    using SafeMath for uint256;
    event Multisended(uint256 value , address indexed sender);
    event Reinvest(address user,uint256 package,uint256 tokenAmt,address tokenInfo,uint256 tokenPrice);
   
    address public owner;
    address public operator;
     address public BTYC;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address ownerAddress,address _operator, address _btycToken,uint _btycprice) {
        owner = ownerAddress; 
        operator=_operator;
        BTYC = _btycToken;
		tokens.push(BTYC);
        restakeTokens[BTYC]=true;
        tokenprice[BTYC]=_btycprice;
    }
    function investment(uint256 _package,address token) external {
        require(_package>=5,"Minimum Package is 10$");
        uint256 tokenAmt=_package*tokenprice[token];
        require(restakeTokens[token] && tokenprice[token]!=0 ,"invalid token");
          require(
            IERC20(token).allowance(msg.sender, address(this)) >= tokenAmt,
            "BigTycoon: ERC20 allowance exceed!"
        );
        require(
            IERC20(token).balanceOf(msg.sender) >= tokenAmt,
            "BigTycoon: ERC20 low balance!"
        );
         IERC20(token).transferFrom(msg.sender, owner, tokenAmt);
       emit Reinvest(msg.sender,_package,tokenAmt,token,tokenprice[token]);
    }
    
   
    function addAndUpdateNewTokenStatus(address _token,bool _status,uint256 _tokenPrice) public  {
        require(msg.sender==operator,"Only Operato");
        require(restakeTokens[_token]!=_status,"already active token");
		tokens.push(_token);
        restakeTokens[_token] = _status;
        tokenprice[_token]=_tokenPrice;
    }
    function withdrawToken(IERC20 _token ,uint256 _amount) external onlyOwner {
        _token.transfer(owner,_amount);
    }

    function withdraw(uint256 _amount) external onlyOwner {
        payable(owner).transfer(_amount);
    }
     function updateTokenPriceInUsd(address _token,uint _price) public {
        require(msg.sender==operator,"Only Operato");
        require(restakeTokens[_token],"token status not active");
        tokenprice[_token] =_price;
    } 
     function changeOpratorwallet(address _newWallet) public{
         require(msg.sender==operator,"Only Operato");
        operator =_newWallet;
    }
    

}