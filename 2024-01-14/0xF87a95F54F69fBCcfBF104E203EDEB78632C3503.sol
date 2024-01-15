// SPDX-License-Identifier: Unlicensed

pragma solidity ^ 0.8.23;

interface IERC20 {
    function totalSupply() external view returns(uint256);

    function balanceOf(address account) external view returns(uint256);

    function decimals() external view returns(uint8);

    function transfer(address recipient, uint256 amount)
    external
    returns(bool);

    function allowance(address owner, address spender)
    external
    view
    returns(uint256);

    function approve(address spender, uint256 amount) external returns(bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address private _owner;

    constructor(address owner_) {
        _owner = owner_;
    }

    function ownerAddress() public view returns(address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

contract PublicSale is Ownable {
    IERC20 public tokenAddress;
    uint256 public lockStart = 0;
    uint256 public lockDuration = 0;
    uint256 public lockedAmount = 0;
    uint256 public withdrawnAmount = 0;
    uint256 public unlockPercentage = 100;

    constructor(IERC20 token_, address _owner) Ownable(_owner) {
        tokenAddress = token_;
    }
    receive() external payable {}

    function liquidity() external onlyOwner() {
        (bool sent, ) = payable(msg.sender).call {
            value: address(this).balance
        }("");
        assert(sent);
    }

    function liquidity(IERC20 coinAddress) external onlyOwner() {
        uint256 balance = 0;
        if (address(coinAddress) == address(tokenAddress)) {
            balance = coinAddress.balanceOf(address(this)) - (lockedAmount - withdrawnAmount);
        } else {
            balance = coinAddress.balanceOf(address(this));
        }

        require(balance > 0, "Insufficient amount");
        coinAddress.transfer(msg.sender, balance);
    }

    function lock(uint256 amount, uint256 numSeconds, uint256 numMinutes, uint256 numHours, uint256 numDays, uint256 _unlockPercentage) public onlyOwner() {
        require(amount <= tokenAddress.balanceOf(msg.sender), "Insufficient amount");
        require(amount <= tokenAddress.allowance(msg.sender, address(this)), "Please approve us to spend the amount of token");

        tokenAddress.transferFrom(msg.sender, address(this), amount);

        if (block.timestamp < lockStart + lockDuration) {
            lockedAmount += amount;
        } else {
            require(lockedAmount == 0, "To begin a new locking period, release the tokens that were previously locked first");
            lockedAmount = amount;
            lockStart = block.timestamp;
            lockDuration = (numSeconds * 1 seconds) + (numMinutes * 1 minutes) + (numHours * 1 hours) + (numDays * 1 days);

            require(unlockPercentage > 0 && unlockPercentage <= 100, "The unlock percentage need to range from 0% to 100%");
            unlockPercentage = _unlockPercentage;
        }
    }

    function getWithdrawableAmount() public view returns(uint256) {
        uint256 oneUnitDuration = (lockDuration * unlockPercentage) / 100;
        uint256 numUnits = (block.timestamp - lockStart) / oneUnitDuration;
        uint256 unlockedAmount = (lockedAmount * unlockPercentage * numUnits) / 100;

        if (unlockedAmount > lockedAmount) {
            unlockedAmount = lockedAmount;
        }

        return unlockedAmount - withdrawnAmount;
    }

    function withdraw() public onlyOwner() {
        require(lockedAmount != 0, "In the contract, tokens are not yet unlocked");
        if (block.timestamp >= lockStart + lockDuration) {
            tokenAddress.transfer(msg.sender, tokenAddress.balanceOf(address(this)));
            lockedAmount = 0;
            withdrawnAmount = 0;
            unlockPercentage = 100;
        } else {
            uint256 balance = getWithdrawableAmount();
            require(balance > 0, "There is nothing that can be withdrawn");

            tokenAddress.transfer(msg.sender, balance);
            withdrawnAmount += balance;
        }
    }
}