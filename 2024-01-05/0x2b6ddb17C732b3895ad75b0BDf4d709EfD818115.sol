/**
 *Submitted for verification at BscScan.com on 2023-12-31
 */

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

interface ERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

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

abstract contract Context {
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ICOOld {
    function totalTokens(address) external returns (uint256);

    function totalWithdrawnTokens(address) external returns (uint256);

    function codes(string memory) external returns (address);

    function referralCodes(address) external returns (string memory);

    function referals(address) external returns (address);
}

contract ICO is Context, ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    address public oldICO = 0xC47f1411d7F0cf9A62A4cA1b483e1d352a55ce3e;

    address public usd;
    address public token;
    address public admin;
    address public settlementWallet;
    uint256 public sendTokenPercentage = 1; // 100/4;
    uint256 public sendVestingTokenPercentage = 1; // 100/4;
    uint256 public tokenPrice = 0.8 * 10 ** 18; // 0.8 USD

    mapping(address => uint256) public totalTokens;
    mapping(address => uint256) public totalWithdrawnTokens;
    mapping(string => address) public codes;
    mapping(address => string) public referralCodes;
    mapping(address => address) public referals;

    uint256 public totalTokensSold = 0;

    uint256 public minUSD = 0 * 10 ** 18;
    uint256 public maxUSD = 50000 * 10 ** 18;

    bool public ICOOngoing = true;

    mapping(uint8 => uint256) public referalPercentage;

    event Purchase(
        address indexed buyer,
        uint256 amount,
        uint256 onVesting,
        uint256 valueInPurchaseCurrency,
        string currency
    );

    event Refferal(
        address _address,
        address _from,
        uint256 amount,
        uint256 percentage
    );

    constructor(address _usd, address _token, address _settlementWallet) {
        admin = _msgSender();
        usd = _usd;
        token = _token;
        settlementWallet = _settlementWallet;
        codes["IFX2023"] = _settlementWallet;
        referalPercentage[0] = 30;
        referalPercentage[1] = 15;
        referalPercentage[2] = 10;
        referalPercentage[3] = 5;
        referalPercentage[4] = 5;
    }

    function copyData(address[] memory _buyers) public returns (bool) {
        for (uint256 index = 0; index < _buyers.length; index++) {
            totalTokens[_buyers[index]] = ICOOld(oldICO).totalTokens(
                _buyers[index]
            );
            totalWithdrawnTokens[_buyers[index]] = ICOOld(oldICO)
                .totalWithdrawnTokens(_buyers[index]);
            referralCodes[_buyers[index]] = ICOOld(oldICO).referralCodes(
                _buyers[index]
            );
            referals[_buyers[index]] = ICOOld(oldICO).referals(_buyers[index]);
            codes[referralCodes[_buyers[index]]] = referals[_buyers[index]];
        }
        return true;
    }

    function buyToken(
        uint256 _amount,
        string memory _code,
        string memory _refferalCode
    ) public virtual nonReentrant returns (bool) {
        uint256 balance = ERC20(usd).balanceOf(_msgSender());
        uint256 allowance = ERC20(usd).allowance(_msgSender(), address(this));

        uint256 totalCostInUSDC = tokenPrice.mul(_amount.div(10 ** 8));
        uint256 tokenToSend = _amount.div(sendTokenPercentage);
        uint256 vestingToken = _amount.sub(tokenToSend);

        require(
            codes[_refferalCode] != address(0),
            "Error: use valid referral code"
        );
        require(ICOOngoing, "Error: ICO halted");
        require(
            totalCostInUSDC >= minUSD,
            "Error: BUDS token should be min 100."
        );
        require(
            totalCostInUSDC <= maxUSD,
            "Error: BUSD token should be max 50000."
        );
        require(balance >= totalCostInUSDC, "Error: insufficient USDC Balance");
        require(
            allowance >= totalCostInUSDC,
            "Error: allowance less than spending"
        );

        if (referals[_msgSender()] != address(0)) {
            require(
                referals[_msgSender()] == codes[_refferalCode],
                "Error: Please use same referral code which used for first purchase."
            );
        }

        ERC20(usd).transferFrom(
            _msgSender(),
            settlementWallet,
            totalCostInUSDC
        );
        ERC20(token).transfer(_msgSender(), tokenToSend);

        totalTokens[_msgSender()] = totalTokens[_msgSender()].add(_amount);
        totalWithdrawnTokens[_msgSender()] = totalWithdrawnTokens[_msgSender()]
            .add(tokenToSend);

        totalTokensSold = totalTokensSold.add(_amount);

        codes[_code] = _msgSender();
        referralCodes[_msgSender()] = _refferalCode;

        referals[_msgSender()] = codes[_refferalCode];

        sendReferralCodes(_msgSender(), _amount);

        emit Purchase(
            _msgSender(),
            tokenToSend,
            vestingToken,
            totalCostInUSDC,
            "USDC"
        );

        return true;
    }

    function sendReferralCodes(address _buyer, uint256 _amount) internal {
        uint8 iterator = 0;
        address _referral = referals[_buyer];
        while (iterator < 5) {
            uint256 tokenToSend = (_amount * referalPercentage[iterator]).div(
                1000
            );
            if (_referral != address(0) && _referral != _buyer) {
                ERC20(token).transfer(_referral, tokenToSend);
                emit Refferal(
                    _referral,
                    _buyer,
                    tokenToSend,
                    referalPercentage[iterator]
                );
                _referral = referals[_referral];
            }
            iterator++;
        }
    }

    function updateBuyWithTokenAddress(
        address newAddress
    ) public virtual onlyOwner {
        require(newAddress != address(0), "Error: address cannot be zero");
        usd = newAddress;
    }

    function updateTokenAddress(address newAddress) public virtual onlyOwner {
        require(newAddress != address(0), "Error: address cannot be zero");
        token = newAddress;
    }

    function updateSendTokenPercentage(
        uint256 _sendTokenPercentage
    ) public virtual onlyOwner {
        uint256 total = 100;
        sendTokenPercentage = total.div(_sendTokenPercentage);
    }

    function updateSettlementWallet(
        address newAddress
    ) public virtual onlyOwner {
        require(newAddress != address(0), "Error: not a valid address");
        settlementWallet = newAddress;
    }

    function resumeICO() public virtual onlyOwner {
        ICOOngoing = true;
    }

    function stopICO() public virtual onlyOwner {
        ICOOngoing = false;
    }

    function changeTokenPrice(uint256 price) public virtual onlyOwner {
        tokenPrice = price;
    }

    function regainUnusedToken(uint256 amount) public virtual onlyOwner {
        ERC20(token).transfer(owner(), amount);
    }

    function checkCanBuyToken(uint256 _amount) public view returns (bool) {
        uint256 balance = ERC20(usd).balanceOf(_msgSender());
        uint256 allowance = ERC20(usd).allowance(_msgSender(), address(this));

        uint256 totalCostInUSDC = tokenPrice.mul(_amount.div(10 ** 8));

        require(ICOOngoing, "Error: ICO halted");
        require(balance >= totalCostInUSDC, "Error: insufficient USDC Balance");
        require(
            allowance >= totalCostInUSDC,
            "Error: allowance less than spending"
        );

        return true;
    }

    function updateMinUSD(uint256 _minUSD) public virtual onlyOwner {
        minUSD = _minUSD;
    }

    function updateMaxUsdc(uint256 _maxUSD) public virtual onlyOwner {
        maxUSD = _maxUSD;
    }

    function sendPendingReferral(
        address[] memory _buyer,
        address[] memory _referral,
        uint256[] memory tokenToSend,
        uint256[] memory _referalPercentage
    ) public onlyOwner {
        for (uint256 index = 0; index < _buyer.length; index++) {
            ERC20(token).transfer(_referral[index], tokenToSend[index]);
            emit Refferal(
                _referral[index],
                _buyer[index],
                tokenToSend[index],
                _referalPercentage[index]
            );
        }
    }

    function changePercentage(
        uint8 _index,
        uint256 _percentage
    ) public onlyOwner {
        referalPercentage[_index] = _percentage;
    }
}