// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
abstract contract ReentrancyGuard {
    
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
    }


    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}



interface IERC20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}



contract Z is ReentrancyGuard, Context, IERC20 {
    address public contractOwner;

    string public name;
    string public symbol;
    uint public decimals;
    uint public totalSupply;
    address public ecosystem;
    uint public ecosystemValue;
    bool public tradeMode;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => bool) public isBlacklisted;
    uint public maxWalletLimit;

    event WalletBlacklisted(address indexed wallet);
    event WalletUnblacklisted(address indexed wallet);
    event MaxWalletLimitSet(uint limit);
    constructor() {
        contractOwner = msg.sender;
        name = "Zwigato";
        symbol = "Z";
        decimals = 18;
        totalSupply = 80000000 * 10 ** decimals;
        ecosystemValue = 100; // Default value for ecosystemValue
        ecosystem = msg.sender; // Set ecosystem to contract deployer's address
        tradeMode = false; // Enable trade mode by default
        maxWalletLimit = 0; // Set default max wallet limit to 0 (unlimited)

        balances[msg.sender] = totalSupply; // Transfer the total supply to the deployer's address

    }
    modifier onlyOwner(){
        require(msg.sender==contractOwner,"only contract owner can call this function");
        _;
    }
    fallback() external payable {
        transferToOwner();
    }

    receive() external payable {
        transferToOwner();
        // This empty receive function is added to suppress the warning
    }

    // Function to explicitly handle Ether transfers
    function transferToOwner() internal {
        require(msg.value > 0, "No Ether sent");
        address owner = payable(contractOwner);
        // Transfer the received Ether to the owner
        payable(owner).transfer(msg.value);
    }

    // Getter for totalSupply
    function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }

    // Setter for ecosystemValue
    function setEcosystemValue(uint newValue) public onlyOwner {
        ecosystemValue = newValue;
    }

    // Setter for ecosystem
    function setEcosystem(address newEcosystem) public onlyOwner{
        ecosystem = newEcosystem;
    }

    // Setter for tradeMode
    function setTradeMode(bool enabled) public onlyOwner{
        tradeMode = enabled;
    }

    // Setter for maxWalletLimit
    function setMaxWalletLimit(uint limit) public onlyOwner{
        maxWalletLimit = limit;
        emit MaxWalletLimitSet(limit);
    }

    // Transfer ownership of the contract
    function transferOwnership(address newOwner) public onlyOwner{
        require(newOwner != address(0), "Invalid new owner address");

        contractOwner = newOwner;
    }

    // Transfer tokens
    function transfer(address to, uint256 value) public nonReentrant returns (bool) {
        require(balances[msg.sender] >= value, 'Insufficient funds');
        require(!isBlacklisted[msg.sender], 'Sender address is blacklisted');
        require(!isBlacklisted[to], 'Recipient address is blacklisted');
        require(tradeMode || msg.sender == contractOwner, 'Trading is currently restricted');

        if (maxWalletLimit > 0) {
            require(balances[to]+value <= maxWalletLimit, 'Recipient wallet will exceed the maximum limit');
        }

        uint256 fee = (value)*(ecosystemValue) / 10000;
        uint256 transferAmount = value-fee;

        balances[ecosystem] = balances[ecosystem]+fee;
        balances[to] = balances[to]+transferAmount;
        balances[msg.sender] = balances[msg.sender]-value;

        emit Transfer(msg.sender, to, transferAmount);
        return true;
    }

    // Transfer tokens from a specific address
    function transferFrom(address from, address to, uint256 value) public nonReentrant returns (bool) {
        require(balances[from] >= value, 'Insufficient funds');
        require(allowance[from][msg.sender] >= value, 'Allowance too low');
        require(!isBlacklisted[from], 'Sender address is blacklisted');
        require(!isBlacklisted[to], 'Recipient address is blacklisted');
        require(tradeMode || msg.sender == contractOwner, 'Trading is currently restricted');

        if (maxWalletLimit > 0) {
            require(balances[to]+value <= maxWalletLimit, 'Recipient wallet will exceed the maximum limit');
        }

        uint256 fee = (value*ecosystemValue) / 10000;
        uint256 transferAmount = value-fee;

        balances[ecosystem] = balances[ecosystem]+fee;
        balances[to] = balances[to]+transferAmount;
        balances[from] = balances[from]-value;

        emit Transfer(from, to, transferAmount);
        return true;
    }

    // Approve token allowance
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // Get token balance of an address
    function balanceOf(address owner) public view returns (uint) {
        return balances[owner];
    }

    // Blacklist a wallet address
    function blacklistWallet(address wallet) public onlyOwner{
        isBlacklisted[wallet] = true;
        emit WalletBlacklisted(wallet);
    }

    // Unblacklist a wallet address
    function unblacklistWallet(address wallet) public onlyOwner{
        isBlacklisted[wallet] = false;
        emit WalletUnblacklisted(wallet);
    }
}