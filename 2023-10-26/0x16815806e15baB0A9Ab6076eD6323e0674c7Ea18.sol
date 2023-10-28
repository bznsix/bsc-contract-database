{"EnumerableSet.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\n// File @openzeppelin/contracts/utils/structs/EnumerableSet.sol@v4.0.0\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Library for managing\r\n * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive\r\n * types.\r\n *\r\n * Sets have the following properties:\r\n *\r\n * - Elements are added, removed, and checked for existence in constant time\r\n * (O(1)).\r\n * - Elements are enumerated in O(n). No guarantees are made on the ordering.\r\n *\r\n * ```\r\n * contract Example {\r\n *     // Add the library methods\r\n *     using EnumerableSet for EnumerableSet.AddressSet;\r\n *\r\n *     // Declare a set state variable\r\n *     EnumerableSet.AddressSet private mySet;\r\n * }\r\n * ```\r\n *\r\n * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)\r\n * and `uint256` (`UintSet`) are supported.\r\n */\r\nlibrary EnumerableSet {\r\n    // To implement this library for multiple types with as little code\r\n    // repetition as possible, we write it in terms of a generic Set type with\r\n    // bytes32 values.\r\n    // The Set implementation uses private functions, and user-facing\r\n    // implementations (such as AddressSet) are just wrappers around the\r\n    // underlying Set.\r\n    // This means that we can only create new EnumerableSets for types that fit\r\n    // in bytes32.\r\n\r\n    struct Set {\r\n        // Storage of set values\r\n        bytes32[] _values;\r\n\r\n        // Position of the value in the `values` array, plus 1 because index 0\r\n        // means a value is not in the set.\r\n        mapping (bytes32 =\u003e uint256) _indexes;\r\n    }\r\n\r\n    /**\r\n     * @dev Add a value to a set. O(1).\r\n     *\r\n     * Returns true if the value was added to the set, that is if it was not\r\n     * already present.\r\n     */\r\n    function _add(Set storage set, bytes32 value) private returns (bool) {\r\n        if (!_contains(set, value)) {\r\n            set._values.push(value);\r\n            // The value is stored at length-1, but we add 1 to all indexes\r\n            // and use 0 as a sentinel value\r\n            set._indexes[value] = set._values.length;\r\n            return true;\r\n        } else {\r\n            return false;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Removes a value from a set. O(1).\r\n     *\r\n     * Returns true if the value was removed from the set, that is if it was\r\n     * present.\r\n     */\r\n    function _remove(Set storage set, bytes32 value) private returns (bool) {\r\n        // We read and store the value\u0027s index to prevent multiple reads from the same storage slot\r\n        uint256 valueIndex = set._indexes[value];\r\n\r\n        if (valueIndex != 0) { // Equivalent to contains(set, value)\r\n            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in\r\n            // the array, and then remove the last element (sometimes called as \u0027swap and pop\u0027).\r\n            // This modifies the order of the array, as noted in {at}.\r\n\r\n            uint256 toDeleteIndex = valueIndex - 1;\r\n            uint256 lastIndex = set._values.length - 1;\r\n\r\n            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs\r\n            // so rarely, we still do the swap anyway to avoid the gas cost of adding an \u0027if\u0027 statement.\r\n\r\n            bytes32 lastvalue = set._values[lastIndex];\r\n\r\n            // Move the last value to the index where the value to delete is\r\n            set._values[toDeleteIndex] = lastvalue;\r\n            // Update the index for the moved value\r\n            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based\r\n\r\n            // Delete the slot where the moved value was stored\r\n            set._values.pop();\r\n\r\n            // Delete the index for the deleted slot\r\n            delete set._indexes[value];\r\n\r\n            return true;\r\n        } else {\r\n            return false;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the value is in the set. O(1).\r\n     */\r\n    function _contains(Set storage set, bytes32 value) private view returns (bool) {\r\n        return set._indexes[value] != 0;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of values on the set. O(1).\r\n     */\r\n    function _length(Set storage set) private view returns (uint256) {\r\n        return set._values.length;\r\n    }\r\n\r\n   /**\r\n    * @dev Returns the value stored at position `index` in the set. O(1).\r\n    *\r\n    * Note that there are no guarantees on the ordering of values inside the\r\n    * array, and it may change when more values are added or removed.\r\n    *\r\n    * Requirements:\r\n    *\r\n    * - `index` must be strictly less than {length}.\r\n    */\r\n    function _at(Set storage set, uint256 index) private view returns (bytes32) {\r\n        require(set._values.length \u003e index, \"EnumerableSet: index out of bounds\");\r\n        return set._values[index];\r\n    }\r\n\r\n    // Bytes32Set\r\n\r\n    struct Bytes32Set {\r\n        Set _inner;\r\n    }\r\n\r\n    /**\r\n     * @dev Add a value to a set. O(1).\r\n     *\r\n     * Returns true if the value was added to the set, that is if it was not\r\n     * already present.\r\n     */\r\n    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {\r\n        return _add(set._inner, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Removes a value from a set. O(1).\r\n     *\r\n     * Returns true if the value was removed from the set, that is if it was\r\n     * present.\r\n     */\r\n    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {\r\n        return _remove(set._inner, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the value is in the set. O(1).\r\n     */\r\n    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {\r\n        return _contains(set._inner, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of values in the set. O(1).\r\n     */\r\n    function length(Bytes32Set storage set) internal view returns (uint256) {\r\n        return _length(set._inner);\r\n    }\r\n\r\n   /**\r\n    * @dev Returns the value stored at position `index` in the set. O(1).\r\n    *\r\n    * Note that there are no guarantees on the ordering of values inside the\r\n    * array, and it may change when more values are added or removed.\r\n    *\r\n    * Requirements:\r\n    *\r\n    * - `index` must be strictly less than {length}.\r\n    */\r\n    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {\r\n        return _at(set._inner, index);\r\n    }\r\n\r\n    // AddressSet\r\n\r\n    struct AddressSet {\r\n        Set _inner;\r\n    }\r\n\r\n    /**\r\n     * @dev Add a value to a set. O(1).\r\n     *\r\n     * Returns true if the value was added to the set, that is if it was not\r\n     * already present.\r\n     */\r\n    function add(AddressSet storage set, address value) internal returns (bool) {\r\n        return _add(set._inner, bytes32(uint256(uint160(value))));\r\n    }\r\n\r\n    /**\r\n     * @dev Removes a value from a set. O(1).\r\n     *\r\n     * Returns true if the value was removed from the set, that is if it was\r\n     * present.\r\n     */\r\n    function remove(AddressSet storage set, address value) internal returns (bool) {\r\n        return _remove(set._inner, bytes32(uint256(uint160(value))));\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the value is in the set. O(1).\r\n     */\r\n    function contains(AddressSet storage set, address value) internal view returns (bool) {\r\n        return _contains(set._inner, bytes32(uint256(uint160(value))));\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of values in the set. O(1).\r\n     */\r\n    function length(AddressSet storage set) internal view returns (uint256) {\r\n        return _length(set._inner);\r\n    }\r\n\r\n   /**\r\n    * @dev Returns the value stored at position `index` in the set. O(1).\r\n    *\r\n    * Note that there are no guarantees on the ordering of values inside the\r\n    * array, and it may change when more values are added or removed.\r\n    *\r\n    * Requirements:\r\n    *\r\n    * - `index` must be strictly less than {length}.\r\n    */\r\n    function at(AddressSet storage set, uint256 index) internal view returns (address) {\r\n        return address(uint160(uint256(_at(set._inner, index))));\r\n    }\r\n\r\n\r\n    // UintSet\r\n\r\n    struct UintSet {\r\n        Set _inner;\r\n    }\r\n\r\n    /**\r\n     * @dev Add a value to a set. O(1).\r\n     *\r\n     * Returns true if the value was added to the set, that is if it was not\r\n     * already present.\r\n     */\r\n    function add(UintSet storage set, uint256 value) internal returns (bool) {\r\n        return _add(set._inner, bytes32(value));\r\n    }\r\n\r\n    /**\r\n     * @dev Removes a value from a set. O(1).\r\n     *\r\n     * Returns true if the value was removed from the set, that is if it was\r\n     * present.\r\n     */\r\n    function remove(UintSet storage set, uint256 value) internal returns (bool) {\r\n        return _remove(set._inner, bytes32(value));\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the value is in the set. O(1).\r\n     */\r\n    function contains(UintSet storage set, uint256 value) internal view returns (bool) {\r\n        return _contains(set._inner, bytes32(value));\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of values on the set. O(1).\r\n     */\r\n    function length(UintSet storage set) internal view returns (uint256) {\r\n        return _length(set._inner);\r\n    }\r\n\r\n   /**\r\n    * @dev Returns the value stored at position `index` in the set. O(1).\r\n    *\r\n    * Note that there are no guarantees on the ordering of values inside the\r\n    * array, and it may change when more values are added or removed.\r\n    *\r\n    * Requirements:\r\n    *\r\n    * - `index` must be strictly less than {length}.\r\n    */\r\n    function at(UintSet storage set, uint256 index) internal view returns (uint256) {\r\n        return uint256(_at(set._inner, index));\r\n    }\r\n}\r\n"},"IERC20.sol":{"content":"pragma solidity \u003e=0.5.0;\n\ninterface IERC20 {\n    event Approval(address indexed owner, address indexed spender, uint value);\n    event Transfer(address indexed from, address indexed to, uint value);\n\n    function decimals() external view returns (uint8);\n    function totalSupply() external view returns (uint);\n    function balanceOf(address owner) external view returns (uint);\n    function allowance(address owner, address spender) external view returns (uint);\n\n    function approve(address spender, uint value) external returns (bool);\n    function transfer(address to, uint value) external returns (bool);\n    function transferFrom(address from, address to, uint value) external returns (bool);\n}"},"Presale01.sol":{"content":"// SPDX-License-Identifier: UNLICENSED\r\n// ALL RIGHTS RESERVED\r\n// Unicrypt by SDDTech reserves all rights on this code. You may NOT copy these contracts.\r\n\r\n/**\r\n  Allows a decentralised presale to take place, and on success creates an AMM pair and locks liquidity on Unicrypt.\r\n  B_TOKEN, or base token, is the token the presale attempts to raise. (Usally ETH).\r\n  S_TOKEN, or sale token, is the token being sold, which investors buy with the base token.\r\n  If the base currency is set to the WETH9 address, the presale is in ETH.\r\n  Otherwise it is for an ERC20 token - such as DAI, USDC, WBTC etc.\r\n  For the Base token - It is advised to only use tokens such as ETH (WETH), DAI, USDC or tokens that have no rebasing, or complex fee on transfers. 1 token should ideally always be 1 token.\r\n  Token withdrawls are done on a percent of total contribution basis (opposed to via a hardcoded \u0027amount\u0027). This allows \r\n  fee on transfer, rebasing, or any magically changing balances to still work for the Sale token.\r\n*/\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./TransferHelper.sol\";\r\nimport \"./EnumerableSet.sol\";\r\nimport \"./ReentrancyGuard.sol\";\r\nimport \"./IERC20.sol\";\r\n\r\ninterface IUniswapV2Factory {\r\n    function getPair(address tokenA, address tokenB) external view returns (address pair);\r\n    function createPair(address tokenA, address tokenB) external returns (address pair);\r\n}\r\n\r\ninterface IPresaleLockForwarder {\r\n    function lockLiquidity (IERC20 _baseToken, IERC20 _saleToken, uint256 _baseAmount, uint256 _saleAmount, uint256 _unlock_date, address payable _withdrawer) external;\r\n    function uniswapPairIsInitialised (address _token0, address _token1) external view returns (bool);\r\n}\r\n\r\ninterface IWETH {\r\n    function deposit() external payable;\r\n    function transfer(address to, uint value) external returns (bool);\r\n    function withdraw(uint) external;\r\n}\r\n\r\ninterface IPresaleSettings {\r\n    function getMaxPresaleLength () external view returns (uint256);\r\n    function getRound1Length () external view returns (uint256);\r\n    function getRound0Offset () external view returns (uint256);\r\n    function userHoldsSufficientRound1Token (address _user) external view returns (bool);\r\n    function referrerIsValid(address _referrer) external view returns (bool);\r\n    function getBaseFee () external view returns (uint256);\r\n    function getTokenFee () external view returns (uint256);\r\n    function getEthAddress () external view returns (address payable);\r\n    function getNonEthAddress () external view returns (address payable);\r\n    function getTokenAddress () external view returns (address payable);\r\n    function getReferralFee () external view returns (uint256);\r\n    function getEthCreationFee () external view returns (uint256);\r\n    function getUNCLInfo () external view returns (address, uint256, address);\r\n}\r\n\r\ncontract Presale01 is ReentrancyGuard {\r\n  using EnumerableSet for EnumerableSet.AddressSet;\r\n  \r\n  /// @notice Presale Contract Version, used to choose the correct ABI to decode the contract\r\n  uint16 public CONTRACT_VERSION = 5;\r\n  \r\n  struct PresaleInfo {\r\n    IERC20 S_TOKEN; // sale token\r\n    IERC20 B_TOKEN; // base token // usually WETH (ETH)\r\n    uint256 TOKEN_PRICE; // 1 base token = ? s_tokens, fixed price\r\n    uint256 MAX_SPEND_PER_BUYER; // maximum base token BUY amount per account\r\n    uint256 AMOUNT; // the amount of presale tokens up for presale\r\n    uint256 HARDCAP;\r\n    uint256 SOFTCAP;\r\n    uint256 LIQUIDITY_PERCENT; // divided by 1000\r\n    uint256 LISTING_RATE; // fixed rate at which the token will list on uniswap\r\n    uint256 START_BLOCK;\r\n    uint256 END_BLOCK;\r\n    uint256 LOCK_PERIOD; // unix timestamp -\u003e e.g. 2 weeks\r\n  }\r\n\r\n  struct PresaleInfo2 {\r\n    address payable PRESALE_OWNER;\r\n    bool PRESALE_IN_ETH; // if this flag is true the presale is raising ETH, otherwise an ERC20 token such as DAI\r\n    uint16 COUNTRY_CODE;\r\n    uint128 UNCL_MAX_PARTICIPANTS; // max number of UNCL reserve allocation participants\r\n    uint128 UNCL_PARTICIPANTS; // number of uncl reserve allocation participants\r\n  }\r\n  \r\n  struct PresaleFeeInfo {\r\n    uint256 UNICRYPT_BASE_FEE; // divided by 1000\r\n    uint256 UNICRYPT_TOKEN_FEE; // divided by 1000\r\n    uint256 REFERRAL_FEE; // divided by 1000\r\n    address payable REFERRAL_FEE_ADDRESS; // if this is not address(0), there is a valid referral\r\n  }\r\n  \r\n  struct PresaleStatus {\r\n    bool WHITELIST_ONLY; // if set to true only whitelisted members may participate\r\n    bool LP_GENERATION_COMPLETE; // final flag required to end a presale and enable withdrawls\r\n    bool FORCE_FAILED; // set this flag to force fail the presale\r\n    uint256 TOTAL_BASE_COLLECTED; // total base currency raised (usually ETH)\r\n    uint256 TOTAL_TOKENS_SOLD; // total presale tokens sold\r\n    uint256 TOTAL_TOKENS_WITHDRAWN; // total tokens withdrawn post successful presale\r\n    uint256 TOTAL_BASE_WITHDRAWN; // total base tokens withdrawn on presale failure\r\n    uint256 ROUND1_LENGTH; // in blocks\r\n    uint256 ROUND_0_START;\r\n    uint256 NUM_BUYERS; // number of unique participants\r\n  }\r\n\r\n  struct BuyerInfo {\r\n    uint256 baseDeposited; // total base token (usually ETH) deposited by user, can be withdrawn on presale failure\r\n    uint256 tokensOwed; // num presale tokens a user is owed, can be withdrawn on presale success\r\n    uint256 unclOwed; // num uncl owed if user used UNCL for pre-allocation\r\n  }\r\n  \r\n  PresaleInfo public PRESALE_INFO;\r\n  PresaleInfo2 public PRESALE_INFO_2;\r\n  PresaleFeeInfo public PRESALE_FEE_INFO;\r\n  PresaleStatus public STATUS;\r\n  address public PRESALE_GENERATOR;\r\n  IPresaleLockForwarder public PRESALE_LOCK_FORWARDER;\r\n  IPresaleSettings public PRESALE_SETTINGS;\r\n  address UNICRYPT_DEV_ADDRESS;\r\n  IUniswapV2Factory public UNI_FACTORY;\r\n  IWETH public WETH;\r\n  mapping(address =\u003e BuyerInfo) public BUYERS;\r\n  EnumerableSet.AddressSet private WHITELIST;\r\n  uint public UNCL_AMOUNT_OVERRIDE;\r\n  uint public UNCL_BURN_ON_FAIL; // amount of UNCL to burn on failed presale\r\n\r\n  constructor(address _presaleGenerator, IPresaleSettings _presaleSettings, address _weth) {\r\n    PRESALE_GENERATOR = _presaleGenerator;\r\n    PRESALE_SETTINGS = _presaleSettings;\r\n    WETH = IWETH(_weth);\r\n    UNI_FACTORY = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);\r\n    PRESALE_LOCK_FORWARDER = IPresaleLockForwarder(0x46ae2bE0585e7f03d7A22411a76C0fd5CD24FCc3);\r\n    UNICRYPT_DEV_ADDRESS = 0xAA3d85aD9D128DFECb55424085754F6dFa643eb1;\r\n  }\r\n  \r\n  function init1 (\r\n    uint16 _countryCode,\r\n    uint256 _amount,\r\n    uint256 _tokenPrice,\r\n    uint256 _maxEthPerBuyer, \r\n    uint256 _hardcap, \r\n    uint256 _softcap,\r\n    uint256 _liquidityPercent,\r\n    uint256 _listingRate,\r\n    uint256 _roundZeroStart,\r\n    uint256 _startblock,\r\n    uint256 _endblock,\r\n    uint256 _lockPeriod\r\n    ) external {\r\n          \r\n      require(msg.sender == PRESALE_GENERATOR, \u0027FORBIDDEN\u0027);\r\n      PRESALE_INFO_2.COUNTRY_CODE = _countryCode;\r\n      PRESALE_INFO.AMOUNT = _amount;\r\n      PRESALE_INFO.TOKEN_PRICE = _tokenPrice;\r\n      PRESALE_INFO.MAX_SPEND_PER_BUYER = _maxEthPerBuyer;\r\n      PRESALE_INFO.HARDCAP = _hardcap;\r\n      PRESALE_INFO.SOFTCAP = _softcap;\r\n      PRESALE_INFO.LIQUIDITY_PERCENT = _liquidityPercent;\r\n      PRESALE_INFO.LISTING_RATE = _listingRate;\r\n      PRESALE_INFO.START_BLOCK = _startblock;\r\n      PRESALE_INFO.END_BLOCK = _endblock;\r\n      PRESALE_INFO.LOCK_PERIOD = _lockPeriod;\r\n      PRESALE_INFO_2.UNCL_MAX_PARTICIPANTS = uint128(_hardcap / _maxEthPerBuyer / 2);\r\n      if (_roundZeroStart \u003c block.number + PRESALE_SETTINGS.getRound0Offset()) {\r\n        STATUS.ROUND_0_START = block.number + PRESALE_SETTINGS.getRound0Offset();\r\n      } else {\r\n        STATUS.ROUND_0_START = _roundZeroStart;\r\n      }\r\n\r\n      if (PRESALE_INFO.START_BLOCK \u003c STATUS.ROUND_0_START) {\r\n        PRESALE_INFO.START_BLOCK = STATUS.ROUND_0_START + PRESALE_SETTINGS.getRound0Offset();\r\n        PRESALE_INFO.END_BLOCK = PRESALE_INFO.START_BLOCK + (_endblock - _startblock);\r\n      }\r\n  }\r\n  \r\n  function init2 (\r\n    address payable _presaleOwner,\r\n    IERC20 _baseToken,\r\n    IERC20 _presaleToken,\r\n    uint256 _unicryptBaseFee,\r\n    uint256 _unicryptTokenFee,\r\n    uint256 _referralFee,\r\n    address payable _referralAddress\r\n    ) external {\r\n          \r\n      require(msg.sender == PRESALE_GENERATOR, \u0027FORBIDDEN\u0027);\r\n      PRESALE_INFO_2.PRESALE_OWNER = _presaleOwner;\r\n      PRESALE_INFO_2.PRESALE_IN_ETH = address(_baseToken) == address(WETH);\r\n      PRESALE_INFO.S_TOKEN = _presaleToken;\r\n      PRESALE_INFO.B_TOKEN = _baseToken;\r\n      PRESALE_FEE_INFO.UNICRYPT_BASE_FEE = _unicryptBaseFee;\r\n      PRESALE_FEE_INFO.UNICRYPT_TOKEN_FEE = _unicryptTokenFee;\r\n      PRESALE_FEE_INFO.REFERRAL_FEE = _referralFee;\r\n      \r\n      PRESALE_FEE_INFO.REFERRAL_FEE_ADDRESS = _referralAddress;\r\n      STATUS.ROUND1_LENGTH = PRESALE_SETTINGS.getRound1Length();\r\n  }\r\n  \r\n  modifier onlyPresaleOwner() {\r\n    require(PRESALE_INFO_2.PRESALE_OWNER == msg.sender, \"NOT PRESALE OWNER\");\r\n    _;\r\n  }\r\n\r\n  function setUNCLAmount (uint _amount) external {\r\n    require(msg.sender == UNICRYPT_DEV_ADDRESS, \u0027NOT DEV\u0027);\r\n    UNCL_AMOUNT_OVERRIDE = _amount;\r\n  }\r\n\r\n  function getUNCLOverride () public view returns (address, uint256) {\r\n    (address unclAddress, uint256 unclAmount,) = PRESALE_SETTINGS.getUNCLInfo();\r\n    unclAmount = UNCL_AMOUNT_OVERRIDE == 0 ? unclAmount : UNCL_AMOUNT_OVERRIDE;\r\n    return (unclAddress, unclAmount);\r\n  }\r\n\r\n  function getElapsedSinceRound1 () external view returns (int) {\r\n    return int(block.number) - int(PRESALE_INFO.START_BLOCK);\r\n  }\r\n\r\n  function getElapsedSinceRound0 () external view returns (int) {\r\n    return int(block.number) - int(STATUS.ROUND_0_START);\r\n  }\r\n\r\n  function getInfo () public view returns (uint16, PresaleInfo memory, PresaleInfo2 memory, PresaleFeeInfo memory, PresaleStatus memory, uint256) {\r\n    return (CONTRACT_VERSION, PRESALE_INFO, PRESALE_INFO_2, PRESALE_FEE_INFO, STATUS, presaleStatus());\r\n  }\r\n  \r\n  function presaleStatus () public view returns (uint256) {\r\n    if (STATUS.LP_GENERATION_COMPLETE) {\r\n      return 4; // FINALIZED - withdraws enabled and markets created\r\n    }\r\n    if (STATUS.FORCE_FAILED) {\r\n      return 3; // FAILED - force fail\r\n    }\r\n    if ((block.number \u003e PRESALE_INFO.END_BLOCK) \u0026\u0026 (STATUS.TOTAL_BASE_COLLECTED \u003c PRESALE_INFO.SOFTCAP)) {\r\n      return 3; // FAILED - softcap not met by end block\r\n    }\r\n    if (STATUS.TOTAL_BASE_COLLECTED \u003e= PRESALE_INFO.HARDCAP) {\r\n      return 2; // SUCCESS - hardcap met\r\n    }\r\n    if ((block.number \u003e PRESALE_INFO.END_BLOCK) \u0026\u0026 (STATUS.TOTAL_BASE_COLLECTED \u003e= PRESALE_INFO.SOFTCAP)) {\r\n      return 2; // SUCCESS - endblock and soft cap reached\r\n    }\r\n    if ((block.number \u003e= PRESALE_INFO.START_BLOCK) \u0026\u0026 (block.number \u003c= PRESALE_INFO.END_BLOCK)) {\r\n      return 1; // ACTIVE - deposits enabled\r\n    }\r\n    return 0; // QUED - awaiting start block\r\n  }\r\n\r\n  function reserveAllocationWithUNCL () external payable nonReentrant {\r\n    require(presaleStatus() == 0, \u0027NOT QUED\u0027); // ACTIVE\r\n    require(block.number \u003e STATUS.ROUND_0_START, \u0027NOT YET\u0027);\r\n    BuyerInfo storage buyer = BUYERS[msg.sender];\r\n    require(buyer.unclOwed == 0, \u0027UNCL NOT ZERO\u0027);\r\n    require(PRESALE_INFO_2.UNCL_PARTICIPANTS \u003c PRESALE_INFO_2.UNCL_MAX_PARTICIPANTS, \u0027NO SLOT\u0027);\r\n    (address unclAddress, uint256 unclAmount) = getUNCLOverride();\r\n    TransferHelper.safeTransferFrom(unclAddress, msg.sender, address(this), unclAmount);\r\n    uint256 unclToBurn = unclAmount / 4;\r\n    UNCL_BURN_ON_FAIL += unclToBurn;\r\n    buyer.unclOwed = unclAmount - unclToBurn;\r\n    PRESALE_INFO_2.UNCL_PARTICIPANTS ++;\r\n  }\r\n\r\n  // accepts msg.value for eth or _amount for ERC20 tokens\r\n  function userDeposit (uint256 _amount) external payable nonReentrant {\r\n    if (presaleStatus() == 0) {\r\n      require(BUYERS[msg.sender].unclOwed \u003e 0, \u0027NOT RESERVED\u0027);\r\n    } else {\r\n      require(presaleStatus() == 1, \u0027NOT ACTIVE\u0027); // ACTIVE\r\n      bool userHoldsUnicryptTokens = PRESALE_SETTINGS.userHoldsSufficientRound1Token(msg.sender);\r\n      if (block.number \u003c PRESALE_INFO.START_BLOCK + STATUS.ROUND1_LENGTH) { // 276 blocks = 1 hour\r\n        require(userHoldsUnicryptTokens, \u0027INSUFFICENT ROUND 1 TOKEN BALANCE\u0027);\r\n      }\r\n    }\r\n    _userDeposit(_amount);\r\n  }\r\n  \r\n  // accepts msg.value for eth or _amount for ERC20 tokens\r\n  function _userDeposit (uint256 _amount) internal {\r\n    // DETERMINE amount_in\r\n    BuyerInfo storage buyer = BUYERS[msg.sender];\r\n    uint256 amount_in = PRESALE_INFO_2.PRESALE_IN_ETH ? msg.value : _amount;\r\n    uint256 allowance = PRESALE_INFO.MAX_SPEND_PER_BUYER - buyer.baseDeposited;\r\n    uint256 remaining;\r\n    if (presaleStatus() == 0) {\r\n      remaining = (PRESALE_INFO_2.UNCL_MAX_PARTICIPANTS * PRESALE_INFO.MAX_SPEND_PER_BUYER) - STATUS.TOTAL_BASE_COLLECTED;\r\n    } else {\r\n      remaining = PRESALE_INFO.HARDCAP - STATUS.TOTAL_BASE_COLLECTED;\r\n    }\r\n    allowance = allowance \u003e remaining ? remaining : allowance;\r\n    if (amount_in \u003e allowance) {\r\n      amount_in = allowance;\r\n    }\r\n\r\n    // UPDATE STORAGE\r\n    uint256 tokensSold = amount_in * PRESALE_INFO.TOKEN_PRICE  / (10 ** uint256(PRESALE_INFO.B_TOKEN.decimals()));\r\n    require(tokensSold \u003e 0, \u0027ZERO TOKENS\u0027);\r\n    if (buyer.baseDeposited == 0) {\r\n        STATUS.NUM_BUYERS++;\r\n    }\r\n    buyer.baseDeposited += amount_in;\r\n    buyer.tokensOwed += tokensSold;\r\n    STATUS.TOTAL_BASE_COLLECTED += amount_in;\r\n    STATUS.TOTAL_TOKENS_SOLD += tokensSold;\r\n    \r\n    // FINAL TRANSFERS OUT AND IN\r\n    // return unused ETH\r\n    if (PRESALE_INFO_2.PRESALE_IN_ETH \u0026\u0026 amount_in \u003c msg.value) {\r\n      payable(msg.sender).transfer(msg.value - amount_in);\r\n    }\r\n    // deduct non ETH token from user\r\n    if (!PRESALE_INFO_2.PRESALE_IN_ETH) {\r\n      TransferHelper.safeTransferFrom(address(PRESALE_INFO.B_TOKEN), msg.sender, address(this), amount_in);\r\n    }\r\n  }\r\n  \r\n  // withdraw presale tokens\r\n  // percentile withdrawls allows fee on transfer or rebasing tokens to still work\r\n  function userWithdrawTokens () external nonReentrant {\r\n    require(STATUS.LP_GENERATION_COMPLETE, \u0027AWAITING LP GENERATION\u0027);\r\n    BuyerInfo storage buyer = BUYERS[msg.sender];\r\n    uint256 tokensRemainingDenominator = STATUS.TOTAL_TOKENS_SOLD - STATUS.TOTAL_TOKENS_WITHDRAWN;\r\n    uint256 tokensOwed = PRESALE_INFO.S_TOKEN.balanceOf(address(this)) * buyer.tokensOwed / tokensRemainingDenominator;\r\n    require(tokensOwed \u003e 0, \u0027NOTHING TO WITHDRAW\u0027);\r\n    STATUS.TOTAL_TOKENS_WITHDRAWN += buyer.tokensOwed;\r\n    buyer.tokensOwed = 0;\r\n    TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), msg.sender, tokensOwed);\r\n  }\r\n  \r\n  // on presale failure\r\n  // percentile withdrawls allows fee on transfer or rebasing tokens to still work\r\n  function userWithdrawBaseTokens () external nonReentrant {\r\n    require(presaleStatus() == 3, \u0027NOT FAILED\u0027); // FAILED\r\n    BuyerInfo storage buyer = BUYERS[msg.sender];\r\n    require(buyer.baseDeposited \u003e 0 || buyer.unclOwed \u003e 0, \u0027NOTHING TO WITHDRAW\u0027);\r\n    if (buyer.baseDeposited \u003e 0) {\r\n      uint256 baseRemainingDenominator = STATUS.TOTAL_BASE_COLLECTED - STATUS.TOTAL_BASE_WITHDRAWN;\r\n      uint256 remainingBaseBalance = PRESALE_INFO_2.PRESALE_IN_ETH ? address(this).balance : PRESALE_INFO.B_TOKEN.balanceOf(address(this));\r\n      uint256 tokensOwed = remainingBaseBalance * buyer.baseDeposited / baseRemainingDenominator;\r\n      require(tokensOwed \u003e 0, \u0027NOTHING TO WITHDRAW\u0027);\r\n      STATUS.TOTAL_BASE_WITHDRAWN += buyer.baseDeposited;\r\n      buyer.baseDeposited = 0;\r\n      TransferHelper.safeTransferBaseToken(address(PRESALE_INFO.B_TOKEN), payable(msg.sender), tokensOwed, !PRESALE_INFO_2.PRESALE_IN_ETH);\r\n    }\r\n    if (buyer.unclOwed \u003e 0) {\r\n      (address unclAddress,,) = PRESALE_SETTINGS.getUNCLInfo();\r\n      TransferHelper.safeTransfer(unclAddress, payable(msg.sender), buyer.unclOwed);\r\n      buyer.unclOwed = 0;\r\n    }\r\n  }\r\n  \r\n  // on presale failure\r\n  // allows the owner to withdraw the tokens they sent for presale \u0026 initial liquidity\r\n  function ownerWithdrawTokens () external onlyPresaleOwner {\r\n    require(presaleStatus() == 3); // FAILED\r\n    TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), PRESALE_INFO_2.PRESALE_OWNER, PRESALE_INFO.S_TOKEN.balanceOf(address(this)));\r\n  }\r\n  \r\n\r\n  // Can be called at any stage before or during the presale to cancel it before it ends.\r\n  // If the pair already exists on uniswap and it contains the presale token as liquidity \r\n  // the final stage of the presale \u0027addLiquidity()\u0027 will fail. This function \r\n  // allows anyone to end the presale prematurely to release funds in such a case.\r\n  /* function forceFailIfPairExists () external {\r\n    require(!STATUS.LP_GENERATION_COMPLETE \u0026\u0026 !STATUS.FORCE_FAILED);\r\n    if (PRESALE_LOCK_FORWARDER.uniswapPairIsInitialised(address(PRESALE_INFO.S_TOKEN), address(PRESALE_INFO.B_TOKEN))) {\r\n        STATUS.FORCE_FAILED = true;\r\n    }\r\n  } */\r\n  \r\n  // if something goes wrong in LP generation\r\n  function forceFailByUnicrypt () external {\r\n      require(msg.sender == UNICRYPT_DEV_ADDRESS);\r\n      require(!STATUS.FORCE_FAILED);\r\n      STATUS.FORCE_FAILED = true;\r\n      // send UNCL to uncl burn address\r\n      (address unclAddress,,address unclFeeAddress) = PRESALE_SETTINGS.getUNCLInfo();\r\n      TransferHelper.safeTransfer(unclAddress, unclFeeAddress, UNCL_BURN_ON_FAIL);\r\n  }\r\n\r\n  // Allows the owner to end a presale before a pool has been created\r\n  function forceFailByPresaleOwner () external onlyPresaleOwner {\r\n      require(!STATUS.LP_GENERATION_COMPLETE, \u0027POOL EXISTS\u0027);\r\n      require(!STATUS.FORCE_FAILED);\r\n      STATUS.FORCE_FAILED = true;\r\n      (address unclAddress,,address unclFeeAddress) = PRESALE_SETTINGS.getUNCLInfo();\r\n      TransferHelper.safeTransfer(unclAddress, unclFeeAddress, UNCL_BURN_ON_FAIL);\r\n  }\r\n  \r\n  // on presale success, this is the final step to end the presale, lock liquidity and enable withdrawls of the sale token.\r\n  // This function does not use percentile distribution. Rebasing mechanisms, fee on transfers, or any deflationary logic\r\n  // are not taken into account at this stage to ensure stated liquidity is locked and the pool is initialised according to \r\n  // the presale parameters and fixed prices.\r\n  function addLiquidity() external nonReentrant {\r\n    // require(!STATUS.LP_GENERATION_COMPLETE, \u0027GENERATION COMPLETE\u0027);\r\n    require(presaleStatus() == 2, \u0027NOT SUCCESS\u0027); // SUCCESS\r\n    // Fail the presale if the pair exists and contains presale token liquidity\r\n    if (PRESALE_LOCK_FORWARDER.uniswapPairIsInitialised(address(PRESALE_INFO.S_TOKEN), address(PRESALE_INFO.B_TOKEN))) {\r\n        STATUS.FORCE_FAILED = true;\r\n        return;\r\n    }\r\n    \r\n    uint256 unicryptBaseFee = STATUS.TOTAL_BASE_COLLECTED * PRESALE_FEE_INFO.UNICRYPT_BASE_FEE / 1000;\r\n    \r\n    // base token liquidity\r\n    uint256 baseLiquidity = (STATUS.TOTAL_BASE_COLLECTED - unicryptBaseFee) * PRESALE_INFO.LIQUIDITY_PERCENT / 1000;\r\n    if (PRESALE_INFO_2.PRESALE_IN_ETH) {\r\n        WETH.deposit{value : baseLiquidity}();\r\n    }\r\n    TransferHelper.safeApprove(address(PRESALE_INFO.B_TOKEN), address(PRESALE_LOCK_FORWARDER), baseLiquidity);\r\n    \r\n    // sale token liquidity\r\n    uint256 tokenLiquidity = baseLiquidity * PRESALE_INFO.LISTING_RATE / (10 ** uint256(PRESALE_INFO.B_TOKEN.decimals()));\r\n    TransferHelper.safeApprove(address(PRESALE_INFO.S_TOKEN), address(PRESALE_LOCK_FORWARDER), tokenLiquidity);\r\n    \r\n    PRESALE_LOCK_FORWARDER.lockLiquidity(PRESALE_INFO.B_TOKEN, PRESALE_INFO.S_TOKEN, baseLiquidity, tokenLiquidity, block.timestamp + PRESALE_INFO.LOCK_PERIOD, PRESALE_INFO_2.PRESALE_OWNER);\r\n    // transfer fees\r\n    uint256 unicryptTokenFee = STATUS.TOTAL_TOKENS_SOLD * PRESALE_FEE_INFO.UNICRYPT_TOKEN_FEE / 1000;\r\n    // referrals are checked for validity in the presale generator\r\n    if (PRESALE_FEE_INFO.REFERRAL_FEE_ADDRESS != address(0)) {\r\n        // Base token fee\r\n        uint256 referralBaseFee = unicryptBaseFee * PRESALE_FEE_INFO.REFERRAL_FEE / 1000;\r\n        TransferHelper.safeTransferBaseToken(address(PRESALE_INFO.B_TOKEN), PRESALE_FEE_INFO.REFERRAL_FEE_ADDRESS, referralBaseFee, !PRESALE_INFO_2.PRESALE_IN_ETH);\r\n        unicryptBaseFee -= referralBaseFee;\r\n        // Token fee\r\n        uint256 referralTokenFee = unicryptTokenFee * PRESALE_FEE_INFO.REFERRAL_FEE / 1000;\r\n        TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), PRESALE_FEE_INFO.REFERRAL_FEE_ADDRESS, referralTokenFee);\r\n        unicryptTokenFee -= referralTokenFee;\r\n    }\r\n    TransferHelper.safeTransferBaseToken(\r\n      address(PRESALE_INFO.B_TOKEN), \r\n      PRESALE_INFO_2.PRESALE_IN_ETH ? PRESALE_SETTINGS.getEthAddress() : PRESALE_SETTINGS.getNonEthAddress(), \r\n      unicryptBaseFee, \r\n      !PRESALE_INFO_2.PRESALE_IN_ETH\r\n    );\r\n    TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), PRESALE_SETTINGS.getTokenAddress(), unicryptTokenFee);\r\n    \r\n    // burn unsold tokens\r\n    uint256 remainingSBalance = PRESALE_INFO.S_TOKEN.balanceOf(address(this));\r\n    if (remainingSBalance \u003e STATUS.TOTAL_TOKENS_SOLD) {\r\n        uint256 burnAmount = remainingSBalance - STATUS.TOTAL_TOKENS_SOLD;\r\n        TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), 0x000000000000000000000000000000000000dEaD, burnAmount);\r\n    }\r\n    \r\n    // send remaining base tokens to presale owner\r\n    uint256 remainingBaseBalance = PRESALE_INFO_2.PRESALE_IN_ETH ? address(this).balance : PRESALE_INFO.B_TOKEN.balanceOf(address(this));\r\n    TransferHelper.safeTransferBaseToken(address(PRESALE_INFO.B_TOKEN), PRESALE_INFO_2.PRESALE_OWNER, remainingBaseBalance, !PRESALE_INFO_2.PRESALE_IN_ETH);\r\n\r\n    // send UNCL to uncl burn address\r\n    (address unclAddress,,address unclFeeAddress) = PRESALE_SETTINGS.getUNCLInfo();\r\n    TransferHelper.safeTransfer(unclAddress, unclFeeAddress, IERC20(unclAddress).balanceOf(address(this)));\r\n    \r\n    STATUS.LP_GENERATION_COMPLETE = true;\r\n  }\r\n  \r\n  // postpone or bring a presale forward, this will only work when a presale is inactive.\r\n  // i.e. current start block \u003e block.number\r\n  function updateBlocks(uint256 _startBlock, uint256 _endBlock) external onlyPresaleOwner {\r\n    require(presaleStatus() == 0 \u0026\u0026 _startBlock \u003e STATUS.ROUND_0_START + PRESALE_SETTINGS.getRound0Offset(), \u0027UB1\u0027);\r\n    require(_endBlock - _startBlock \u003c= PRESALE_SETTINGS.getMaxPresaleLength(), \u0027UB2\u0027);\r\n    PRESALE_INFO.START_BLOCK = _startBlock;\r\n    PRESALE_INFO.END_BLOCK = _endBlock;\r\n  }\r\n}"},"ReentrancyGuard.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\n// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.0.0\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Contract module that helps prevent reentrant calls to a function.\r\n *\r\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\r\n * available, which can be applied to functions to make sure there are no nested\r\n * (reentrant) calls to them.\r\n *\r\n * Note that because there is a single `nonReentrant` guard, functions marked as\r\n * `nonReentrant` may not call one another. This can be worked around by making\r\n * those functions `private`, and then adding `external` `nonReentrant` entry\r\n * points to them.\r\n *\r\n * TIP: If you would like to learn more about reentrancy and alternative ways\r\n * to protect against it, check out our blog post\r\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\r\n */\r\nabstract contract ReentrancyGuard {\r\n    // Booleans are more expensive than uint256 or any type that takes up a full\r\n    // word because each write operation emits an extra SLOAD to first read the\r\n    // slot\u0027s contents, replace the bits taken up by the boolean, and then write\r\n    // back. This is the compiler\u0027s defense against contract upgrades and\r\n    // pointer aliasing, and it cannot be disabled.\r\n\r\n    // The values being non-zero value makes deployment a bit more expensive,\r\n    // but in exchange the refund on every call to nonReentrant will be lower in\r\n    // amount. Since refunds are capped to a percentage of the total\r\n    // transaction\u0027s gas, it is best to keep them low in cases like this one, to\r\n    // increase the likelihood of the full refund coming into effect.\r\n    uint256 private constant _NOT_ENTERED = 1;\r\n    uint256 private constant _ENTERED = 2;\r\n\r\n    uint256 private _status;\r\n\r\n    constructor () {\r\n        _status = _NOT_ENTERED;\r\n    }\r\n\r\n    /**\r\n     * @dev Prevents a contract from calling itself, directly or indirectly.\r\n     * Calling a `nonReentrant` function from another `nonReentrant`\r\n     * function is not supported. It is possible to prevent this from happening\r\n     * by making the `nonReentrant` function external, and make it call a\r\n     * `private` function that does the actual work.\r\n     */\r\n    modifier nonReentrant() {\r\n        // On the first call to nonReentrant, _notEntered will be true\r\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\r\n\r\n        // Any calls to nonReentrant after this point will fail\r\n        _status = _ENTERED;\r\n\r\n        _;\r\n\r\n        // By storing the original value once again, a refund is triggered (see\r\n        // https://eips.ethereum.org/EIPS/eip-2200)\r\n        _status = _NOT_ENTERED;\r\n    }\r\n}\r\n"},"TransferHelper.sol":{"content":"pragma solidity ^0.8.0;\r\n\r\n/**\r\n    helper methods for interacting with ERC20 tokens that do not consistently return true/false\r\n    with the addition of a transfer function to send eth or an erc20 token\r\n*/\r\nlibrary TransferHelper {\r\n    function safeApprove(address token, address to, uint value) internal {\r\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));\r\n        require(success \u0026\u0026 (data.length == 0 || abi.decode(data, (bool))), \u0027TransferHelper: APPROVE_FAILED\u0027);\r\n    }\r\n\r\n    function safeTransfer(address token, address to, uint value) internal {\r\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));\r\n        require(success \u0026\u0026 (data.length == 0 || abi.decode(data, (bool))), \u0027TransferHelper: TRANSFER_FAILED\u0027);\r\n    }\r\n\r\n    function safeTransferFrom(address token, address from, address to, uint value) internal {\r\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));\r\n        require(success \u0026\u0026 (data.length == 0 || abi.decode(data, (bool))), \u0027TransferHelper: TRANSFER_FROM_FAILED\u0027);\r\n    }\r\n    \r\n    // sends ETH or an erc20 token\r\n    function safeTransferBaseToken(address token, address payable to, uint value, bool isERC20) internal {\r\n        if (!isERC20) {\r\n            to.transfer(value);\r\n        } else {\r\n            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));\r\n            require(success \u0026\u0026 (data.length == 0 || abi.decode(data, (bool))), \u0027TransferHelper: TRANSFER_FAILED\u0027);\r\n        }\r\n    }\r\n}"}}