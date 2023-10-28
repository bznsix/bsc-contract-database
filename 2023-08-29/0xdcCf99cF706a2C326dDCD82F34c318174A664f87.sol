{"CentToken.sol":{"content":"/*\r\n   ____ _____ _   _ _____   _____ ___  _  _______ _   _ \r\n  / ___| ____| \\ | |_   _| |_   _/ _ \\| |/ / ____| \\ | |\r\n | |   |  _| |  \\| | | |     | || | | | \u0027 /|  _| |  \\| |\r\n | |___| |___| |\\  | | |     | || |_| | . \\| |___| |\\  |\r\n  \\____|_____|_| \\_| |_|     |_| \\___/|_|\\_\\_____|_| \\_|\r\n                                                                                                               \r\n*/\r\n\r\n// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.18;\r\n\r\n// Interface for BEP20 Token Standard\r\ninterface IBEP20 {\r\n    // Standard functions\r\n    function totalSupply() external view returns (uint256);\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    // Additional features\r\n    function mint(address account, uint256 amount) external returns (bool);\r\n    function burn(uint256 amount) external;\r\n    function pause() external;\r\n    function unpause() external;\r\n    function lock(address account, uint256 amount, uint256 until) external;\r\n    function unlock(address account) external;\r\n    function recoverTokens(address tokenAddress, uint256 amount) external returns (bool);\r\n\r\n    // Events\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n    event Mint(address indexed account, uint256 amount);\r\n    event Burn(uint256 amount);\r\n    event PausingEnabled(bool enabled);\r\n    event Paused(address account);\r\n    event Unpaused(address account);\r\n    event Lock(address indexed account, uint256 amount, uint256 until);\r\n}\r\n\r\n// Cent Token contract implementing the BEP20 Token Standard\r\ncontract CentToken is IBEP20 {\r\n    string public name = \"Cent Token\";\r\n    string public symbol = \"CTPAY\";\r\n    uint8 public decimals = 18;\r\n    uint256 public totalSupply = 100000000 * 10**uint256(decimals);\r\n    uint256 public ownerLockAmount = totalSupply / 5; // 20% of total supply locked for the owner\r\n    address public owner = msg.sender;\r\n\r\n    mapping(address =\u003e uint256) public balanceOf;\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) public allowance;\r\n    mapping(address =\u003e bool) public isLocked;\r\n    mapping(address =\u003e uint256) public lockAmount;\r\n    mapping(address =\u003e uint256) public lockedUntil;\r\n\r\n    bool public mintingFinished;\r\n    bool public pausingEnabled;\r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner, \"Only owner can call this function\");\r\n        _;\r\n    }\r\n\r\n    modifier notLocked(address account) {\r\n        require(!isLocked[account], \"Account is locked\");\r\n        _;\r\n    }\r\n\r\n    modifier pausingNotEnabled() {\r\n        require(!pausingEnabled, \"Pausing is enabled\");\r\n        _;\r\n    }\r\n\r\n    modifier pausingEnabledOnly() {\r\n        require(pausingEnabled, \"Pausing is not enabled\");\r\n        _;\r\n    }\r\n\r\n    constructor() {\r\n        balanceOf[owner] = totalSupply - ownerLockAmount;\r\n        balanceOf[address(this)] = ownerLockAmount;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfer tokens from the sender\u0027s address to the recipient\u0027s address.\r\n     * @param to The recipient\u0027s address.\r\n     * @param value The amount of tokens to transfer.\r\n     * @return A boolean value indicating whether the transfer was successful or not.\r\n     */\r\n    function transfer(address to, uint256 value) external override notLocked(msg.sender) returns (bool) {\r\n        require(to != address(0), \"Invalid recipient\");\r\n        require(balanceOf[msg.sender] \u003e= value, \"Insufficient balance\");\r\n\r\n        balanceOf[msg.sender] -= value;\r\n        balanceOf[to] += value;\r\n\r\n        emit Transfer(msg.sender, to, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Approve the spender to spend the specified amount of tokens on behalf of the sender.\r\n     * @param spender The address allowed to spend tokens.\r\n     * @param value The amount of tokens approved for spending.\r\n     * @return A boolean value indicating whether the approval was successful or not.\r\n     */\r\n    function approve(address spender, uint256 value) external override notLocked(msg.sender) returns (bool) {\r\n        allowance[msg.sender][spender] = value;\r\n        emit Approval(msg.sender, spender, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfer tokens from the owner\u0027s address to the recipient\u0027s address on behalf of the owner.\r\n     * @param from The owner\u0027s address.\r\n     * @param to The recipient\u0027s address.\r\n     * @param value The amount of tokens to transfer.\r\n     * @return A boolean value indicating whether the transfer was successful or not.\r\n     */\r\n    function transferFrom(address from, address to, uint256 value) external override notLocked(from) returns (bool) {\r\n        require(to != address(0), \"Invalid recipient\");\r\n        require(balanceOf[from] \u003e= value, \"Insufficient balance\");\r\n        require(allowance[from][msg.sender] \u003e= value, \"Insufficient allowance\");\r\n\r\n        balanceOf[from] -= value;\r\n        balanceOf[to] += value;\r\n        allowance[from][msg.sender] -= value;\r\n\r\n        emit Transfer(from, to, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Mint new tokens and add them to the specified account.\r\n     * @param account The account to receive the newly minted tokens.\r\n     * @param amount The amount of tokens to mint.\r\n     * @return A boolean value indicating whether the minting was successful or not.\r\n     */\r\n    function mint(address account, uint256 amount) external override onlyOwner pausingNotEnabled returns (bool) {\r\n        require(!mintingFinished, \"Minting is finished\");\r\n        require(account != address(0), \"Invalid account address\");\r\n        require(amount \u003e 0, \"Amount must be greater than zero\");\r\n\r\n        balanceOf[account] += amount;\r\n        totalSupply += amount;\r\n\r\n        emit Mint(account, amount);\r\n        emit Transfer(address(0), account, amount);\r\n\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Finish the minting process, preventing any further minting of tokens.\r\n     * @return A boolean value indicating whether finishing the minting was successful or not.\r\n     */\r\n    function finishMinting() external onlyOwner pausingNotEnabled returns (bool) {\r\n        require(!mintingFinished, \"Minting already finished\");\r\n\r\n        mintingFinished = true;\r\n\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Burn tokens from the sender\u0027s address.\r\n     * @param amount The amount of tokens to burn.\r\n     */\r\n    function burn(uint256 amount) external override notLocked(msg.sender) {\r\n        require(balanceOf[msg.sender] \u003e= amount, \"Insufficient balance\");\r\n\r\n        balanceOf[msg.sender] -= amount;\r\n        totalSupply -= amount;\r\n\r\n        emit Burn(amount);\r\n        emit Transfer(msg.sender, address(0), amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Pause token transfers.\r\n     */\r\n    function pause() external override onlyOwner pausingNotEnabled {\r\n        pausingEnabled = true;\r\n\r\n        emit PausingEnabled(true);\r\n        emit Paused(msg.sender);\r\n    }\r\n\r\n    /**\r\n     * @dev Unpause token transfers.\r\n     */\r\n    function unpause() external override onlyOwner pausingEnabledOnly {\r\n        pausingEnabled = false;\r\n\r\n        emit PausingEnabled(false);\r\n        emit Unpaused(msg.sender);\r\n    }\r\n\r\n    /**\r\n     * @dev Lock tokens of the specified account for a specified duration.\r\n     * @param account The address whose tokens will be locked.\r\n     * @param amount The amount of tokens to lock.\r\n     * @param until The timestamp until which the tokens will be locked.\r\n     */\r\n    function lock(address account, uint256 amount, uint256 until) external override onlyOwner pausingNotEnabled {\r\n        require(account != address(0), \"Invalid account address\");\r\n        require(amount \u003e 0, \"Amount must be greater than zero\");\r\n\r\n        isLocked[account] = true;\r\n        lockAmount[account] = amount;\r\n        lockedUntil[account] = until;\r\n\r\n        emit Lock(account, amount, until);\r\n    }\r\n\r\n    /**\r\n     * @dev Unlock tokens of the specified account.\r\n     * @param account The address whose tokens will be unlocked.\r\n     */\r\n    function unlock(address account) external override onlyOwner pausingNotEnabled {\r\n        isLocked[account] = false;\r\n        lockAmount[account] = 0;\r\n        lockedUntil[account] = 0;\r\n    }\r\n\r\n    /**\r\n     * @dev Recover tokens mistakenly sent to the contract.\r\n     * @param tokenAddress The address of the token to recover.\r\n     * @param amount The amount of tokens to recover.\r\n     * @return A boolean value indicating whether the token recovery was successful or not.\r\n     */\r\n    function recoverTokens(address tokenAddress, uint256 amount) external override onlyOwner pausingNotEnabled returns (bool) {\r\n        require(tokenAddress != address(this), \"Cannot recover Cent Tokens\");\r\n        IBEP20 token = IBEP20(tokenAddress);\r\n        require(token.transfer(msg.sender, amount), \"Token transfer failed\");\r\n        return true;\r\n    }\r\n}"},"ICO.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.18;\r\n\r\nimport \"./CentToken.sol\";  // Import the CentToken contract\r\n\r\ncontract ICOToken {\r\n    CentToken public token;  // Use the imported CentToken contract\r\n    address public owner;\r\n    uint256 public icoStartDate;\r\n    uint256 public icoEndDate;\r\n    uint256 public icoTokenPrice = 44000; // 0.000044 BNB * 10^18 (decimals)\r\n    uint256 public minPurchase = 4400; // 0.0044 BNB * 10^18 (decimals)\r\n    uint256 public maxPurchase;\r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner, \"Only owner can call this function\");\r\n        _;\r\n    }\r\n\r\n    modifier icoActive() {\r\n        require(block.timestamp \u003e= icoStartDate \u0026\u0026 block.timestamp \u003c= icoEndDate, \"ICO is not active\");\r\n        _;\r\n    }\r\n\r\n    modifier icoEnded() {\r\n        require(block.timestamp \u003e icoEndDate, \"ICO has not ended yet\");\r\n        _;\r\n    }\r\n\r\n    constructor(address _tokenAddress) {\r\n        token = CentToken(_tokenAddress);  // Use the imported contract\r\n        owner = msg.sender;\r\n        icoStartDate = block.timestamp;\r\n        icoEndDate = 1662144000; // September 2, 2023, at 00:00:00 (UTC)\r\n        maxPurchase = token.balanceOf(address(this));\r\n    }\r\n\r\n    function buyTokens(uint256 amount) external payable icoActive {\r\n        require(msg.value \u003e= minPurchase, \"Minimum purchase not met\");\r\n        require(amount \u003c= maxPurchase, \"Exceeds maximum purchase\");\r\n        \r\n        uint256 requiredAmount = amount * icoTokenPrice;\r\n        require(msg.value \u003e= requiredAmount, \"Insufficient BNB sent\");\r\n\r\n        require(token.transfer(msg.sender, amount), \"Token transfer failed\");\r\n    }\r\n\r\n    function getTotalICO() external view returns (uint256) {\r\n        return maxPurchase;\r\n    }\r\n\r\n    function getSold() external view returns (uint256) {\r\n        return token.balanceOf(address(this)) - maxPurchase;\r\n    }\r\n\r\n    function getBalance() external view returns (uint256) {\r\n        return token.balanceOf(address(this));\r\n    }\r\n\r\n    function getICOStatus() external view returns (bool) {\r\n        return block.timestamp \u003e= icoStartDate \u0026\u0026 block.timestamp \u003c= icoEndDate;\r\n    }\r\n\r\n    function withdrawUnsoldTokens() external onlyOwner icoEnded {\r\n        uint256 unsoldTokens = token.balanceOf(address(this)) - maxPurchase;\r\n        require(unsoldTokens \u003e 0, \"No unsold tokens\");\r\n        \r\n        require(token.transfer(owner, unsoldTokens), \"Token transfer failed\");\r\n    }\r\n\r\n    function withdrawBNB() external onlyOwner icoEnded {\r\n        payable(owner).transfer(address(this).balance);\r\n    }\r\n}\r\n"}}