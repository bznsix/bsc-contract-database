// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "./interfaces/IIFOV6.sol";
import "./utils/WhiteList.sol";
import "./IPancakeProfile.sol";
import "./ICake.sol";
import "./test/CakeToken.sol";
import "./test/SyrupBar.sol";
import "./test/MasterChef.sol";

/**
 * @title IFOInitializableV6
 */
contract IFOInitializableV6 is IIFOV6, ReentrancyGuard, Whitelist {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Number of pools
    uint8 public constant NUMBER_POOLS = 2;

    // The address of the smart chef factory
    address public immutable IFO_FACTORY;

    // Max blocks (for sanity checks)
    uint256 public MAX_BUFFER_BLOCKS;

    // Max pool id (sometimes only public sale exist)
    uint8 public MAX_POOL_ID;

    // The LP token used
    IERC20 public lpToken;

    // The offering token
    IERC20 public offeringToken;

    // PancakeProfile
    address public pancakeProfileAddress;

    // ICake contract
    address public iCakeAddress;

    // Whether it is initialized
    bool public isInitialized;

    // The block number when IFO starts
    uint256 public startBlock;

    // The block number when IFO ends
    uint256 public endBlock;

    // The campaignId for the IFO
    uint256 public campaignId;

    // The number of points distributed to each person who harvest
    uint256 public numberPoints;

    // The threshold for points (in LP tokens)
    uint256 public thresholdPoints;

    // Total tokens distributed across the pools
    uint256 public totalTokensOffered;

    // The minimum point special sale require
    uint256 public pointThreshold;

    // The contract of the admission profile
    address public admissionProfile;

    // Array of PoolCharacteristics of size NUMBER_POOLS
    PoolCharacteristics[NUMBER_POOLS] private _poolInformation;

    // Checks if user has claimed points
    mapping(address => bool) private _hasClaimedPoints;

    // It maps the address to pool id to UserInfo
    mapping(address => mapping(uint8 => UserInfo)) private _userInfo;

    // It maps user address to credit used amount
    mapping(address => uint256) public userCreditUsed;

    // It maps if nft token id was used
    mapping(uint256 => address) public tokenIdUsed;

    // It maps user address with NFT id
    mapping(address => uint256) public userNftTokenId;

    // Struct that contains each pool characteristics
    struct PoolCharacteristics {
        uint256 raisingAmountPool; // amount of tokens raised for the pool (in LP tokens)
        uint256 offeringAmountPool; // amount of tokens offered for the pool (in offeringTokens)
        uint256 limitPerUserInLP; // limit of tokens per user (if 0, it is ignored)
        bool hasTax; // tax on the overflow (if any, it works with _calculateTaxOverflow)
        uint256 flatTaxRate; // new rate for flat tax
        uint256 totalAmountPool; // total amount pool deposited (in LP tokens)
        uint256 sumTaxesOverflow; // total taxes collected (starts at 0, increases with each harvest if overflow)
        bool isSpecialSale;
        uint256 vestingPercentage; // 60 means 0.6, rest part such as 100-60=40 means 0.4 is claimingPercentage
        uint256 vestingCliff; // Vesting cliff
        uint256 vestingDuration; // Vesting duration
        uint256 vestingSlicePeriodSeconds; // Vesting slice period seconds
    }

    // Struct that contains each user information for both pools
    struct UserInfo {
        uint256 amountPool; // How many tokens the user has provided for pool
        bool claimedPool; // Whether the user has claimed (default: false) for pool
    }

    // vesting startTime, everyone will be started at same timestamp
    uint256 public vestingStartTime;

    // A flag for vesting is being revoked
    bool public vestingRevoked;

    // Struct that contains vesting schedule
    struct VestingSchedule {
        bool isVestingInitialized;
        // beneficiary of tokens after they are released
        address beneficiary;
        // pool id
        uint8 pid;
        // total amount of tokens to be released at the end of the vesting
        uint256 amountTotal;
        // amount of tokens has been released
        uint256 released;
    }

    bytes32[] private vestingSchedulesIds;
    mapping(bytes32 => VestingSchedule) private vestingSchedules;
    uint256 private vestingSchedulesTotalAmount;
    mapping(address => uint256) private holdersVestingCount;

    // Admin withdraw events
    event AdminWithdraw(uint256 amountLP, uint256 amountOfferingToken);

    // Admin recovers token
    event AdminTokenRecovery(address tokenAddress, uint256 amountTokens);

    // Deposit event
    event Deposit(address indexed user, uint256 amount, uint8 indexed pid);

    // Harvest event
    event Harvest(address indexed user, uint256 offeringAmount, uint256 excessAmount, uint8 indexed pid);

    // Create VestingSchedule event
    event CreateVestingSchedule(address indexed user, uint256 offeringAmount, uint256 excessAmount, uint8 indexed pid);

    // Event for new start & end blocks
    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);

    // Event with point parameters for IFO
    event PointParametersSet(uint256 campaignId, uint256 numberPoints, uint256 thresholdPoints);

    // Event when parameters are set for one of the pools
    event PoolParametersSet(uint256 offeringAmountPool, uint256 raisingAmountPool, uint8 pid);

    // Event when released new amount
    event Released(address indexed beneficiary, uint256 amount);

    // Event when revoked
    event Revoked();

    // Modifier to prevent contracts to participate
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    /**
     * @notice Constructor
     */
    constructor() public {
        IFO_FACTORY = msg.sender;
    }

    /**
     * @notice It initializes the contract
     * @dev It can only be called once.
     * @param _lpToken: the LP token used
     * @param _offeringToken: the token that is offered for the IFO
     * @param _pancakeProfileAddress: the address of the PancakeProfile
     * @param _iCakeAddress: the address of the ICake
     * @param _startBlock: the start block for the IFO
     * @param _endBlock: the end block for the IFO
     * @param _maxBufferBlocks: maximum buffer of blocks from the current block number
     * @param _maxPoolId: maximum id of pools, sometimes only public sale exist
     * @param _adminAddress: the admin address for handling tokens
     */
    function initialize(
        address _lpToken,
        address _offeringToken,
        address _pancakeProfileAddress,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _maxBufferBlocks,
        uint8 _maxPoolId,
        address _adminAddress,
        address _iCakeAddress,
        uint256 _pointThreshold,
        address _admissionProfile
    ) public {
        require(!isInitialized, "Operations: Already initialized");
        require(msg.sender == IFO_FACTORY, "Operations: Not factory");
        require(_maxPoolId < NUMBER_POOLS, "Operations: Should not larger than NUMBER_POOLS");

        // Make this contract initialized
        isInitialized = true;

        lpToken = IERC20(_lpToken);
        offeringToken = IERC20(_offeringToken);
        if (_pancakeProfileAddress != address(0)) {
            IPancakeProfile(_pancakeProfileAddress).getTeamProfile(1);
            pancakeProfileAddress = _pancakeProfileAddress;
        }
        if (_iCakeAddress != address(0)) {
            ICake(_iCakeAddress).admin();
            iCakeAddress = _iCakeAddress;
        }
        startBlock = _startBlock;
        endBlock = _endBlock;
        MAX_BUFFER_BLOCKS = _maxBufferBlocks;
        MAX_POOL_ID = _maxPoolId;
        pointThreshold = _pointThreshold;
        admissionProfile = _admissionProfile;

        // Transfer ownership to admin
        transferOwnership(_adminAddress);
    }

    /**
     * @notice It allows users to deposit LP tokens to pool
     * @param _amount: the number of LP token used (18 decimals)
     * @param _pid: pool id
     */
    function depositPool(uint256 _amount, uint8 _pid) external override nonReentrant notContract {
        if (pancakeProfileAddress != address(0)) {
            // Checks whether the user has an active profile
            require(
                IPancakeProfile(pancakeProfileAddress).getUserStatus(msg.sender),
                "Deposit: Must have an active profile"
            );
        }

        // Checks whether the pool id is valid
        require(_pid <= MAX_POOL_ID, "Deposit: Non valid pool id");

        // Checks that pool was set
        require(
            _poolInformation[_pid].offeringAmountPool > 0 && _poolInformation[_pid].raisingAmountPool > 0,
            "Deposit: Pool not set"
        );

        // Checks whether the block number is not too early
        require(block.number > startBlock, "Deposit: Too early");

        // Checks whether the block number is not too late
        require(block.number < endBlock, "Deposit: Too late");

        // Checks that the amount deposited is not inferior to 0
        require(_amount > 0, "Deposit: Amount must be > 0");

        // Verify tokens were deposited properly
        require(offeringToken.balanceOf(address(this)) >= totalTokensOffered, "Deposit: Tokens not deposited properly");

        if (!_poolInformation[_pid].isSpecialSale) {
            if (iCakeAddress != address(0)) {
                // getUserCredit from ICake contract
                uint256 ifoCredit = ICake(iCakeAddress).getUserCredit(msg.sender);
                require(userCreditUsed[msg.sender].add(_amount) <= ifoCredit, "Not enough IFO credit left");
            }

            // Transfers funds to this contract
            lpToken.safeTransferFrom(msg.sender, address(this), _amount);

            // Update the user status
            _userInfo[msg.sender][_pid].amountPool = _userInfo[msg.sender][_pid].amountPool.add(_amount);

            // Check if the pool has a limit per user
            if (_poolInformation[_pid].limitPerUserInLP > 0) {
                // Checks whether the limit has been reached
                require(
                    _userInfo[msg.sender][_pid].amountPool <= _poolInformation[_pid].limitPerUserInLP,
                    "Deposit: New amount above user limit"
                );
            }

            // Updates the totalAmount for pool
            _poolInformation[_pid].totalAmountPool = _poolInformation[_pid].totalAmountPool.add(_amount);

            // Updates Accumulative deposit lpTokens
            userCreditUsed[msg.sender] = userCreditUsed[msg.sender].add(_amount);

            emit Deposit(msg.sender, _amount, _pid);
        } else {
            if (pancakeProfileAddress != address(0)) {
                (
                ,
                uint256 profileNumberPoints,
                ,
                address profileAddress,
                uint256 tokenId,
                bool active
                ) = IPancakeProfile(pancakeProfileAddress).getUserProfile(msg.sender);

                require(active, "profile not active");

                // Must meet one of three admission requirement
                require(
                    _isQualifiedPoints(profileNumberPoints) ||
                    _isQualifiedWhitelist(msg.sender) ||
                    _isQualifiedNFT(msg.sender, profileAddress, tokenId),
                    "Deposit: Not meet any one of required conditions"
                );
            }

            // Transfers funds to this contract
            lpToken.safeTransferFrom(msg.sender, address(this), _amount);

            // Update the user status
            _userInfo[msg.sender][_pid].amountPool = _userInfo[msg.sender][_pid].amountPool.add(_amount);

            // Check if the pool has a limit per user
            if (_poolInformation[_pid].limitPerUserInLP > 0) {
                // Checks whether the limit has been reached
                require(
                    _userInfo[msg.sender][_pid].amountPool <= _poolInformation[_pid].limitPerUserInLP,
                    "Deposit: New amount above user limit"
                );
            }

            // Updates the totalAmount for pool
            _poolInformation[_pid].totalAmountPool = _poolInformation[_pid].totalAmountPool.add(_amount);

            if (pancakeProfileAddress != address(0)) {
                (
                ,
                uint256 profileNumberPoints,
                ,
                address profileAddress,
                uint256 tokenId,
                bool active
                ) = IPancakeProfile(pancakeProfileAddress).getUserProfile(msg.sender);

                // Update tokenIdUsed
                if (
                    !_isQualifiedPoints(profileNumberPoints) &&
                !_isQualifiedWhitelist(msg.sender) &&
                profileAddress == admissionProfile
                ) {
                    if (tokenIdUsed[tokenId] == address(0)) {
                        // update tokenIdUsed
                        tokenIdUsed[tokenId] = msg.sender;
                    } else {
                        require(tokenIdUsed[tokenId] == msg.sender, "Deposit: NFT used by another address already");
                    }
                    if (userNftTokenId[msg.sender] == 0) {
                        // update userNftTokenId
                        userNftTokenId[msg.sender] = tokenId;
                    } else {
                        require(
                            userNftTokenId[msg.sender] == tokenId,
                            "Deposit: NFT tokenId is not the same as registered"
                        );
                    }
                }
            }

            emit Deposit(msg.sender, _amount, _pid);
        }
    }

    /**
     * @notice It allows users to harvest from pool
     * @param _pid: pool id
     */
    function harvestPool(uint8 _pid) external override nonReentrant notContract {
        // Checks whether it is too early to harvest
        require(block.number > endBlock, "Harvest: Too early");

        // Checks whether pool id is valid
        require(_pid <= MAX_POOL_ID, "Harvest: Non valid pool id");

        // Checks whether the user has participated
        require(_userInfo[msg.sender][_pid].amountPool > 0, "Harvest: Did not participate");

        // Checks whether the user has already harvested
        require(!_userInfo[msg.sender][_pid].claimedPool, "Harvest: Already done");

        if (userNftTokenId[msg.sender] != 0) {
            (, , , address profileAddress, uint256 tokenId, bool isActive) = IPancakeProfile(pancakeProfileAddress)
            .getUserProfile(msg.sender);

            require(
                isActive && profileAddress == admissionProfile && userNftTokenId[msg.sender] == tokenId,
                "Harvest: NFT requirements must be met for harvest"
            );
        }

        // Claim points if possible
        _claimPoints(msg.sender);

        // Updates the harvest status
        _userInfo[msg.sender][_pid].claimedPool = true;

        // Updates the vesting startTime
        if (vestingStartTime == 0) {
            vestingStartTime = block.timestamp;
        }

        // Initialize the variables for offering, refunding user amounts, and tax amount
        (
        uint256 offeringTokenAmount,
        uint256 refundingTokenAmount,
        uint256 userTaxOverflow
        ) = _calculateOfferingAndRefundingAmountsPool(msg.sender, _pid);

        // Increment the sumTaxesOverflow
        if (userTaxOverflow > 0) {
            _poolInformation[_pid].sumTaxesOverflow = _poolInformation[_pid].sumTaxesOverflow.add(userTaxOverflow);
        }

        // Transfer these tokens back to the user if quantity > 0
        if (offeringTokenAmount > 0) {
            if (100 - _poolInformation[_pid].vestingPercentage > 0) {
                uint256 amount = offeringTokenAmount.mul(100 - _poolInformation[_pid].vestingPercentage).div(100);

                // Transfer the tokens at TGE
                offeringToken.safeTransfer(msg.sender, amount);

                emit Harvest(msg.sender, amount, refundingTokenAmount, _pid);
            }
            // If this pool is Vesting modal, create a VestingSchedule for each user
            if (_poolInformation[_pid].vestingPercentage > 0) {
                uint256 amount = offeringTokenAmount.mul(_poolInformation[_pid].vestingPercentage).div(100);

                // Create VestingSchedule object
                _createVestingSchedule(msg.sender, _pid, amount);

                emit CreateVestingSchedule(msg.sender, amount, refundingTokenAmount, _pid);
            }
        }

        if (refundingTokenAmount > 0) {
            lpToken.safeTransfer(msg.sender, refundingTokenAmount);
        }
    }

    /**
     * @notice It allows the admin to withdraw funds
     * @param _lpAmount: the number of LP token to withdraw (18 decimals)
     * @param _offerAmount: the number of offering amount to withdraw
     * @dev This function is only callable by admin.
     */
    function finalWithdraw(uint256 _lpAmount, uint256 _offerAmount) external override onlyOwner {
        require(_lpAmount <= lpToken.balanceOf(address(this)), "Operations: Not enough LP tokens");
        require(_offerAmount <= offeringToken.balanceOf(address(this)), "Operations: Not enough offering tokens");

        if (_lpAmount > 0) {
            lpToken.safeTransfer(msg.sender, _lpAmount);
        }

        if (_offerAmount > 0) {
            offeringToken.safeTransfer(msg.sender, _offerAmount);
        }

        emit AdminWithdraw(_lpAmount, _offerAmount);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw (18 decimals)
     * @param _tokenAmount: the number of token amount to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(lpToken), "Recover: Cannot be LP token");
        require(_tokenAddress != address(offeringToken), "Recover: Cannot be offering token");

        IERC20(_tokenAddress).safeTransfer(msg.sender, _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /**
     * @notice It sets parameters for pool
     * @param _offeringAmountPool: offering amount (in tokens)
     * @param _raisingAmountPool: raising amount (in LP tokens)
     * @param _limitPerUserInLP: limit per user (in LP tokens)
     * @param _hasTax: if the pool has a tax
     * @param _pid: pool id
     * @param _isSpecialSale: flag to set is special or public sale
     * @param _vestingPercentage: percentage for vesting remain tokens after end IFO
     * @param _vestingCliff: cliff of vesting
     * @param _vestingDuration: duration of vesting
     * @param _vestingSlicePeriodSeconds: slice period seconds of vesting
     * @dev This function is only callable by admin.
     */
    function setPool(
        uint256 _offeringAmountPool,
        uint256 _raisingAmountPool,
        uint256 _limitPerUserInLP,
        bool _hasTax,
        uint256 _flatTaxRate,
        uint8 _pid,
        bool _isSpecialSale,
        uint256 _vestingPercentage,
        uint256 _vestingCliff,
        uint256 _vestingDuration,
        uint256 _vestingSlicePeriodSeconds
    ) external override onlyOwner {
        require(block.number < startBlock, "Operations: IFO has started");
        require(_pid <= MAX_POOL_ID, "Operations: Pool does not exist");
        require(_flatTaxRate < 1e12, "Operations: Flat tax rate must be less than 1e12");
        require(
            _vestingPercentage >= 0 && _vestingPercentage <= 100,
            "Operations: vesting percentage should exceeds 0 and interior 100"
        );
        require(_vestingDuration > 0, "duration must exceeds 0");
        require(_vestingSlicePeriodSeconds >= 1, "slicePeriodSeconds must be exceeds 1");
        require(_vestingSlicePeriodSeconds <= _vestingDuration, "slicePeriodSeconds must be interior duration");

        _poolInformation[_pid].offeringAmountPool = _offeringAmountPool;
        _poolInformation[_pid].raisingAmountPool = _raisingAmountPool;
        _poolInformation[_pid].limitPerUserInLP = _limitPerUserInLP;
        _poolInformation[_pid].hasTax = _hasTax;
        if (!_hasTax) {
            require(_flatTaxRate == 0, "Operations: hasTax is false, flatTaxRate has to be 0");
        }
        _poolInformation[_pid].flatTaxRate = _flatTaxRate;
        _poolInformation[_pid].isSpecialSale = _isSpecialSale;
        _poolInformation[_pid].vestingPercentage = _vestingPercentage;
        _poolInformation[_pid].vestingCliff = _vestingCliff;
        _poolInformation[_pid].vestingDuration = _vestingDuration;
        _poolInformation[_pid].vestingSlicePeriodSeconds = _vestingSlicePeriodSeconds;

        uint256 tokensDistributedAcrossPools;

        for (uint8 i = 0; i <= MAX_POOL_ID; i++) {
            tokensDistributedAcrossPools = tokensDistributedAcrossPools.add(_poolInformation[i].offeringAmountPool);
        }

        // Update totalTokensOffered
        totalTokensOffered = tokensDistributedAcrossPools;

        emit PoolParametersSet(_offeringAmountPool, _raisingAmountPool, _pid);
    }

    /**
     * @notice It updates point parameters for the IFO.
     * @param _numberPoints: the number of points for the IFO
     * @param _campaignId: the campaignId for the IFO
     * @param _thresholdPoints: the amount of LP required to receive points
     * @dev This function is only callable by admin.
     */
    function updatePointParameters(
        uint256 _campaignId,
        uint256 _numberPoints,
        uint256 _thresholdPoints
    ) external override onlyOwner {
        require(block.number < endBlock, "Operations: IFO has ended");

        numberPoints = _numberPoints;
        campaignId = _campaignId;
        thresholdPoints = _thresholdPoints;

        emit PointParametersSet(campaignId, numberPoints, thresholdPoints);
    }

    /**
     * @notice It allows the admin to update start and end blocks
     * @param _startBlock: the new start block
     * @param _endBlock: the new end block
     * @dev This function is only callable by admin.
     */
    function updateStartAndEndBlocks(uint256 _startBlock, uint256 _endBlock) external onlyOwner {
        require(_endBlock < (block.number + MAX_BUFFER_BLOCKS), "Operations: EndBlock too far");
        require(block.number < startBlock, "Operations: IFO has started");
        require(_startBlock < _endBlock, "Operations: New startBlock must be lower than new endBlock");
        require(block.number < _startBlock, "Operations: New startBlock must be higher than current block");

        startBlock = _startBlock;
        endBlock = _endBlock;

        emit NewStartAndEndBlocks(_startBlock, _endBlock);
    }

    /**
     * @notice It returns the pool information
     * @param _pid: pool id
     * @return raisingAmountPool: amount of LP tokens raised (in LP tokens)
     * @return offeringAmountPool: amount of tokens offered for the pool (in offeringTokens)
     * @return limitPerUserInLP; // limit of tokens per user (if 0, it is ignored)
     * @return hasTax: tax on the overflow (if any, it works with _calculateTaxOverflow)
     * @return flatTaxRate: new rate of flat tax
     * @return totalAmountPool: total amount pool deposited (in LP tokens)
     * @return sumTaxesOverflow: total taxes collected (starts at 0, increases with each harvest if overflow)
     */
    function viewPoolInformation(uint256 _pid)
    external
    view
    override
    returns (
        uint256,
        uint256,
        uint256,
        bool,
        uint256,
        uint256,
        bool
    )
    {
        return (
        _poolInformation[_pid].raisingAmountPool,
        _poolInformation[_pid].offeringAmountPool,
        _poolInformation[_pid].limitPerUserInLP,
        _poolInformation[_pid].hasTax,
        _poolInformation[_pid].totalAmountPool,
        _poolInformation[_pid].sumTaxesOverflow,
        _poolInformation[_pid].isSpecialSale
        );
    }

    /**
     * @notice It returns the pool vesting information
     * @param _pid: pool id
     * @return vestingPercentage: the percentage of vesting part, claimingPercentage + vestingPercentage should be 100
     * @return vestingCliff: the cliff of vesting
     * @return vestingDuration: the duration of vesting
     * @return vestingSlicePeriodSeconds: the slice period seconds of vesting
     */
    function viewPoolVestingInformation(uint256 _pid)
    external
    view
    override
    returns (
        uint256,
        uint256,
        uint256,
        uint256
    )
    {
        return (
        _poolInformation[_pid].vestingPercentage,
        _poolInformation[_pid].vestingCliff,
        _poolInformation[_pid].vestingDuration,
        _poolInformation[_pid].vestingSlicePeriodSeconds
        );
    }

    /**
     * @notice It returns the tax overflow rate calculated for a pool
     * @dev 100,000,000,000 means 0.1 (10%) / 1 means 0.0000000000001 (0.0000001%) / 1,000,000,000,000 means 1 (100%)
     * @param _pid: pool id
     * @return It returns the tax percentage
     */
    function viewPoolTaxRateOverflow(uint256 _pid) external view override returns (uint256) {
        if (!_poolInformation[_pid].hasTax) {
            return 0;
        } else {
            if (_poolInformation[_pid].flatTaxRate > 0) {
                return _poolInformation[_pid].flatTaxRate;
            } else {
                return
                _calculateTaxOverflow(
                    _poolInformation[_pid].totalAmountPool,
                    _poolInformation[_pid].raisingAmountPool
                );
            }
        }
    }

    /**
     * @notice External view function to see user allocations for both pools
     * @param _user: user address
     * @param _pids[]: array of pids
     * @return
     */
    function viewUserAllocationPools(address _user, uint8[] calldata _pids)
    external
    view
    override
    returns (uint256[] memory)
    {
        uint256[] memory allocationPools = new uint256[](_pids.length);
        for (uint8 i = 0; i < _pids.length; i++) {
            allocationPools[i] = _getUserAllocationPool(_user, _pids[i]);
        }
        return allocationPools;
    }

    /**
     * @notice External view function to see user information
     * @param _user: user address
     * @param _pids[]: array of pids
     */
    function viewUserInfo(address _user, uint8[] calldata _pids)
    external
    view
    override
    returns (uint256[] memory, bool[] memory)
    {
        uint256[] memory amountPools = new uint256[](_pids.length);
        bool[] memory statusPools = new bool[](_pids.length);

        for (uint8 i = 0; i <= MAX_POOL_ID; i++) {
            amountPools[i] = _userInfo[_user][i].amountPool;
            statusPools[i] = _userInfo[_user][i].claimedPool;
        }
        return (amountPools, statusPools);
    }

    /**
     * @notice External view function to see user offering and refunding amounts for both pools
     * @param _user: user address
     * @param _pids: array of pids
     */
    function viewUserOfferingAndRefundingAmountsForPools(address _user, uint8[] calldata _pids)
    external
    view
    override
    returns (uint256[3][] memory)
    {
        uint256[3][] memory amountPools = new uint256[3][](_pids.length);

        for (uint8 i = 0; i < _pids.length; i++) {
            uint256 userOfferingAmountPool;
            uint256 userRefundingAmountPool;
            uint256 userTaxAmountPool;

            if (_poolInformation[_pids[i]].raisingAmountPool > 0) {
                (
                userOfferingAmountPool,
                userRefundingAmountPool,
                userTaxAmountPool
                ) = _calculateOfferingAndRefundingAmountsPool(_user, _pids[i]);
            }

            amountPools[i] = [userOfferingAmountPool, userRefundingAmountPool, userTaxAmountPool];
        }
        return amountPools;
    }

    /**
     * @notice Returns the number of vesting schedules associated to a beneficiary
     * @return The number of vesting schedules
     */
    function getVestingSchedulesCountByBeneficiary(address _beneficiary) external view returns (uint256) {
        return holdersVestingCount[_beneficiary];
    }

    /**
     * @notice Returns the vesting schedule id at the given index
     * @return The vesting schedule id
     */
    function getVestingScheduleIdAtIndex(uint256 _index) external view returns (bytes32) {
        require(_index < getVestingSchedulesCount(), "index out of bounds");
        return vestingSchedulesIds[_index];
    }

    /**
     * @notice Returns the vesting schedule information of a given holder and index
     * @return The vesting schedule object
     */
    function getVestingScheduleByAddressAndIndex(address _holder, uint256 _index)
    external
    view
    returns (VestingSchedule memory)
    {
        return getVestingSchedule(computeVestingScheduleIdForAddressAndIndex(_holder, _index));
    }

    /**
     * @notice Returns the total amount of vesting schedules
     * @return The vesting schedule total amount
     */
    function getVestingSchedulesTotalAmount() external view returns (uint256) {
        return vestingSchedulesTotalAmount;
    }

    /**
     * @notice Release vested amount of offering tokens
     * @param _vestingScheduleId the vesting schedule identifier
     */
    function release(bytes32 _vestingScheduleId) external nonReentrant {
        require(vestingSchedules[_vestingScheduleId].isVestingInitialized == true, "vesting schedule is not exist");

        VestingSchedule storage vestingSchedule = vestingSchedules[_vestingScheduleId];
        bool isBeneficiary = msg.sender == vestingSchedule.beneficiary;
        bool isOwner = msg.sender == owner();
        require(isBeneficiary || isOwner, "only the beneficiary and owner can release vested tokens");
        uint256 vestedAmount = _computeReleasableAmount(vestingSchedule);
        require(vestedAmount > 0, "no vested tokens to release");
        vestingSchedule.released = vestingSchedule.released.add(vestedAmount);
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.sub(vestedAmount);
        offeringToken.safeTransfer(vestingSchedule.beneficiary, vestedAmount);

        emit Released(vestingSchedule.beneficiary, vestedAmount);
    }

    /**
     * @notice Revokes all the vesting schedules
     */
    function revoke() external onlyOwner {
        require(!vestingRevoked, "vesting is revoked");

        vestingRevoked = true;

        emit Revoked();
    }

    /**
     * @notice Returns the number of vesting schedules managed by the contract
     * @return The number of vesting count
     */
    function getVestingSchedulesCount() public view returns (uint256) {
        return vestingSchedulesIds.length;
    }

    /**
     * @notice Returns the vested amount of tokens for the given vesting schedule identifier
     * @return The number of vested count
     */
    function computeReleasableAmount(bytes32 _vestingScheduleId) public view returns (uint256) {
        require(vestingSchedules[_vestingScheduleId].isVestingInitialized == true, "vesting schedule is not exist");

        VestingSchedule memory vestingSchedule = vestingSchedules[_vestingScheduleId];
        return _computeReleasableAmount(vestingSchedule);
    }

    /**
     * @notice Returns the vesting schedule information of a given identifier
     * @return The vesting schedule object
     */
    function getVestingSchedule(bytes32 _vestingScheduleId) public view returns (VestingSchedule memory) {
        return vestingSchedules[_vestingScheduleId];
    }

    /**
     * @notice Returns the amount of offering token that can be withdrawn by the owner
     * @return The amount of offering token
     */
    function getWithdrawableOfferingTokenAmount() public view returns (uint256) {
        return offeringToken.balanceOf(address(this)).sub(vestingSchedulesTotalAmount);
    }

    /**
     * @notice Computes the next vesting schedule identifier for a given holder address
     * @return The id string
     */
    function computeNextVestingScheduleIdForHolder(address _holder) public view returns (bytes32) {
        return computeVestingScheduleIdForAddressAndIndex(_holder, holdersVestingCount[_holder]);
    }

    /**
     * @notice Computes the next vesting schedule identifier for an address and an index
     * @return The id string
     */
    function computeVestingScheduleIdForAddressAndIndex(address _holder, uint256 _index) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_holder, _index));
    }

    /**
     * @notice Computes the next vesting schedule identifier for an address and an pid
     * @return The id string
     */
    function computeVestingScheduleIdForAddressAndPid(address _holder, uint256 _pid) external view returns (bytes32) {
        require(_pid <= MAX_POOL_ID, "ComputeVestingScheduleId: Non valid pool id");
        bytes32 vestingScheduleId = computeVestingScheduleIdForAddressAndIndex(_holder, 0);
        VestingSchedule memory vestingSchedule = vestingSchedules[vestingScheduleId];
        if (vestingSchedule.pid == _pid) {
            return vestingScheduleId;
        } else {
            return computeVestingScheduleIdForAddressAndIndex(_holder, 1);
        }
    }

    /**
     * @notice Get current Time
     */
    function getCurrentTime() internal view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @notice Computes the releasable amount of tokens for a vesting schedule
     * @return The amount of releasable tokens
     */
    function _computeReleasableAmount(VestingSchedule memory _vestingSchedule) internal view returns (uint256) {
        uint256 currentTime = getCurrentTime();
        if (currentTime < vestingStartTime + _poolInformation[_vestingSchedule.pid].vestingCliff) {
            return 0;
        } else if (
            currentTime >= vestingStartTime.add(_poolInformation[_vestingSchedule.pid].vestingDuration) ||
            vestingRevoked
        ) {
            return _vestingSchedule.amountTotal.sub(_vestingSchedule.released);
        } else {
            uint256 timeFromStart = currentTime.sub(vestingStartTime);
            uint256 secondsPerSlice = _poolInformation[_vestingSchedule.pid].vestingSlicePeriodSeconds;
            uint256 vestedSlicePeriods = timeFromStart.div(secondsPerSlice);
            uint256 vestedSeconds = vestedSlicePeriods.mul(secondsPerSlice);
            uint256 vestedAmount = _vestingSchedule.amountTotal.mul(vestedSeconds).div(
                _poolInformation[_vestingSchedule.pid].vestingDuration
            );
            vestedAmount = vestedAmount.sub(_vestingSchedule.released);
            return vestedAmount;
        }
    }

    /**
     * @notice Creates a new vesting schedule for a beneficiary
     * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
     * @param _pid the pool id
     * @param _amount total amount of tokens to be released at the end of the vesting
     */
    function _createVestingSchedule(
        address _beneficiary,
        uint8 _pid,
        uint256 _amount
    ) internal {
        require(
            getWithdrawableOfferingTokenAmount() >= _amount,
            "can not create vesting schedule with sufficient tokens"
        );

        bytes32 vestingScheduleId = computeNextVestingScheduleIdForHolder(_beneficiary);
        require(vestingSchedules[vestingScheduleId].beneficiary == address(0), "vestingScheduleId is been created");
        vestingSchedules[vestingScheduleId] = VestingSchedule(true, _beneficiary, _pid, _amount, 0);
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.add(_amount);
        vestingSchedulesIds.push(vestingScheduleId);
        holdersVestingCount[_beneficiary]++;
    }

    /**
     * @notice It allows users to claim points
     * @param _user: user address
     */
    function _claimPoints(address _user) internal {
        if (pancakeProfileAddress != address(0)) {
            if (!_hasClaimedPoints[_user] && numberPoints > 0) {
                uint256 sumPools;
                for (uint8 i = 0; i <= MAX_POOL_ID; i++) {
                    sumPools = sumPools.add(_userInfo[msg.sender][i].amountPool);
                }
                if (sumPools > thresholdPoints) {
                    _hasClaimedPoints[_user] = true;
                    // Increase user points
                    IPancakeProfile(pancakeProfileAddress).increaseUserPoints(msg.sender, numberPoints, campaignId);
                }
            }
        }
    }

    /**
     * @notice It calculates the tax overflow given the raisingAmountPool and the totalAmountPool.
     * @dev 100,000,000,000 means 0.1 (10%) / 1 means 0.0000000000001 (0.0000001%) / 1,000,000,000,000 means 1 (100%)
     * @return It returns the tax percentage
     */
    function _calculateTaxOverflow(uint256 _totalAmountPool, uint256 _raisingAmountPool)
    internal
    pure
    returns (uint256)
    {
        uint256 ratioOverflow = _totalAmountPool.div(_raisingAmountPool);
        if (ratioOverflow >= 1500) {
            return 250000000; // 0.0125%
        } else if (ratioOverflow >= 1000) {
            return 500000000; // 0.05%
        } else if (ratioOverflow >= 500) {
            return 1000000000; // 0.1%
        } else if (ratioOverflow >= 250) {
            return 1250000000; // 0.125%
        } else if (ratioOverflow >= 100) {
            return 1500000000; // 0.15%
        } else if (ratioOverflow >= 50) {
            return 2500000000; // 0.25%
        } else {
            return 5000000000; // 0.5%
        }
    }

    /**
     * @notice It calculates the offering amount for a user and the number of LP tokens to transfer back.
     * @param _user: user address
     * @param _pid: pool id
     * @return {uint256, uint256, uint256} It returns the offering amount, the refunding amount (in LP tokens),
     * and the tax (if any, else 0)
     */
    function _calculateOfferingAndRefundingAmountsPool(address _user, uint8 _pid)
    internal
    view
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        uint256 userOfferingAmount;
        uint256 userRefundingAmount;
        uint256 taxAmount;

        if (_poolInformation[_pid].totalAmountPool > _poolInformation[_pid].raisingAmountPool) {
            // Calculate allocation for the user
            uint256 allocation = _getUserAllocationPool(_user, _pid);

            // Calculate the offering amount for the user based on the offeringAmount for the pool
            userOfferingAmount = _poolInformation[_pid].offeringAmountPool.mul(allocation).div(1e12);

            // Calculate the payAmount
            uint256 payAmount = _poolInformation[_pid].raisingAmountPool.mul(allocation).div(1e12);

            // Calculate the pre-tax refunding amount
            userRefundingAmount = _userInfo[_user][_pid].amountPool.sub(payAmount);

            // Retrieve the tax rate
            if (_poolInformation[_pid].hasTax) {
                uint256 flatTaxRate = _poolInformation[_pid].flatTaxRate;
                if (flatTaxRate > 0) {
                    // Calculate the final taxAmount
                    taxAmount = userRefundingAmount.mul(flatTaxRate).div(1e12);

                    // Adjust the refunding amount
                    userRefundingAmount = userRefundingAmount.sub(taxAmount);
                } else {
                    uint256 taxOverflow = _calculateTaxOverflow(
                        _poolInformation[_pid].totalAmountPool,
                        _poolInformation[_pid].raisingAmountPool
                    );

                    // Calculate the final taxAmount
                    taxAmount = userRefundingAmount.mul(taxOverflow).div(1e12);

                    // Adjust the refunding amount
                    userRefundingAmount = userRefundingAmount.sub(taxAmount);
                }
            }
        } else {
            userRefundingAmount = 0;
            taxAmount = 0;
            // _userInfo[_user] / (raisingAmount / offeringAmount)
            userOfferingAmount = _userInfo[_user][_pid].amountPool.mul(_poolInformation[_pid].offeringAmountPool).div(
                _poolInformation[_pid].raisingAmountPool
            );
        }
        return (userOfferingAmount, userRefundingAmount, taxAmount);
    }

    /**
     * @notice It returns the user allocation for pool
     * @dev 100,000,000,000 means 0.1 (10%) / 1 means 0.0000000000001 (0.0000001%) / 1,000,000,000,000 means 1 (100%)
     * @param _user: user address
     * @param _pid: pool id
     * @return It returns the user's share of pool
     */
    function _getUserAllocationPool(address _user, uint8 _pid) internal view returns (uint256) {
        if (_pid > MAX_POOL_ID) {
            return 0;
        } else {
            if (_poolInformation[_pid].totalAmountPool > 0) {
                return _userInfo[_user][_pid].amountPool.mul(1e18).div(_poolInformation[_pid].totalAmountPool.mul(1e6));
            } else {
                return 0;
            }
        }
    }

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function isQualifiedWhitelist(address _user) external view returns (bool) {
        return isWhitelisted(_user);
    }

    function isQualifiedPoints(address _user) external view returns (bool) {
        if (pancakeProfileAddress == address(0)) {
            return true;
        }
        if (!IPancakeProfile(pancakeProfileAddress).getUserStatus(_user)) {
            return false;
        }

        (, uint256 profileNumberPoints, , , , ) = IPancakeProfile(pancakeProfileAddress).getUserProfile(_user);
        return (pointThreshold != 0 && profileNumberPoints >= pointThreshold);
    }

    function isQualifiedNFT(address _user) external view returns (bool) {
        if (pancakeProfileAddress == address(0)) {
            return true;
        }
        if (!IPancakeProfile(pancakeProfileAddress).getUserStatus(_user)) {
            return false;
        }

        (, , , address profileAddress, uint256 tokenId, ) = IPancakeProfile(pancakeProfileAddress).getUserProfile(
            _user
        );

        return (profileAddress == admissionProfile &&
        (tokenIdUsed[tokenId] == address(0) || tokenIdUsed[tokenId] == _user));
    }

    function _isQualifiedWhitelist(address _user) internal view returns (bool) {
        return isWhitelisted(_user);
    }

    function _isQualifiedPoints(uint256 profileNumberPoints) internal view returns (bool) {
        return (pointThreshold != 0 && profileNumberPoints >= pointThreshold);
    }

    function _isQualifiedNFT(
        address _user,
        address profileAddress,
        uint256 tokenId
    ) internal view returns (bool) {
        return (profileAddress == admissionProfile &&
        (tokenIdUsed[tokenId] == address(0) || tokenIdUsed[tokenId] == _user));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

/** @title IIFOV6.
 * @notice It is an interface for IFOV6.sol
 */
interface IIFOV6 {
    function depositPool(uint256 _amount, uint8 _pid) external;

    function harvestPool(uint8 _pid) external;

    function finalWithdraw(uint256 _lpAmount, uint256 _offerAmount) external;

    function setPool(
        uint256 _offeringAmountPool,
        uint256 _raisingAmountPool,
        uint256 _limitPerUserInLP,
        bool _hasTax,
        uint256 _flatTaxRate,
        uint8 _pid,
        bool _isSpecialSale,
        uint256 _vestingPercentage,
        uint256 _vestingCliff,
        uint256 _vestingDuration,
        uint256 _vestingSlicePeriodSeconds
    ) external;

    function updatePointParameters(
        uint256 _campaignId,
        uint256 _numberPoints,
        uint256 _thresholdPoints
    ) external;

    function viewPoolInformation(uint256 _pid)
    external
    view
    returns (
        uint256,
        uint256,
        uint256,
        bool,
        uint256,
        uint256,
        bool
    );

    function viewPoolVestingInformation(uint256 _pid)
    external
    view
    returns (
        uint256,
        uint256,
        uint256,
        uint256
    );

    function viewPoolTaxRateOverflow(uint256 _pid) external view returns (uint256);

    function viewUserAllocationPools(address _user, uint8[] calldata _pids) external view returns (uint256[] memory);

    function viewUserInfo(address _user, uint8[] calldata _pids)
    external
    view
    returns (uint256[] memory, bool[] memory);

    function viewUserOfferingAndRefundingAmountsForPools(address _user, uint8[] calldata _pids)
    external
    view
    returns (uint256[3][] memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Whitelist is Ownable {
    mapping(address => bool) private whitelist;

    event WhitelistedAddressAdded(address indexed _user);
    event WhitelistedAddressRemoved(address indexed _user);

    /**
     * @dev throws if user is not whitelisted.
     * @param _user address
     */
    modifier onlyIfWhitelisted(address _user) {
        require(whitelist[_user]);
        _;
    }

    /**
     * @dev add single address to whitelist
     */
    function addAddressToWhitelist(address _user) external onlyOwner {
        whitelist[_user] = true;
        emit WhitelistedAddressAdded(_user);
    }

    /**
     * @dev add addresses to whitelist
     */
    function addAddressesToWhitelist(address[] calldata _users) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            whitelist[_users[i]] = true;
            emit WhitelistedAddressAdded(_users[i]);
        }
    }

    /**
     * @dev remove single address from whitelist
     */
    function removeAddressFromWhitelist(address _user) external onlyOwner {
        whitelist[_user] = false;
        emit WhitelistedAddressRemoved(_user);
    }

    /**
     * @dev remove addresses from whitelist
     */
    function removeAddressesFromWhitelist(address[] calldata _users) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            whitelist[_users[i]] = false;
            emit WhitelistedAddressRemoved(_users[i]);
        }
    }

    /**
     * @dev getter to determine if address is in whitelist
     */
    function isWhitelisted(address _user) public view returns (bool) {
        return whitelist[_user];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

/**
 * @title IPancakeProfile
 */
interface IPancakeProfile {
    function createProfile(
        uint256 _teamId,
        address _nftAddress,
        uint256 _tokenId
    ) external;

    function increaseUserPoints(
        address _userAddress,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external;

    function removeUserPoints(address _userAddress, uint256 _numberPoints) external;

    function addNftAddress(address _nftAddress) external;

    function addTeam(string calldata _teamName, string calldata _teamDescription) external;

    function getUserProfile(address _userAddress)
    external
    view
    returns (
        uint256,
        uint256,
        uint256,
        address,
        uint256,
        bool
    );

    function getUserStatus(address _userAddress) external view returns (bool);

    function getTeamProfile(uint256 _teamId)
    external
    view
    returns (
        string memory,
        string memory,
        uint256,
        uint256,
        bool
    );
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/ICaKePool.sol";

contract ICake is Ownable {
    using SafeMath for uint256;

    ICaKePool public immutable cakePool;

    address public admin;
    // threshold of locked duration
    uint256 public ceiling;

    uint256 public constant MIN_CEILING_DURATION = 1 weeks;

    event UpdateCeiling(uint256 newCeiling);

    /**
     * @notice Checks if the msg.sender is the admin address
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "None admin!");
        _;
    }

    /**
     * @notice Constructor
     * @param _cakePool: Cake pool contract
     * @param _admin: admin of the this contract
     * @param _ceiling: the max locked duration which the linear decrease start
     */
    constructor(
        ICaKePool _cakePool,
        address _admin,
        uint256 _ceiling
    ) public {
        require(_ceiling >= MIN_CEILING_DURATION, "Invalid ceiling duration");
        cakePool = _cakePool;
        admin = _admin;
        ceiling = _ceiling;
    }

    /**
     * @notice calculate iCake credit per user.
     * @param _user: user address.
     */
    function getUserCredit(address _user) external view returns (uint256) {
        require(_user != address(0), "getUserCredit: Invalid address");

        ICaKePool.UserInfo memory userInfo = cakePool.userInfo(_user);

        if (!userInfo.locked || block.timestamp > userInfo.lockEndTime) {
            return 0;
        }

        // lockEndTime always >= lockStartTime
        uint256 lockDuration = userInfo.lockEndTime.sub(userInfo.lockStartTime);

        if (lockDuration >= ceiling) {
            return userInfo.lockedAmount;
        } else if (lockDuration < ceiling && lockDuration >= 0) {
            return (userInfo.lockedAmount.mul(lockDuration)).div(ceiling);
        }
    }

    /**
     * @notice update ceiling thereshold duration for iCake calculation.
     * @param _newCeiling: new threshold duration.
     */
    function updateCeiling(uint256 _newCeiling) external onlyAdmin {
        require(_newCeiling >= MIN_CEILING_DURATION, "updateCeiling: Invalid ceiling");
        require(ceiling != _newCeiling, "updateCeiling: Ceiling not changed");
        ceiling = _newCeiling;
        emit UpdateCeiling(ceiling);
    }
}
/**
 *Submitted for verification at BscScan.com on 2020-09-22
*/

pragma solidity 0.6.12;

import "../BEP20.sol";

contract CakeToken is BEP20('PancakeSwap Token', 'Cake') {
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public onlyOwner{
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    /// @notice A record of each accounts delegate
    mapping (address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator)
    external
    view
    returns (address)
    {
        return _delegates[delegator];
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
    * @param delegatee The address to delegate votes to
    */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
    external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "CAKE::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "CAKE::delegateBySig: invalid nonce");
        require(now <= expiry, "CAKE::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account)
    external
    view
    returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber)
    external
    view
    returns (uint256)
    {
        require(blockNumber < block.number, "CAKE::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
    internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying CAKEs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
    internal
    {
        uint32 blockNumber = safe32(block.number, "CAKE::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../BEP20.sol";
import "./CakeToken.sol";

// SyrupBar with Governance.
contract SyrupBar is BEP20('SyrupBar Token', 'SYRUP') {
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function burn(address _from ,uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
        _moveDelegates(address(0), _delegates[_from], _amount);
    }

    // The CAKE TOKEN!
    CakeToken public cake;


    constructor(
        CakeToken _cake
    ) public {
        cake = _cake;
    }

    // Safe cake transfer function, just in case if rounding error causes pool to not have enough CAKEs.
    function safeCakeTransfer(address _to, uint256 _amount) public onlyOwner {
        uint256 cakeBal = cake.balanceOf(address(this));
        if (_amount > cakeBal) {
            cake.transfer(_to, cakeBal);
        } else {
            cake.transfer(_to, _amount);
        }
    }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    /// @notice A record of each accounts delegate
    mapping (address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator)
    external
    view
    returns (address)
    {
        return _delegates[delegator];
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
    * @param delegatee The address to delegate votes to
    */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
    external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "CAKE::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "CAKE::delegateBySig: invalid nonce");
        require(now <= expiry, "CAKE::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account)
    external
    view
    returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber)
    external
    view
    returns (uint256)
    {
        require(blockNumber < block.number, "CAKE::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
    internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying CAKEs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
    internal
    {
        uint32 blockNumber = safe32(block.number, "CAKE::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../BEP20.sol";
import "../SafeBEP20.sol";
import "./CakeToken.sol";
import "./SyrupBar.sol";

interface IMigratorChef {
    // Perform LP token migration from legacy PancakeSwap to CakeSwap.
    // Take the current LP token address and return the new LP token address.
    // Migrator should have full access to the caller's LP token.
    // Return the new LP token address.
    //
    // XXX Migrator must have allowance access to PancakeSwap LP tokens.
    // CakeSwap must mint EXACTLY the same amount of CakeSwap LP tokens or
    // else something bad will happen. Traditional PancakeSwap does not
    // do that so be careful!
    function migrate(IBEP20 token) external returns (IBEP20);
}

// MasterChef is the master of Cake. He can make Cake and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once CAKE is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of CAKEs
        // entitled to a user but is pending to be distributed is:
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accCakePerShare` ( and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. CAKEs to distribute per block.
        uint256 lastRewardBlock; // Last block number that CAKEs distribution occurs.
        uint256 accCakePerShare; // Accumulated CAKEs per share, times 1e12. See below.
    }

    // The CAKE TOKEN!
    CakeToken public cake;
    // The SYRUP TOKEN!
    SyrupBar public syrup;
    // Dev address.
    address public devaddr;
    // CAKE tokens created per block.
    uint256 public cakePerBlock;
    // Bonus muliplier for early cake markers.
    uint256 public BONUS_MULTIPLIER = 1;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorChef public migrator;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when CAKE mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        CakeToken _cake,
        SyrupBar _syrup,
        address _devaddr,
        uint256 _cakePerBlock,
        uint256 _startBlock
    ) public {
        cake = _cake;
        syrup = _syrup;
        devaddr = _devaddr;
        cakePerBlock = _cakePerBlock;
        startBlock = _startBlock;

        // staking pool
        poolInfo.push(PoolInfo({lpToken: _cake, allocPoint: 1000, lastRewardBlock: startBlock, accCakePerShare: 0}));

        totalAllocPoint = 1000;
    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IBEP20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({lpToken: _lpToken, allocPoint: _allocPoint, lastRewardBlock: lastRewardBlock, accCakePerShare: 0})
        );
        updateStakingPool();
    }

    // Update the given pool's CAKE allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
            updateStakingPool();
        }
    }

    function updateStakingPool() internal {
        uint256 length = poolInfo.length;
        uint256 points = 0;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points.add(poolInfo[pid].allocPoint);
        }
        if (points != 0) {
            points = points.div(3);
            totalAllocPoint = totalAllocPoint.sub(poolInfo[0].allocPoint).add(points);
            poolInfo[0].allocPoint = points;
        }
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IBEP20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IBEP20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending CAKEs on frontend.
    function pendingCake(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accCakePerShare = pool.accCakePerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 cakeReward = multiplier.mul(cakePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accCakePerShare = accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 cakeReward = multiplier.mul(cakePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        cake.mint(devaddr, cakeReward.div(10));
        cake.mint(address(syrup), cakeReward);
        pool.accCakePerShare = pool.accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for CAKE allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        require(_pid != 0, "deposit CAKE by staking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);

            if (pending > 0) {
                safeCakeTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        require(_pid != 0, "withdraw CAKE by unstaking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);

        if (pending > 0) {
            safeCakeTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Stake CAKE tokens to MasterChef
    function enterStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeCakeTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);

        syrup.mint(msg.sender, _amount);
        emit Deposit(msg.sender, 0, _amount);
    }

    // Withdraw CAKE tokens from STAKING.
    function leaveStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeCakeTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);

        syrup.burn(msg.sender, _amount);
        emit Withdraw(msg.sender, 0, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Safe cake transfer function, just in case if rounding error causes pool to not have enough CAKEs.
    function safeCakeTransfer(address _to, uint256 _amount) internal {
        syrup.safeCakeTransfer(_to, _amount);
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface ICaKePool {
    struct UserInfo {
        uint256 shares;
        uint256 lastDepositedTime;
        uint256 cakeAtLastUserAction;
        uint256 lastUserActionTime;
        uint256 lockStartTime;
        uint256 lockEndTime;
        uint256 userBoostedShare;
        bool locked;
        uint256 lockedAmount;
    }

    function userInfo(address _user) external view returns (UserInfo memory);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/IBEP20.sol";

contract BEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view override returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance")
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero")
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance")
        );
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
   */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
   */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interfaces/IBEP20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
   * {IBEP20-approve}, and its usage is discouraged.
   *
   * Whenever possible, use {safeIncreaseAllowance} and
   * {safeDecreaseAllowance} instead.
   */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
        token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
   * on the return value: the return value is optional (but if data is returned, it must not be false).
   * @param token The token targeted by the call.
   * @param data The call data (encoded using abi.encode or one of its variants).
   */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata =
        address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}
