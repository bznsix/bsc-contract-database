// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../../interfaces/IBEP20.sol";
import "../../interfaces/OwnableV2.sol";

contract EvoGameV1 is OwnableV2
{

    IBEP20 token;
/// Commission for offline contract work
    uint Fee = 2 * 10 ** 15;

    constructor (address _token) 
    {
        token = IBEP20(payable(_token));
    }
/// Frozen tokens that can be withdrawn by the user
    mapping (address => uint) public freezed;



/// One transaction - one rent
    modifier unfreez(address user) 
    {
        require(freezed[user] == 0, "unfreez now");
        _;
    }


/// You can withdraw only if there are tokens on defrosting
    modifier canUnfreez(address user)
    {
        require(freezed[user] > 0, "unfreez now");
        _;
    }


/// Checking that there is enough commission
    modifier enoughtFee(uint amount)
    {
        require( amount >= Fee, "Not enought fee");
        _;
    }


                        /// PUBLIC VIEW
/// Frezed amount
    function getFreezed (address user) public view returns(uint)
    {
        return freezed[user];
    } 

            /// PUBLIC PAYABLE
/// Unfreez and transfer tokens to user
    function getUnfreezAll() enoughtFee(msg.value) canUnfreez(msg.sender) public payable returns (bool)
    {
        payable(_owner).transfer(msg.value);
        token.transfer(msg.sender, getFreezed(msg.sender));
        freezed[msg.sender] = 0;
        return true;
    }
    

            /// ADMIN

/// Withdraw balance                     
    function withdraw() onlyOwner public
    {
        payable(_owner).transfer(address(this).balance);
    }

/// TRANSFER 
    function transferFromContract(address to,  uint amount) public onlyOwner returns (bool)
    {
        token.transfer(to, amount);
        return true;
    }

/// SET UNFREEZED TOKEN TO USER            <-----------------  this function 
    function SetUnfreez( address user, uint amount) public onlyOwner unfreez(user)
    {
        freezed[user] = amount;
    }

/// Change token contract
    function SetToken (address _token) public onlyOwner
    {
        token = IBEP20(payable(_token));
    }
///    
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Context.sol";

abstract contract OwnableV2 is Context
{
    address _owner;
    address public _newOwner;
    constructor()  
    {
        _owner = payable(msg.sender);
    }

    modifier onlyOwner() 
    {
        require(_msgSender() == _owner, "Only owner");
        _;
    }

    function changeOwner(address newOwner) onlyOwner public
    {
        _newOwner = newOwner;
    }
    function confirm() public
    {
        require(_newOwner == msg.sender);
        _owner = _newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

abstract contract Context 
{
    function _msgSender() internal view virtual returns (address) 
    {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) 
    {
        this; 
        return msg.data;
    }
}
