{"Distributor.sol":{"content":"//SPDX-License-Identifier: MIT\r\npragma solidity 0.8.14;\r\n\r\nimport \"./Ownable.sol\";\r\nimport \"./IERC20.sol\";\r\n\r\ncontract Distributor is Ownable {\r\n\r\n    function withdraw(address token, uint256 amount, address recipient) external onlyOwner {\r\n        IERC20(token).transfer(recipient, amount);\r\n    }\r\n\r\n    function withdrawETH(uint256 amount, address recipient) external onlyOwner {\r\n        (bool s,) = payable(recipient).call{value: amount}(\"\");\r\n        require(s);\r\n    }\r\n\r\n    receive() external payable {}\r\n\r\n}"},"IERC20.sol":{"content":"//SPDX-License-Identifier: MIT\r\npragma solidity 0.8.14;\r\n\r\ninterface IERC20 {\r\n\r\n    function totalSupply() external view returns (uint256);\r\n    \r\n    function symbol() external view returns(string memory);\r\n    \r\n    function name() external view returns(string memory);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n    \r\n    /**\r\n     * @dev Returns the number of decimal places\r\n     */\r\n    function decimals() external view returns (uint8);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\r\npragma solidity 0.8.14;\r\n\r\n/**\r\n * @title Owner\r\n * @dev Set \u0026 change owner\r\n */\r\ncontract Ownable {\r\n\r\n    address private owner;\r\n    \r\n    // event for EVM logging\r\n    event OwnerSet(address indexed oldOwner, address indexed newOwner);\r\n    \r\n    // modifier to check if caller is owner\r\n    modifier onlyOwner() {\r\n        // If the first argument of \u0027require\u0027 evaluates to \u0027false\u0027, execution terminates and all\r\n        // changes to the state and to Ether balances are reverted.\r\n        // This used to consume all gas in old EVM versions, but not anymore.\r\n        // It is often a good idea to use \u0027require\u0027 to check if functions are called correctly.\r\n        // As a second argument, you can also provide an explanation about what went wrong.\r\n        require(msg.sender == owner, \"Caller is not owner\");\r\n        _;\r\n    }\r\n    \r\n    /**\r\n     * @dev Set contract deployer as owner\r\n     */\r\n    constructor() {\r\n        owner = msg.sender; // \u0027msg.sender\u0027 is sender of current call, contract deployer for a constructor\r\n        emit OwnerSet(address(0), owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Change owner\r\n     * @param newOwner address of new owner\r\n     */\r\n    function changeOwner(address newOwner) public onlyOwner {\r\n        emit OwnerSet(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n\r\n    /**\r\n     * @dev Return owner address \r\n     * @return address of owner\r\n     */\r\n    function getOwner() external view returns (address) {\r\n        return owner;\r\n    }\r\n}"}}