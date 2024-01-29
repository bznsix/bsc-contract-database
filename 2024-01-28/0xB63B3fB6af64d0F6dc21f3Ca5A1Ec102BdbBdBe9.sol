/**
 *Submitted for verification at testnet.bscscan.com on 2024-01-24
 */

/**
 *Submitted for verification at testnet.bscscan.com on 2024-01-24
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface Aggregator {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract Presale is Ownable, Pausable {
    IBEP20 public token;
    IBEP20 public usdt;

    uint256 public maxTokensToBuy;
    uint256 public totalTokensSold;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public totalUsdAmount;

    uint256 public currentStep;

    Aggregator public aggregatorInterface;

    event MaxTokensUpdated(
        uint256 prevValue,
        uint256 newValue,
        uint256 timestamp
    );

    constructor() {
        token = IBEP20(0x887De913513361038Ba133D14492b0e662d9AD5C);
        usdt = IBEP20(0x55d398326f99059fF775485246999027B3197955);
        aggregatorInterface = Aggregator(
            0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        );
        setRounds();
        maxTokensToBuy = 265000000 ether;
        startTime = block.timestamp;
        endTime = block.timestamp + 365 days;
    }

    struct round {
        uint256 amount;
        uint256 rate;
        uint256 soldToken;
    }

    round[] public rounds;

    function setRounds() private {
        rounds.push(
            round({amount: 265000000 ether, rate: 100000, soldToken: 0})
        );
    }

    function updateRounds(
        uint256 step,
        uint256 amount,
        uint256 rate
    ) external onlyOwner {
        require(step < rounds.length, "Invalid rounds Id");
        require(amount > 0 || rate > 0, "Invalid value");
        round storage setRound = rounds[step];
        if (amount > 0) setRound.amount = amount;
        if (rate > 0) setRound.rate = rate;
    }

    function changeMaxTokensToBuy(uint256 _maxTokensToBuy) external onlyOwner {
        require(_maxTokensToBuy > 0, "Zero max tokens to buy value");
        maxTokensToBuy = _maxTokensToBuy;
        emit MaxTokensUpdated(maxTokensToBuy, _maxTokensToBuy, block.timestamp);
    }

    function changeSaleStartTime(uint256 _startTime) external onlyOwner {
        require(block.timestamp <= _startTime, "Sale time in past");
        startTime = _startTime;
    }

    function changeSaleEndTime(uint256 _endTime) external onlyOwner {
        require(_endTime > startTime, "Invalid endTime");
        endTime = _endTime;
    }

    function pause() external onlyOwner returns (bool success) {
        _pause();
        return true;
    }

    function unpause() external onlyOwner returns (bool success) {
        _unpause();
        return true;
    }

    function withdrawBNB() public onlyOwner {
        require(address(this).balance > 0, "contract balance is 0");
        payable(owner()).transfer(address(this).balance);
    }

    function convertBNBtoUSD() public view returns (uint256) {
        uint256 balance = address(this).balance;
        uint256 convertedUSD = (getLatestPrice() * balance) / 1e8;
        uint256 totatConvertedUSD = convertedUSD + totalUsdAmount;
        return totatConvertedUSD;
    }

    function totalTokenInPresale() public view returns (uint256) {
        uint256 unsoldTokens = IBEP20(token).balanceOf(address(this));
        uint256 totaltokenInPresale = totalTokensSold + unsoldTokens;
        return totaltokenInPresale;
    }

    function withdrawTokens(address _token, uint256 amount) external onlyOwner {
        require(isContract(_token), "Invalid contract address");
        require(
            IBEP20(_token).balanceOf(address(this)) >= amount,
            "Insufficient tokens"
        );
        IBEP20(_token).transfer(_msgSender(), amount);
    }

    function isContract(address _addr) private view returns (bool iscontract) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    modifier checkSaleState(uint256 amount) {
        require(startTime <= block.timestamp, "ICO not start");
        require(endTime >= block.timestamp, "ICO end");
        require(amount > 0, "Invalid amount");
        _;
    }

    function buyWithUSDT(
        uint256 amount
    ) external checkSaleState(amount) whenNotPaused {
        uint256 numOfTokens = calculateToken(amount);
        require(numOfTokens <= maxTokensToBuy, "max tokens buy");
        uint256 ourAllowance = usdt.allowance(_msgSender(), address(this));
        require(amount <= ourAllowance, "Make sure to add enough allowance");
        usdt.transferFrom(_msgSender(), address(this), amount);
        token.transfer(_msgSender(), numOfTokens);
        rounds[currentStep].soldToken += numOfTokens;
        totalTokensSold += numOfTokens;
        totalUsdAmount += amount;
    }

    function buyWithBNB()
        external
        payable
        checkSaleState(msg.value)
        whenNotPaused
    {
        uint256 bnbToUsdt = (getLatestPrice() * msg.value) / 1e8;
        uint256 numOfTokens = calculateToken(bnbToUsdt);
        require(numOfTokens <= maxTokensToBuy, "max tokens buy");
        token.transfer(_msgSender(), numOfTokens);
        rounds[currentStep].soldToken += numOfTokens;
        totalTokensSold += numOfTokens;
    }

    function calculateToken(uint256 _usdtAmount) public view returns (uint256) {
        uint256 numOfTokens = _usdtAmount * rounds[currentStep].rate;
        return (numOfTokens / 100000);
    }

    function bnbBuyHelper(
        uint256 amount
    ) external view returns (uint256 numOfTokens) {
        uint256 bnbToUsdt = (getLatestPrice() * amount) / 1e8;
        numOfTokens = calculateToken(bnbToUsdt);
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = aggregatorInterface.latestRoundData();
        return uint256(price);
    }

    function getTokenBalance() public view returns (uint256 tokenBalance) {
        tokenBalance = token.balanceOf(address(this));
    }

    function getUsdtBalance() public view returns (uint256 usdtBalance) {
        usdtBalance = usdt.balanceOf(address(this));
    }

    function getBnbBalance() public view returns (uint256 BNB) {
        BNB = address(this).balance;
    }

    function totalRounds() public view returns (uint256 _rounds) {
        _rounds = rounds.length;
    }

    function getTokenPrice() public view returns (uint256) {
        return rounds[currentStep].rate;
    }

    receive() external payable {}
}