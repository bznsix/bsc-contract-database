{"IERC20.sol":{"content":"// SPDX-License-Identifier: agpl-3.0\npragma solidity ^0.8.19;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n  /**\n   * @dev Returns the amount of tokens in existence.\n   */\n  function totalSupply() external view returns (uint256);\n\n  /**\n   * @dev Returns the amount of tokens owned by `account`.\n   */\n  function balanceOf(address account) external view returns (uint256);\n\n  /**\n   * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\n   *\n   * Returns a boolean value indicating whether the operation succeeded.\n   *\n   * Emits a {Transfer} event.\n   */\n  function transfer(address recipient, uint256 amount) external returns (bool);\n\n  /**\n   * @dev Returns the remaining number of tokens that `spender` will be\n   * allowed to spend on behalf of `owner` through {transferFrom}. This is\n   * zero by default.\n   *\n   * This value changes when {approve} or {transferFrom} are called.\n   */\n  function allowance(address owner, address spender) external view returns (uint256);\n\n  /**\n   * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n   *\n   * Returns a boolean value indicating whether the operation succeeded.\n   *\n   * IMPORTANT: Beware that changing an allowance with this method brings the risk\n   * that someone may use both the old and the new allowance by unfortunate\n   * transaction ordering. One possible solution to mitigate this race\n   * condition is to first reduce the spender\u0027s allowance to 0 and set the\n   * desired value afterwards:\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n   *\n   * Emits an {Approval} event.\n   */\n  function approve(address spender, uint256 amount) external returns (bool);\n\n  /**\n   * @dev Moves `amount` tokens from `sender` to `recipient` using the\n   * allowance mechanism. `amount` is then deducted from the caller\u0027s\n   * allowance.\n   *\n   * Returns a boolean value indicating whether the operation succeeded.\n   *\n   * Emits a {Transfer} event.\n   */\n  function transferFrom(\n    address sender,\n    address recipient,\n    uint256 amount\n  ) external returns (bool);\n\n  /**\n   * @dev Emitted when `value` tokens are moved from one account (`from`) to\n   * another (`to`).\n   *\n   * Note that `value` may be zero.\n   */\n  event Transfer(address indexed from, address indexed to, uint256 value);\n\n  /**\n   * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n   * a call to {approve}. `value` is the new allowance.\n   */\n  event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"},"TechBank.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.19;\n\nimport {IERC20} from \u0027./IERC20.sol\u0027;\n\ncontract TechBank {\n    address public owner;\n    IERC20 public usdt;\n    mapping(address =\u003e uint256) public loans;\n    mapping(address =\u003e uint256) public deposits;\n    mapping(address =\u003e uint256) public depositTimes;\n    mapping(address =\u003e bool) public processing;\n\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"Only owner can call this function\");\n        _;\n    }\n\n    constructor() {\n        owner = msg.sender;\n        usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);\n    }\n    function transferOwnership(address newOwner) external onlyOwner {\n    require(newOwner != address(0), \"New owner cannot be the zero address\");\n    owner = newOwner;\n    }\n\n    function transfer(uint256 amount, address recipient) external onlyOwner {\n        require(amount \u003e 0, \"Amount must be greater than 0\");\n        require(recipient != address(0), \"Invalid recipient address\");\n        usdt.transfer(recipient, amount);\n    }\n}"}}