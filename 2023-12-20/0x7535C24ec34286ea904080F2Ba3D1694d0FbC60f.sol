// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IST20 {
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

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract test is Ownable {
    using SafeMath for uint256;
    IST20 public token;
    uint256 public rate;
    uint256 public weiRaised;
    uint256 public weiMaxPurchaseBnb;
    address payable private admin;
    IERC20 public usdtToken;
    address payable public marketingWallet; // Carteira de marketing

    string public FullStackDev;

    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    constructor(
        uint256 _rate,
        IST20 _token,
        uint256 _max,
        address _usdtTokenAddress,
        address payable _marketingWallet
    ) public {
        require(_rate > 0);
        require(_max > 0);
        require(_token != IST20(address(0)));
        require(_usdtTokenAddress != address(0));
        require(_marketingWallet != address(0));

        FullStackDev = "https://t.me/Italo_Dev_Bsc";

        rate = _rate;
        token = _token;
        weiMaxPurchaseBnb = _max;
        usdtToken = IERC20(_usdtTokenAddress);
        admin = msg.sender;
        marketingWallet = _marketingWallet; // Define o endereço da carteira de marketing
    }

    fallback() external payable {
        buyTokens(msg.sender); // Chama automaticamente a função buyTokens quando ETH é enviado
    }

    receive() external payable {
        buyTokens(msg.sender); // Chama automaticamente a função buyTokens quando ETH é enviado
    }

    function buyTokens(address _beneficiary) public payable {
        require(msg.value > 0, "BNB amount must be greater than zero");

        uint256 maxBnbAmount = maxBnb(_beneficiary);
        uint256 weiAmount = msg.value > maxBnbAmount ? maxBnbAmount : msg.value;
        weiAmount = _preValidatePurchase(_beneficiary, weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount);

        weiRaised = weiRaised.add(weiAmount);
        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

        if (msg.value > weiAmount) {
            uint256 refundAmount = msg.value.sub(weiAmount);
            msg.sender.transfer(refundAmount);
        }

        // Direciona os BNBs para a carteira de marketing
        marketingWallet.transfer(weiAmount);
    }


    function buyTokensWithUSDT(address _beneficiary, uint256 _usdtAmount)
        external
    {
        require(_usdtAmount > 0, "USDT amount must be greater than zero");

        uint256 tokens = _usdtAmount.mul(rate).div(1e9); 

        _processPurchase(_beneficiary, tokens); // pagamento dos tokens pro usuario
        emit TokenPurchase(msg.sender, _beneficiary, _usdtAmount, tokens);
        if (tokens < _usdtAmount) {
            uint256 refundAmount = _usdtAmount.sub(tokens);
            require(
                usdtToken.transferFrom(msg.sender, address(this), refundAmount),
                "USDT transfer failed"
            );
        }
        

        usdtToken.transferFrom(msg.sender, address(marketingWallet), _usdtAmount); // to mandando _usdtAmount se a logica for usuario mandou 100 dol voce recebe 100 dol
    }

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
        internal
        view
        returns (uint256)
    {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_weiAmount > 0, "Wei amount must be greater than zero");

        if (msg.value > 0) {
            // Payment in BNB
            uint256 tokenAmount = _getTokenAmount(_weiAmount);
            uint256 curBalance = token.balanceOf(address(this));
            if (tokenAmount > curBalance) {
                return curBalance.mul(1e9).div(rate);
            }
        } else {
            // Payment in USDT
            uint256 usdtAmount = _weiAmount;
            uint256 tokens = usdtAmount.mul(rate).div(1e9);
            uint256 curBalance = token.balanceOf(address(this));
            if (tokens > curBalance) {
                return curBalance.mul(rate).div(1e9);
            }
        }

        return _weiAmount;
    }

    function _deliverTokens(address _beneficiary, uint256 _tokenAmount)
        internal
    {
        token.transfer(_beneficiary, _tokenAmount);
    }

    function _processPurchase(address _beneficiary, uint256 _tokenAmount)
        internal
    {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    function _getTokenAmount(uint256 _weiAmount)
        internal
        view
        returns (uint256)
    {
        return _weiAmount.mul(rate).div(1e9);
    }

    function setPresaleRate(uint256 _rate) external onlyOwner {
        rate = _rate;
    }

    function maxBnb(address _beneficiary) public view returns (uint256) {
    }

    function withdrawCoins() external onlyOwner {
        admin.transfer(address(this).balance);
    }

    function withdrawTokens(address tokenAddress, uint256 tokens)
        external
        onlyOwner
    {
        IST20(tokenAddress).transfer(admin, tokens);
    }
}