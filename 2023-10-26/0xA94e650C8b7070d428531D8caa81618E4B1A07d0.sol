{"eclipse.sol":{"content":"//SPDX-License-Identifier: MIT\r\npragma solidity 0.8.14;\r\n\r\nimport \"./IERC20.sol\";\r\nimport \"./Ownable.sol\";\r\n\r\ncontract Eclipse is Ownable {\r\n\r\n    // Eclipse Token\r\n    address public eclipse;\r\n\r\n    // Listing Data\r\n    struct ListedToken {\r\n        uint256 listedIndex;\r\n        uint256 amount;\r\n        uint256 lastContribute;\r\n        bool isNFT;\r\n        bool nsfw;\r\n    }\r\n\r\n    // token =\u003e listing data\r\n    mapping (address =\u003e ListedToken) public listedTokens;\r\n\r\n    // array of listed tokens\r\n    address[] public listed;\r\n\r\n    // Applicants\r\n    struct Applicant {\r\n        uint index;\r\n        uint feeCharged;\r\n        address user;\r\n        address ref;\r\n    }\r\n    address[] public applicants;\r\n    mapping ( address =\u003e Applicant ) public applicationInfo;\r\n\r\n    // Referral Structure\r\n    struct Ref {\r\n        uint256 cut;\r\n        uint256 totalEarned;\r\n        address[] tokenReferrals;\r\n    }\r\n\r\n    // Referrer Structure\r\n    mapping ( address =\u003e Ref ) public refInfo;\r\n\r\n    // address =\u003e is authorized\r\n    mapping ( address =\u003e bool ) public authorized;\r\n    modifier onlyAuthorized() {\r\n        require(authorized[msg.sender] || msg.sender == this.getOwner(), \u0027Only Authorized\u0027);\r\n        _;\r\n    }\r\n\r\n    // Decay Rate\r\n    uint256 public decay_per_second = 165343916000;\r\n    uint256 private constant DENOM = 10**18;\r\n\r\n    // Listing Fees\r\n    uint256 public listingFee;\r\n\r\n    // Recipient\r\n    address public eclipseRecipient;\r\n    address public listingRecipient;\r\n\r\n    // Default Referrer Fee\r\n    uint256 public default_referral_fee = 10;\r\n\r\n    // Events\r\n    event Applied(address indexed user, address ref, uint256 listingFee);\r\n    event FundedEclipse(address token, address funder, uint256 amount);\r\n\r\n    constructor(address eclipse_, uint listingFee_) {\r\n        eclipse = eclipse_;\r\n        listingFee = listingFee_;\r\n    }\r\n\r\n    function setListingFee(uint newFee) external onlyOwner {\r\n        listingFee = newFee;\r\n    }\r\n\r\n    function setDefaultReferralFee(uint newDefault) external onlyOwner {\r\n        require(\r\n            newDefault \u003e 0 \u0026\u0026 newDefault \u003c 50,\r\n            \u0027Fee Out Of Bounds\u0027\r\n        );\r\n        default_referral_fee = newDefault;\r\n    }\r\n\r\n    function upgrade(address oldToken, address newToken) external onlyOwner {\r\n        require(isListed(oldToken), \u0027Token Not Listed\u0027);\r\n        listedTokens[newToken] = listedTokens[oldToken];\r\n    }\r\n\r\n    function awardPoints(address token, uint256 numPoints) external onlyOwner {\r\n        require(isListed(token), \u0027Token Not Listed\u0027);\r\n\r\n        // add new points to amount\r\n        unchecked {\r\n            listedTokens[token].amount += numPoints;\r\n        }\r\n\r\n        // reset last contribution timestamp\r\n        listedTokens[token].lastContribute = block.timestamp;\r\n    }\r\n\r\n    function setEclipse(address eclipse_) external onlyOwner {\r\n        eclipse = eclipse_;\r\n    }\r\n\r\n    function setAuthorized(address account, bool isAuth) external onlyOwner {\r\n        authorized[account] = isAuth;\r\n    }\r\n\r\n    function delistToken(address token) external onlyOwner {\r\n        require(\r\n            isListed(token),\r\n            \u0027Not Listed\u0027\r\n        );\r\n        listed[listedTokens[token].listedIndex] = listed[listed.length-1];\r\n        listedTokens[listed[listed.length-1]].listedIndex = listedTokens[token].listedIndex;\r\n        listed.pop();\r\n        delete listedTokens[token];\r\n    }\r\n\r\n    function setDecayPerSecond(uint newDecay) external onlyOwner {\r\n        decay_per_second = newDecay;\r\n    }\r\n\r\n    function setEclipseRecipient(address newRecipient) external onlyOwner {\r\n        eclipseRecipient = newRecipient;\r\n    }\r\n\r\n    function setListingRecipient(address newRecipient) external onlyOwner {\r\n        listingRecipient = newRecipient;\r\n    }\r\n\r\n    function withdrawTokens(address token) external onlyOwner {\r\n        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));\r\n    }\r\n\r\n    function setReferralCut(address ref, uint cut) external onlyOwner {\r\n        require(cut \u003e 0, \u0027Must Have Cut\u0027);\r\n        require(cut \u003c 100, \u0027Cut Cannot Be 100%\u0027);\r\n        require(ref != address(0), \u0027Zero Addr\u0027);\r\n        refInfo[ref].cut = cut;\r\n    }\r\n\r\n    function removeReferrerCut(address ref) external onlyOwner {\r\n        delete refInfo[ref].cut;\r\n    }\r\n\r\n    function listTokenWithoutApplication(address token, bool isNFT) external onlyOwner {\r\n        require(\r\n            !isListed(token),\r\n            \u0027Already Listed\u0027\r\n        );\r\n        require(\r\n            !isApplicant(token),\r\n            \u0027Token Already Applied\u0027\r\n        );\r\n        \r\n        // listed data\r\n        listedTokens[token].listedIndex = listed.length;\r\n        listedTokens[token].isNFT = isNFT;\r\n        listed.push(token);\r\n    }\r\n\r\n    function listToken(address token, bool isNFT) external onlyAuthorized {\r\n        require(\r\n            !isListed(token),\r\n            \u0027Already Listed\u0027\r\n        );\r\n        require(\r\n            isApplicant(token),\r\n            \u0027Token Did Not Apply\u0027\r\n        );\r\n        \r\n        // listed data\r\n        listedTokens[token].listedIndex = listed.length;\r\n        listedTokens[token].isNFT = isNFT;\r\n        listed.push(token);\r\n\r\n        // application fee\r\n        uint fee = applicationInfo[token].feeCharged;\r\n\r\n        // referrer\r\n        address ref = applicationInfo[token].ref;\r\n\r\n        // remove applicant\r\n        _removeApplicant(token);\r\n        \r\n        // forward fee\r\n        if (fee \u003e 0) {\r\n            if (ref != address(0)) {\r\n\r\n                // split fee\r\n                uint refCut = getReferralFee(fee, ref);\r\n                uint rest = fee - refCut;\r\n\r\n                // send fee to listing recipient\r\n                (bool s,) = payable(listingRecipient).call{value: rest}(\"\");\r\n                require(s, \u0027BNB TRANSFER FAIL\u0027);\r\n\r\n                // send fee to referrer\r\n                (s,) = payable(ref).call{value: refCut}(\"\");\r\n                require(s, \u0027BNB TRANSFER FAIL\u0027);\r\n\r\n                // track how many fees were received by referrer\r\n                unchecked {\r\n                    refInfo[ref].totalEarned += refCut;\r\n                }\r\n\r\n                // add to referrers list\r\n                refInfo[ref].tokenReferrals.push(token);\r\n\r\n            } else {\r\n\r\n                // no referrer, send entire fee to listing recipient\r\n                (bool s,) = payable(listingRecipient).call{value: fee}(\"\");\r\n                require(s, \u0027BNB TRANSFER FAIL\u0027);\r\n\r\n            }\r\n        }\r\n    }\r\n\r\n    function rejectApplication(address token) external onlyAuthorized {\r\n        require(isApplicant(token), \u0027Not Applicant\u0027);\r\n\r\n        // fetch data\r\n        uint refund = applicationInfo[token].feeCharged;\r\n        address user = applicationInfo[token].user;\r\n\r\n        // remove applicant\r\n        _removeApplicant(token);\r\n\r\n        // refund user\r\n        (bool s,) = payable(user).call{value: refund}(\"\");\r\n        require(s, \u0027BNB TRANSFER FAIL\u0027);\r\n    }\r\n\r\n    function setNSFW(address token, bool isNSFW) external onlyAuthorized {\r\n        require(isListed(token), \u0027Token Not Listed\u0027);\r\n        listedTokens[token].nsfw = isNSFW;\r\n    }\r\n\r\n    function Apply(address ref, address token) external payable {\r\n        require(\r\n            token != address(0),\r\n            \u0027Non Token\u0027\r\n        );\r\n        require(\r\n            !isApplicant(token),\r\n            \u0027Already Applied\u0027\r\n        );\r\n        require(\r\n            msg.value \u003e= listingFee,\r\n            \u0027Invalid Fee\u0027\r\n        );\r\n\r\n        if (ref != address(0)) {\r\n            applicationInfo[token].ref = ref;\r\n        }\r\n\r\n        applicationInfo[token].index = applicants.length;\r\n        applicationInfo[token].feeCharged = msg.value;\r\n        applicationInfo[token].user = msg.sender;\r\n        applicants.push(token);\r\n\r\n        emit Applied(msg.sender, ref, msg.value);\r\n    }\r\n\r\n    function addToEclipse(address token, uint256 amount) external {\r\n        require(\r\n            IERC20(eclipse).allowance(msg.sender, address(this)) \u003e= amount,\r\n            \u0027Insufficient Allowance\u0027\r\n        );\r\n        require(\r\n            IERC20(eclipse).balanceOf(msg.sender) \u003e= amount,\r\n            \u0027Insufficient Balance\u0027\r\n        );\r\n\r\n        // transfer tokens from sender to eclipse recipient\r\n        IERC20(eclipse).transferFrom(msg.sender, eclipseRecipient, amount);\r\n\r\n        // decay balance if applicable\r\n        if (timeSince(token) \u003e 0) {\r\n            listedTokens[token].amount = getPoints(token);\r\n        }\r\n\r\n        // add new donation to amount\r\n        unchecked {\r\n            listedTokens[token].amount += amount;\r\n        }\r\n        listedTokens[token].lastContribute = block.timestamp;\r\n\r\n        emit FundedEclipse(token, msg.sender, amount);\r\n    }\r\n\r\n    function _removeApplicant(address applicant) internal {\r\n        applicants[applicationInfo[applicant].index] = applicants[applicants.length-1];\r\n        applicationInfo[applicants[applicants.length-1]].index = applicationInfo[applicant].index;\r\n        applicants.pop();\r\n        delete applicationInfo[applicant];\r\n    }\r\n\r\n    function getReferralFee(uint256 amount, address ref) public view returns (uint256 refFee) {\r\n        uint256 refCut = refInfo[ref].cut == 0 ? default_referral_fee : refInfo[ref].cut;\r\n        return ( amount * refCut ) / 100;\r\n    }\r\n\r\n    function getPoints(address token) public view returns (uint256) {\r\n        if (listedTokens[token].amount == 0 || listedTokens[token].lastContribute == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint prev = listedTokens[token].amount;\r\n        uint timeSince_ = timeSince(token);\r\n\r\n        uint decay = prev * timeSince_ * decay_per_second / DENOM;\r\n\r\n        return decay \u003e= prev ? 0 : prev - decay;\r\n    }\r\n\r\n    function timeSince(address token) public view returns (uint256) {\r\n        if (listedTokens[token].lastContribute == 0) {\r\n            return 0;\r\n        }\r\n\r\n        return block.timestamp \u003e listedTokens[token].lastContribute ? block.timestamp - listedTokens[token].lastContribute : 0;\r\n    }\r\n\r\n    function getListedTokens() public view returns (address[] memory) {\r\n        return listed;\r\n    }\r\n\r\n    function getListedTokensAndPoints() public view returns (address[] memory, uint256[] memory) {\r\n\r\n        uint len = listed.length;\r\n        uint256[] memory points = new uint256[](len);\r\n        for (uint i = 0; i \u003c len;) {\r\n            points[i] = getPoints(listed[i]);\r\n            unchecked { ++i; }\r\n        }\r\n        return (listed, points);\r\n    }\r\n\r\n    function getListedTokensAndPointsAndTypeFlag() public view returns (address[] memory, uint256[] memory, bool[] memory isNFTList, bool[] memory isNSFW) {\r\n\r\n        uint len = listed.length;\r\n        uint256[] memory points = new uint256[](len);\r\n        isNFTList = new bool[](len);\r\n\r\n        isNSFW = new bool[](len);\r\n        for (uint i = 0; i \u003c len;) {\r\n            points[i] = getPoints(listed[i]);\r\n            isNFTList[i] = listedTokens[listed[i]].isNFT;\r\n            isNSFW[i] = listedTokens[listed[i]].nsfw;\r\n            unchecked { ++i; }\r\n        }\r\n        return (listed, points, isNFTList, isNSFW);\r\n    }\r\n\r\n    function isListed(address token) public view returns (bool) {\r\n        if (listed.length \u003c= listedTokens[token].listedIndex) {\r\n            return false;\r\n        }\r\n        return listed[listedTokens[token].listedIndex] == token;\r\n    }\r\n\r\n    function isApplicant(address token) public view returns (bool) {\r\n        if (applicants.length \u003c= applicationInfo[token].index) {\r\n            return false;\r\n        }\r\n        return applicants[applicationInfo[token].index] == token;\r\n    }\r\n\r\n    function isReferrer(address ref) public view returns (bool) {\r\n        if (ref == address(0)) {\r\n            return false;\r\n        }\r\n        return refInfo[ref].cut \u003e 0;\r\n    }\r\n\r\n    function getTotalEarned(address ref) external view returns (uint256) {\r\n        return refInfo[ref].totalEarned;\r\n    }\r\n\r\n    function viewAllTokensReferred(address ref) external view returns (address[] memory) {\r\n        return refInfo[ref].tokenReferrals;\r\n    }\r\n\r\n    function getNumberOfTokensReferred(address ref) external view returns (uint256) {\r\n        return refInfo[ref].tokenReferrals.length;\r\n    }\r\n\r\n    receive() external payable {}\r\n}"},"IERC20.sol":{"content":"//SPDX-License-Identifier: MIT\r\npragma solidity 0.8.14;\r\n\r\ninterface IERC20 {\r\n\r\n    function totalSupply() external view returns (uint256);\r\n    \r\n    function symbol() external view returns(string memory);\r\n    \r\n    function name() external view returns(string memory);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n    \r\n    /**\r\n     * @dev Returns the number of decimal places\r\n     */\r\n    function decimals() external view returns (uint8);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\r\npragma solidity 0.8.14;\r\n\r\n/**\r\n * @title Owner\r\n * @dev Set \u0026 change owner\r\n */\r\ncontract Ownable {\r\n\r\n    address private owner;\r\n    \r\n    // event for EVM logging\r\n    event OwnerSet(address indexed oldOwner, address indexed newOwner);\r\n    \r\n    // modifier to check if caller is owner\r\n    modifier onlyOwner() {\r\n        // If the first argument of \u0027require\u0027 evaluates to \u0027false\u0027, execution terminates and all\r\n        // changes to the state and to Ether balances are reverted.\r\n        // This used to consume all gas in old EVM versions, but not anymore.\r\n        // It is often a good idea to use \u0027require\u0027 to check if functions are called correctly.\r\n        // As a second argument, you can also provide an explanation about what went wrong.\r\n        require(msg.sender == owner, \"Caller is not owner\");\r\n        _;\r\n    }\r\n    \r\n    /**\r\n     * @dev Set contract deployer as owner\r\n     */\r\n    constructor() {\r\n        owner = msg.sender; // \u0027msg.sender\u0027 is sender of current call, contract deployer for a constructor\r\n        emit OwnerSet(address(0), owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Change owner\r\n     * @param newOwner address of new owner\r\n     */\r\n    function changeOwner(address newOwner) public onlyOwner {\r\n        emit OwnerSet(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n\r\n    /**\r\n     * @dev Return owner address \r\n     * @return address of owner\r\n     */\r\n    function getOwner() external view returns (address) {\r\n        return owner;\r\n    }\r\n}"}}