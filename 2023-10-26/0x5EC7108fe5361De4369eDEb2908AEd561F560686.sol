// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}

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

contract FXST_Swap {
    using SafeMath for uint256;

    IERC20 public token;
    uint256 public tokensPerOLDFXST;
    address public swapOwner;

    IERC20 OLDFXST = IERC20(0xFF702E389ca1bC4A6D103e245956cFb0521Ae9c5);

    constructor(
        address _tokenAddress,
        address _owner,
        uint256 _tokensPerOLDFXST
    ) {
        token = IERC20(_tokenAddress);
        swapOwner = _owner;
        tokensPerOLDFXST = _tokensPerOLDFXST;
    }

    modifier onlyOwner() {
        require(msg.sender == swapOwner, "ONLY_OWNER_CAN_ACCESS_THIS_FUNCTION");
        _;
    }

    function updateRate(uint256 newTokensPerOLDFXST)
        public
        onlyOwner
    {
        tokensPerOLDFXST = newTokensPerOLDFXST;
    }

    function endSwap() public onlyOwner {
        uint256 contractTokenBalance = token.balanceOf(address(this));
        token.transfer(msg.sender, contractTokenBalance);
    }

    function swapWithOLDFXST(uint256 _OLDFXSTAmount) public {
        require(_OLDFXSTAmount > 0, "Invalid OLDFXST amount");
        require(
            OLDFXST.balanceOf(msg.sender) >= _OLDFXSTAmount,
            "Insufficient OLDFXST balance"
        );

        // Check allowance
        uint256 allowance = OLDFXST.allowance(msg.sender, address(this));
        require(allowance >= _OLDFXSTAmount, "Allowance is too low");

        uint256 tokenAmount = _OLDFXSTAmount;
        require(
            token.balanceOf(address(this)) >= tokenAmount,
            "Insufficient balance in contract"
        );

        // Transfer OLDFXST tokens from the user to the contract
        require(
            OLDFXST.transferFrom(msg.sender, swapOwner, _OLDFXSTAmount),
            "Failed to transfer OLDFXST tokens to swapOwner"
        );

        // Transfer new tokens to the user
        require(
            token.transfer(msg.sender, tokenAmount),
            "Failed to transfer new tokens to the user"
        );
    }

    function recoverTokens(address tokenToRecover) public onlyOwner {
        IERC20 tokenContract = IERC20(tokenToRecover);
        uint256 contractTokenBalance = tokenContract.balanceOf(address(this));
        require(contractTokenBalance > 0, "No tokens to recover");

        bool sent = tokenContract.transfer(msg.sender, contractTokenBalance);
        require(sent, "Failed to recover tokens");
    }
}