// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.18;

import "./tokens/ERC20.sol";
import "./lib/ExcludedFromFeeList.sol";

contract ET is ERC20, ExcludedFromFeeList {
    address constant per3 = 0x451053B80Ba37235d44750117F786183F59E0A72;
    address constant per1 = 0x6F5116C481F21e0cde3D89417164470729544d92;
    address constant per2_7 = 0x08d15B053CAAb0fc30BD2f2D3024a1cD8BAD82e2;
    address constant per1_8 = 0xBC6Dc27cf9E1a19CFa62bA7B0D8deaa30b86a1e1;

    bool public trading;

    constructor() Owned(msg.sender) ERC20("ET", "ET", 18, 1_0000_0000 ether) {
        excludeFromFee(msg.sender);
        trading = true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            super._transfer(sender, recipient, amount);
        } else {
            require(trading, "trd");
            balanceOf[sender] -= amount;

            uint256 p3 = amount * 30 / 1000;
            uint256 p1 = amount * 10 / 1000;
            uint256 p2_7 = amount * 27 / 1000;
            uint256 p1_8 = amount * 18 / 1000;
            uint256 burn = amount * 5 / 1000;
            uint256 transferAmount = amount - p3 - p1 - p2_7 - p1_8 - burn;
            unchecked {
                balanceOf[per3] += p3;
                balanceOf[per1] += p1;
                balanceOf[per2_7] += p2_7;
                balanceOf[per1_8] += p1_8;
                balanceOf[address(0xdead)] += burn;
                balanceOf[recipient] += transferAmount;
            }
            emit Transfer(sender, per3, p3);
            emit Transfer(sender, per1, p1);
            emit Transfer(sender, per2_7, p2_7);
            emit Transfer(sender, per1_8, p1_8);
            emit Transfer(sender, address(0xdead), burn);
            emit Transfer(sender, recipient, transferAmount);
        }
    }

    function openTrading(bool status) external onlyOwner {
        trading = status;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public immutable totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        unchecked {
            balanceOf[msg.sender] += _totalSupply;
        }

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - amount;
        }

        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        balanceOf[from] -= amount;
        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "solmate/auth/Owned.sol";

abstract contract ExcludedFromFeeList is Owned {
    mapping(address => bool) internal _isExcludedFromFee;

    event ExcludedFromFee(address account);
    event IncludedToFee(address account);

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludedToFee(account);
    }

    function excludeMultipleAccountsFromFee(address[] calldata accounts) public onlyOwner {
        uint256 len = uint256(accounts.length);
        for (uint256 i = 0; i < len;) {
            _isExcludedFromFee[accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
