{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(\n        address indexed previousOwner,\n        address indexed newOwner\n    );\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(\n            newOwner != address(0),\n            \"Ownable: new owner is the zero address\"\n        );\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"},"ReferralCode.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./Ownable.sol\";\r\n\r\ncontract ReferralCode is Ownable {\r\n    struct Referrer {\r\n        string code;\r\n        address creator;\r\n        uint256 tokenId;\r\n        address tokenAddress;\r\n        uint256 totalAppliedCodes;\r\n        uint256 totalRewards;\r\n        bool isVIP;\r\n    }\r\n\r\n    event ReferralCodeGenerated(string code, address creator);\r\n    event ReferralCodeRedeemed(string code, address minter);\r\n    event ReferrerUpgraded(string code, address creator);\r\n\r\n    mapping(string =\u003e Referrer) public referralCodes;\r\n    mapping(string =\u003e bool) public referralCodesVIP;\r\n    mapping(address =\u003e string) public referralCodesByCreator;\r\n    string[] public referralCodeKeys;\r\n    mapping(address =\u003e uint256) public totalReferralRewards;\r\n    mapping(address =\u003e uint256) public totalAppliedReferralCodes;\r\n    mapping(address =\u003e uint256) public totalDiscountsByMinter;\r\n    mapping(address =\u003e address) public nftContracts;\r\n    mapping(address =\u003e bool) public nftContractVIP;\r\n\r\n    uint256 public totalDiscounts;\r\n    uint256 public totalReferralCount;\r\n    uint256 public totalRewards;\r\n\r\n    modifier onlyNFTContract() {\r\n        require(\r\n            nftContracts[msg.sender] == msg.sender,\r\n            \"Only NFT contract can call this function\"\r\n        );\r\n        _;\r\n    }\r\n\r\n    function addNFTContract(\r\n        address _nftContract,\r\n        bool isVIP\r\n    ) external onlyOwner {\r\n        nftContracts[_nftContract] = _nftContract;\r\n        nftContractVIP[_nftContract] = isVIP;\r\n    }\r\n\r\n    function removeNFTContract(address _nftContract) external onlyOwner {\r\n        delete nftContracts[_nftContract];\r\n        delete nftContractVIP[_nftContract];\r\n    }\r\n\r\n    function generateReferralCode(\r\n        address _creator,\r\n        uint256 _tokenId,\r\n        address _tokenAddress,\r\n        string memory _code\r\n    ) external onlyNFTContract returns (string memory) {\r\n        require(_creator != address(0), \"Creator address cannot be 0\");\r\n        string memory code;\r\n        if (bytes(_code).length \u003e 0) {\r\n            require(\r\n                _isValidCode(_code),\r\n                \"The provided code contains invalid characters\"\r\n            );\r\n            require(!isValidCode(_code), \"The provided code is already in use\");\r\n            code = _code;\r\n        } else {\r\n            code = generateUniqueReferralCode();\r\n        }\r\n        bool _vip = nftContractVIP[_tokenAddress];\r\n        referralCodes[code] = Referrer(\r\n            code,\r\n            _creator,\r\n            _tokenId,\r\n            _tokenAddress,\r\n            0,\r\n            0,\r\n            _vip\r\n        );\r\n        referralCodesVIP[code] = _vip;\r\n        referralCodeKeys.push(code);\r\n        referralCodesByCreator[_creator] = code;\r\n        emit ReferralCodeGenerated(code, _creator);\r\n        return code;\r\n    }\r\n\r\n    function isValidCode(string memory _code) public view returns (bool) {\r\n        return referralCodes[_code].creator != address(0);\r\n    }\r\n\r\n    function upgradeReferrer(\r\n        address _referrer\r\n    ) external onlyNFTContract returns (Referrer memory) {\r\n        require(_referrer != address(0), \"Referrer address cannot be 0\");\r\n        string memory _code = referralCodesByCreator[_referrer];\r\n        Referrer storage referrer = referralCodes[_code];\r\n        if (bytes(_code).length \u003e 0) {\r\n            // require(referrer.creator != address(0), \"Referrer does not exist\");\r\n            if (referrer.isVIP) {\r\n                return referrer;\r\n            } else {\r\n                referrer.isVIP = true;\r\n                emit ReferrerUpgraded(_code, _referrer);\r\n            }\r\n            return referrer;\r\n        } else {\r\n            return referrer;\r\n        }\r\n    }\r\n\r\n    function redeemCode(\r\n        string memory _code,\r\n        address _minter,\r\n        uint256 _discount,\r\n        uint256 _reward\r\n    ) external onlyNFTContract returns (Referrer memory) {\r\n        Referrer storage referrer = referralCodes[_code];\r\n        require(referrer.creator != address(0), \"Invalid referral code\");\r\n        require(referrer.creator != _minter, \"Cannot refer yourself\");\r\n        referrer.totalAppliedCodes++;\r\n        referrer.totalRewards += _reward;\r\n\r\n        totalDiscounts += _discount;\r\n        totalReferralCount++;\r\n        totalRewards += _reward;\r\n\r\n        totalReferralRewards[referrer.creator] += _reward;\r\n        totalAppliedReferralCodes[referrer.creator]++;\r\n        totalDiscountsByMinter[_minter] += _discount;\r\n\r\n        emit ReferralCodeRedeemed(_code, _minter);\r\n\r\n        return referrer;\r\n    }\r\n\r\n    function getReferralCodeByCreator(\r\n        address creator\r\n    ) external view returns (string memory) {\r\n        return referralCodesByCreator[creator];\r\n    }\r\n\r\n    function getReferrerByCode(\r\n        string memory _code\r\n    ) external view returns (Referrer memory) {\r\n        Referrer storage referrerStorage = referralCodes[_code];\r\n        require(referrerStorage.creator != address(0), \"Invalid referral code\");\r\n\r\n        Referrer memory referrerMemory = Referrer({\r\n            code: referrerStorage.code,\r\n            creator: referrerStorage.creator,\r\n            tokenId: referrerStorage.tokenId,\r\n            tokenAddress: referrerStorage.tokenAddress,\r\n            totalAppliedCodes: referrerStorage.totalAppliedCodes,\r\n            totalRewards: referrerStorage.totalRewards,\r\n            isVIP: referrerStorage.isVIP\r\n        });\r\n\r\n        return referrerMemory;\r\n    }\r\n\r\n    function getTotalAppliedReferralCodes(\r\n        address creator\r\n    ) external view returns (uint256) {\r\n        return totalAppliedReferralCodes[creator];\r\n    }\r\n\r\n    function generateUniqueReferralCode()\r\n        internal\r\n        view\r\n        returns (string memory)\r\n    {\r\n        string memory code;\r\n        do {\r\n            code = randomString(8);\r\n        } while (isValidCode(code));\r\n        return code;\r\n    }\r\n\r\n    function _isValidCode(string memory _code) internal pure returns (bool) {\r\n        bytes memory b = bytes(_code);\r\n        for (uint i; i \u003c b.length; i++) {\r\n            bytes1 char = b[i];\r\n            if (\r\n                !((char \u003e= bytes1(\"0\") \u0026\u0026 char \u003c= bytes1(\"9\")) ||\r\n                    (char \u003e= bytes1(\"A\") \u0026\u0026 char \u003c= bytes1(\"Z\")) ||\r\n                    (char \u003e= bytes1(\"a\") \u0026\u0026 char \u003c= bytes1(\"z\")))\r\n            ) {\r\n                return false;\r\n            }\r\n        }\r\n        return true;\r\n    }\r\n\r\n    function randomString(uint256 length) public view returns (string memory) {\r\n        string memory chars = \"ABCDEFGHIJKLMNOPQRSTUVWXYZ\";\r\n        bytes memory charsBytes = bytes(chars);\r\n        bytes memory str = new bytes(length);\r\n        for (uint256 i = 0; i \u003c length; ++i) {\r\n            uint256 rand = uint256(\r\n                keccak256(\r\n                    abi.encodePacked(\r\n                        block.timestamp,\r\n                        blockhash(block.number - 1),\r\n                        i\r\n                    )\r\n                )\r\n            ) % charsBytes.length;\r\n            str[i] = charsBytes[rand];\r\n        }\r\n        return string(str);\r\n    }\r\n\r\n\r\n}\r\n"}}