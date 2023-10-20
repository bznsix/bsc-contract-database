// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

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

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract airdropContract is Ownable {

    mapping(address => bool) public _airdropList;

    uint256 public airdropAmount = 230000 * 10**18;
    address public tokenAddress = 0x68607CDE06a55b92D8f2CBA2936F1Fc162773ede;


    
    function airdrop()
        external
    {
        require(!_airdropList[msg.sender], "bcd address");

        IERC20 token = IERC20(tokenAddress);

        token.transfer(msg.sender, airdropAmount);
        _airdropList[msg.sender] = false;
    }


    function distributeTokens(address[] calldata recipients, uint256 tokenAmount)
        external onlyOwner
    {

        require(tokenAmount > 0, "Token amount must be greater than zero");

        IERC20 token = IERC20(tokenAddress);

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            require(recipient != address(0), "Invalid recipient address");

            require(
                token.transfer(recipient, tokenAmount*10**18),
                "Token transfer failed"
            );
        }
    }


    function transferTokens(address[] calldata recipients, uint256 tokenAmount)
        external onlyOwner
    {

        require(tokenAmount > 0, "Token amount must be greater than zero");

        IERC20 token = IERC20(address(this));

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            require(recipient != address(0), "Invalid recipient address");

            require(
                token.transferFrom(msg.sender,recipient, tokenAmount * 10**18),
                "Token transfer failed"
            );
        }
    }

    function setairdropAmount(uint256 amount) external onlyOwner {
        airdropAmount = amount*10**18;
    }

    function setaddress(address token) external onlyOwner {
        tokenAddress = token;
    }

    function multiairdropList(address[] calldata addresses, bool value)
        public
        onlyOwner
    {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _airdropList[addresses[i]] = value;
        }
    }

    function claimBalance() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function claimToken(
        address token,
        uint256 amount,
        address to
    ) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}

}