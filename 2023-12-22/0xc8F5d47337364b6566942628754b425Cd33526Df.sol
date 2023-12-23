// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;
    address public oneAddress;
    address public twoAddress;
    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        owner = msg.sender;
        emit OwnerUpdated(address(0), msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnerUpdated(msg.sender, newOwner);
    }

    function setOneAddress(
        address oneaddress 
    ) external onlyOwner {
        oneAddress=oneaddress;
    }
     function setTwoAddress(
        address twoaddress 
    ) external onlyOwner {
        twoAddress=twoaddress;
    }
}

contract Vault is Owned {
      
    event Deposit(address indexed sender, uint256 amount);
    struct Receord {
        address depositer;
        uint256 amount;
    }
    Receord[] public historyReceords;
    mapping(address => uint256[]) indexs;

    constructor(address payable dev) payable {
        (bool success, ) = dev.call{value: msg.value}("");
        require(success, "Failed");
    }

    function deposit(uint256 value) external {
        historyReceords.push(Receord({depositer: msg.sender, amount: value}));
        uint256 counter = historyReceords.length - 1;
        indexs[msg.sender].push(counter);

        USDT.transferFrom(msg.sender, address(this), value);
        uint256 percent80 = (value * 5) / 10;
        USDT.transfer(oneAddress, percent80);
        USDT.transfer(twoAddress, value - percent80);
        emit Deposit(msg.sender, value);
    }

    function withdrawToken(IERC20 token, uint256 _amount) external onlyOwner {
        token.transfer(msg.sender, _amount);
    }
}