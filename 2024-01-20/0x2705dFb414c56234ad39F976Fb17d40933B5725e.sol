// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Campaign.sol";
import "./CloneFactory.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract CampaignFactory {
    address payable public immutable owner;
    address public recipient;
    mapping(string => address) public campaigns;
    address public campaignContract;
    CloneFactory public immutable CloneContract;

    // in US cents
    uint256 private deposit = 33300;

    // in US cents
    uint256 private fee = 100;

    IPyth pyth;
    bytes32 priceId;

    constructor(address _pythAddress, bytes32 _priceId) {
        owner = payable(msg.sender);
        pyth = IPyth(_pythAddress);
        priceId = _priceId;
        CloneContract = new CloneFactory();
        campaignContract = address(new Campaign(owner, address(this)));
        recipient = owner;
    }

    event campaignCreated(address campaignContractAddress);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
    uint constant MINIMUM_UNIT_EXPO = 18;

    function getTokenPricePerCent(
        bytes[] memory pythUpdateData
    ) public payable returns (uint256 price_per_cent) {
        uint256 updateFee = pyth.getUpdateFee(pythUpdateData);
        require(msg.value - updateFee >= 0, "insufficient fee");
        pyth.updatePriceFeeds{value: updateFee}(pythUpdateData);
        PythStructs.Price memory tokenPriceInUSD = pyth.getPrice(priceId);
        require(tokenPriceInUSD.price > 0, "price should be greater than 0");

        uint expo;
        if (tokenPriceInUSD.expo < 0) {
            expo = MINIMUM_UNIT_EXPO + uint(uint32(-tokenPriceInUSD.expo));
        } else {
            expo = MINIMUM_UNIT_EXPO - uint(uint32(tokenPriceInUSD.expo));
        }
        uint unitPerCent = 10 ** (expo - 2) /
            uint(uint64(tokenPriceInUSD.price));
        return unitPerCent;
    }

    function createCampaign(
        uint256 _chainId,
        string memory _campaignId,
        address _prizeAddress,
        uint256 _prizeAmount,
        uint256 _maxEntries,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        bytes32 _sealedSeed,
        bytes32 r,
        bytes32 s,
        uint8 v,
        bytes[] memory pythUpdateData
    ) public payable {
        require(
            campaigns[_campaignId] == address(0),
            "Campaign with this id already exists"
        );
        require(
            _chainId == block.chainid,
            "The chainID you want to deploy is different"
        );

        bytes32 message = hashMessage(
            msg.sender,
            _chainId,
            _campaignId,
            _prizeAddress,
            _prizeAmount,
            _maxEntries,
            _startTimestamp,
            _endTimestamp,
            _sealedSeed
        );

        require(
            ecrecover(message, v, r, s) == owner,
            "You need signatures from the owner to create a campaign"
        );

        uint256 price_per_cent = getTokenPricePerCent(pythUpdateData);

        address campaign = CloneContract.createClone(campaignContract);
        Campaign(campaign).initialize(
            msg.sender,
            _campaignId,
            _prizeAddress,
            _prizeAmount,
            _maxEntries,
            _startTimestamp,
            _endTimestamp,
            _sealedSeed,
            deposit * price_per_cent,
            fee * price_per_cent
        );

        campaigns[_campaignId] = campaign;
        emit campaignCreated(campaign);
    }

    function setDepositAmount(uint256 _deposit) public onlyOwner {
        deposit = _deposit;
    }

    function getDepositAmount() public view returns (uint256) {
        return deposit;
    }

    function setFeeAmount(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function getFeeAmount() public view returns (uint256) {
        return fee;
    }

    function hashMessage(
        address _campaignOwner,
        uint256 _chainId,
        string memory _campaignId,
        address _prizeAddress,
        uint256 _prizeAmount,
        uint256 _maxEntries,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        bytes32 _sealedSeed
    ) public view returns (bytes32) {
        bytes memory pack = abi.encodePacked(
            this,
            _campaignOwner,
            _chainId,
            _campaignId,
            _prizeAddress,
            _prizeAmount,
            _maxEntries,
            _startTimestamp,
            _endTimestamp,
            _sealedSeed
        );
        return keccak256(pack);
    }

    function getCampaignContractAddress(
        string memory _campaignId
    ) public view returns (address) {
        return campaigns[_campaignId];
    }

    function setRecipientAddress(address _recipient) public onlyOwner {
        recipient = _recipient;
    }

    function setCampaignContract(address _campaignContract) public onlyOwner {
        campaignContract = _campaignContract;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

interface ICampaignFactory {
    function recipient() external view returns (address);
}

contract Campaign is Initializable {
    bool public initialized;
    string public campaignId;
    address immutable owner;
    address immutable factory;
    address public campaignOwner;
    address public prizeAddress;
    uint256 public prizeAmount;
    uint256 public maxEntries;
    uint256 public startTimestamp;
    uint256 public endTimestamp;
    bytes32 private sealedSeed;
    uint256 private feeAmount;
    uint256 private depositAmount;

    uint256 private campaignOwnersContribution;
    uint256 private campaignOwnersContributionTotal;

    bytes32 public revealedSeed;

    mapping(address => bool) private freeEntry;
    mapping(address => address) private chain;
    mapping(uint256 => address) private cursorMap;

    uint256 public length;

    uint256 private rattleRandom;
    bool private cancelled;
    bool private depositReceived;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier onlyCampaignOwner() {
        require(
            msg.sender == campaignOwner,
            "Caller is not the campaign owner"
        );
        _;
    }

    constructor(address _owner, address _factory) {
        owner = _owner;
        factory = _factory;
    }

    function initialize(
        address _campaignOwner,
        string memory _campaignId,
        address _prizeAddress,
        uint256 _prizeAmount,
        uint256 _maxEntries,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        bytes32 _sealedSeed,
        uint256 _deposit,
        uint256 _fee
    ) external initializer {
        campaignOwner = _campaignOwner;
        campaignId = _campaignId;
        prizeAddress = _prizeAddress;
        prizeAmount = _prizeAmount;
        maxEntries = _maxEntries;
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
        sealedSeed = _sealedSeed;
        rattleRandom = uint256(_sealedSeed);
        feeAmount = _fee;
        depositAmount =  _deposit;
    }

    event CampaignCreated(
        address campaignAddress,
        address campaignOwner,
        string campaignId,
        address prizeAddress,
        uint256 prizeAmount,
        uint256 maxEntries,
        uint256 startTimestamp,
        uint256 endTimestamp
    );

    function getDetail()
        public
        view
        returns (
            address _campaignOwner,
            string memory _campaignId,
            address _prizeAddress,
            uint256 _prizeAmount,
            uint256 _maxEntries,
            uint256 _startTimestamp,
            uint256 _endTimestamp,
            uint256 _entryCount
        )
    {
        return (
            campaignOwner,
            campaignId,
            prizeAddress,
            prizeAmount,
            maxEntries,
            startTimestamp,
            endTimestamp,
            length
        );
    }

    function hashMessage(address _user, uint256 _timestamp)
        public
        view
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(this, _user, _timestamp));
    }

    function isStarted() public view returns (bool) {
        return block.timestamp >= startTimestamp;
    }

    function isNotClosed() public view returns (bool) {
        return block.timestamp < endTimestamp;
    }

    function isNotFull() public view returns (bool) {
        return length < maxEntries;
    }

    function isCancelled() public view returns (bool) {
        return cancelled;
    }

    function isDepositReceived() public view returns (bool) {
        return depositReceived;
    }

    function hasEntered(address _user) public view returns (bool) {
        return chain[_user] != address(0);
    }

    function getFreeDrawRemaining() public view returns (uint256) {
        return (feeAmount > 0) ? (campaignOwnersContribution / feeAmount) : 0;
    }

    function getStatus()
        public
        view
        returns (
            bool _hasEntered,
            bool _isStarted,
            bool _isNotClosed,
            bool _isRevealed,
            bool _isDepositReceived,
            bool _isCancelled,
            uint256 _totalEntries,
            uint256 _maxEntries,
            uint256 _fee,
            uint256 _freeDrawRemaining
        )
    {
        return (
            hasEntered(msg.sender),
            isStarted(),
            isNotClosed(),
            isRevealed(),
            isDepositReceived(),
            isCancelled(),
            length,
            maxEntries,
            feeAmount,
            getFreeDrawRemaining()
        );
    }

    function getFee() public view returns (uint256) {
        return feeAmount;
    }

    function setFeeZero() public onlyOwner {
        require(!isStarted(), "Campaign has started");
        feeAmount = 0;
        if (campaignOwnersContribution > 0) {
            payable(campaignOwner).transfer(campaignOwnersContribution);
            campaignOwnersContribution = 0;
        }
    }

    function getEntryCount() public view returns (uint256) {
        return length;
    }

    function deposit() public payable onlyCampaignOwner {
        require(!depositReceived, "Deposit has already been received");
        require(!isCancelled(), "Campaign has been cancelled");
        require(isNotClosed(), "Campaign has ended");
        require(msg.value >= depositAmount, "You need to pay the deposit");
        depositReceived = true;
        if (msg.value > depositAmount) {
            payable(msg.sender).transfer(msg.value - depositAmount);
        }
    }

    function getDepositAmount() public view returns (uint256) {
        return depositAmount;
    }

    function setCampaignOwnersContribution() public payable onlyCampaignOwner {
        require(!isCancelled(), "Campaign has been cancelled");
        require(isNotClosed(), "Campaign has ended");
        require(
            campaignOwnersContribution + msg.value <= maxEntries * feeAmount,
            "You cannot contribute more than the maximum amount"
        );
        campaignOwnersContribution += msg.value;
    }

    function getCampaignOwnersContribution() public view returns (uint256) {
        return campaignOwnersContribution;
    }

    function isFreeDraw() public view returns (bool) {
        return campaignOwnersContribution >= feeAmount;
    }

    function isRevealed() public view returns (bool) {
        return revealedSeed != 0;
    }

    function setEntry(
        uint256 _timestamp,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public payable {
        require(isNotFull(), "Already reached the maximum number of entries");
        require(isStarted(), "Campaign has not started yet");
        require(isNotClosed(), "Campaign has ended");
        require(!isCancelled(), "Campaign has been cancelled");
        require(
            _timestamp + 5 minutes > block.timestamp,
            "Timestamp is not valid"
        );
        require(chain[msg.sender] == address(0), "You have already entered");

        bytes32 message = hashMessage(msg.sender, _timestamp);

        require(
            ecrecover(message, v, r, s) == owner,
            "You need signatures from the owner to set an entry"
        );

        if (isFreeDraw()) {
            require(
                freeEntry[msg.sender] == false,
                "You have already used your free draw"
            );
            freeEntry[msg.sender] = true;
            campaignOwnersContribution -= feeAmount;
            campaignOwnersContributionTotal += feeAmount;
        } else {
            require(
                msg.value >= feeAmount,
                "You need to pay the entry fee to enter"
            );
        }

        uint256 rand = uint256(
            keccak256(abi.encodePacked(message, rattleRandom, length))
        );

        if (length == 0) {
            chain[msg.sender] = msg.sender;
            cursorMap[0] = msg.sender;
        } else {
            address cursor = cursorMap[rand % length];
            chain[msg.sender] = chain[cursor];
            chain[cursor] = msg.sender;
            cursorMap[length] = msg.sender;
        }
        length++;
        rattleRandom = rand;
    }

    function withdrawAll() public onlyOwner {
        require(
            endTimestamp + 365 days < block.timestamp,
            "Campaign has not ended yet"
        );
        payable(ICampaignFactory(factory).recipient()).transfer(
            address(this).balance
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "transfer failed"
        );
    }

    function recoverERC20(address _tokenAddress) public onlyOwner {
        uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));
        safeTransfer(_tokenAddress, owner, balance);
    }

    function getPaybackAmount() public view returns (uint256) {
        return (length * feeAmount) / 2;
    }

    function payback() public payable onlyCampaignOwner {
        require(!isCancelled(), "Campaign has been cancelled already");
        require(revealedSeed == 0, "Campaign has already been revealed");

        require(
            msg.value >= getPaybackAmount(),
            "You need to pay 1/2 of the fee that user paid"
        );

        uint256 campaignOwnersBack = isDepositReceived() ? depositAmount : 0;
        depositReceived = false;
        cancelled = true;
        campaignOwnersBack += campaignOwnersContributionTotal;
        campaignOwnersBack += campaignOwnersContribution;
        campaignOwnersBack += msg.value - getPaybackAmount();
        payable(ICampaignFactory(factory).recipient()).transfer(msg.value);
        payable(campaignOwner).transfer(campaignOwnersBack);
    }

    function paybackWithdraw() public {
        require(isCancelled(), "Campaign has not been cancelled");
        require(
            chain[msg.sender] != address(0) && !freeEntry[msg.sender],
            "You don't have right to withdraw"
        );
        chain[msg.sender] = address(0);
        payable(msg.sender).transfer(feeAmount);
    }

    function revealSeed(bytes32 _seed) public {
        require(!isNotClosed(), "Campaign has not ended yet");
        require(!isCancelled(), "Campaign has been cancelled");
        require(revealedSeed == 0, "Seed has already been revealed");
        require(
            block.timestamp > endTimestamp + 7 days ||
                msg.sender == campaignOwner,
            "You can not reveal the seed"
        );
        require(
            keccak256(abi.encodePacked(campaignId, _seed)) == sealedSeed,
            "Seed is not correct"
        );
        revealedSeed = _seed;
        rattleRandom = uint256(
            keccak256(abi.encodePacked(_seed, rattleRandom))
        );
        if (isDepositReceived()) {
            depositReceived = false;
            payable(msg.sender).transfer(depositAmount);
        }
        if (campaignOwnersContribution > 0) {
            uint256 back = campaignOwnersContribution;
            campaignOwnersContribution = 0;
            payable(campaignOwner).transfer(back);
        }
        payable(ICampaignFactory(factory).recipient()).transfer(
            address(this).balance
        );
    }

    function canDraw() public view returns (bool) {
        return revealedSeed > 0;
    }

    function draw() public view returns (address[] memory _winners) {
        require(canDraw(), "Seed has not been confirmed yet");

        address[] memory winners = new address[](prizeAmount);
        uint256 winnerNum = prizeAmount < length ? prizeAmount : length;
        address cursor = cursorMap[rattleRandom % length];
        for (uint256 i = 0; i < winnerNum; i++) {
            winners[i] = chain[cursor];
            cursor = chain[cursor];
        }
        for (uint256 i = winnerNum; i < prizeAmount; i++) {
            winners[i] = campaignOwner;
        }

        return winners;
    }

    function showSubstituteElected(uint256 _substitute)
        public
        view
        returns (address[] memory _substitutes)
    {
        require(canDraw(), "Seed has not been confirmed yet");
        require(prizeAmount < length, "Substitute election is not needed");

        address[] memory substitutes = new address[](_substitute);
        address cursor = cursorMap[rattleRandom % length];
        for (uint256 i = 0; i < prizeAmount; i++) {
            cursor = chain[cursor];
        }
        for (uint256 i = 0; i < _substitute; i++) {
            substitutes[i] = chain[cursor];
            cursor = chain[cursor];
        }
        return substitutes;
    }
}
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

contract CloneFactory {
    function createClone(address target) public returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }

    function isClone(address target, address query)
        public
        view
        returns (bool result)
    {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000
            )
            mstore(add(clone, 0xa), targetBytes)
            mstore(
                add(clone, 0x1e),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./PythStructs.sol";
import "./IPythEvents.sol";

/// @title Consume prices from the Pyth Network (https://pyth.network/).
/// @dev Please refer to the guidance at https://docs.pyth.network/documentation/pythnet-price-feeds/best-practices for how to consume prices safely.
/// @author Pyth Data Association
interface IPyth is IPythEvents {
    /// @notice Returns the period (in seconds) that a price feed is considered valid since its publish time
    function getValidTimePeriod() external view returns (uint validTimePeriod);

    /// @notice Returns the price and confidence interval.
    /// @dev Reverts if the price has not been updated within the last `getValidTimePeriod()` seconds.
    /// @param id The Pyth Price Feed ID of which to fetch the price and confidence interval.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getPrice(
        bytes32 id
    ) external view returns (PythStructs.Price memory price);

    /// @notice Returns the exponentially-weighted moving average price and confidence interval.
    /// @dev Reverts if the EMA price is not available.
    /// @param id The Pyth Price Feed ID of which to fetch the EMA price and confidence interval.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getEmaPrice(
        bytes32 id
    ) external view returns (PythStructs.Price memory price);

    /// @notice Returns the price of a price feed without any sanity checks.
    /// @dev This function returns the most recent price update in this contract without any recency checks.
    /// This function is unsafe as the returned price update may be arbitrarily far in the past.
    ///
    /// Users of this function should check the `publishTime` in the price to ensure that the returned price is
    /// sufficiently recent for their application. If you are considering using this function, it may be
    /// safer / easier to use either `getPrice` or `getPriceNoOlderThan`.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getPriceUnsafe(
        bytes32 id
    ) external view returns (PythStructs.Price memory price);

    /// @notice Returns the price that is no older than `age` seconds of the current time.
    /// @dev This function is a sanity-checked version of `getPriceUnsafe` which is useful in
    /// applications that require a sufficiently-recent price. Reverts if the price wasn't updated sufficiently
    /// recently.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getPriceNoOlderThan(
        bytes32 id,
        uint age
    ) external view returns (PythStructs.Price memory price);

    /// @notice Returns the exponentially-weighted moving average price of a price feed without any sanity checks.
    /// @dev This function returns the same price as `getEmaPrice` in the case where the price is available.
    /// However, if the price is not recent this function returns the latest available price.
    ///
    /// The returned price can be from arbitrarily far in the past; this function makes no guarantees that
    /// the returned price is recent or useful for any particular application.
    ///
    /// Users of this function should check the `publishTime` in the price to ensure that the returned price is
    /// sufficiently recent for their application. If you are considering using this function, it may be
    /// safer / easier to use either `getEmaPrice` or `getEmaPriceNoOlderThan`.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getEmaPriceUnsafe(
        bytes32 id
    ) external view returns (PythStructs.Price memory price);

    /// @notice Returns the exponentially-weighted moving average price that is no older than `age` seconds
    /// of the current time.
    /// @dev This function is a sanity-checked version of `getEmaPriceUnsafe` which is useful in
    /// applications that require a sufficiently-recent price. Reverts if the price wasn't updated sufficiently
    /// recently.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getEmaPriceNoOlderThan(
        bytes32 id,
        uint age
    ) external view returns (PythStructs.Price memory price);

    /// @notice Update price feeds with given update messages.
    /// This method requires the caller to pay a fee in wei; the required fee can be computed by calling
    /// `getUpdateFee` with the length of the `updateData` array.
    /// Prices will be updated if they are more recent than the current stored prices.
    /// The call will succeed even if the update is not the most recent.
    /// @dev Reverts if the transferred fee is not sufficient or the updateData is invalid.
    /// @param updateData Array of price update data.
    function updatePriceFeeds(bytes[] calldata updateData) external payable;

    /// @notice Wrapper around updatePriceFeeds that rejects fast if a price update is not necessary. A price update is
    /// necessary if the current on-chain publishTime is older than the given publishTime. It relies solely on the
    /// given `publishTimes` for the price feeds and does not read the actual price update publish time within `updateData`.
    ///
    /// This method requires the caller to pay a fee in wei; the required fee can be computed by calling
    /// `getUpdateFee` with the length of the `updateData` array.
    ///
    /// `priceIds` and `publishTimes` are two arrays with the same size that correspond to senders known publishTime
    /// of each priceId when calling this method. If all of price feeds within `priceIds` have updated and have
    /// a newer or equal publish time than the given publish time, it will reject the transaction to save gas.
    /// Otherwise, it calls updatePriceFeeds method to update the prices.
    ///
    /// @dev Reverts if update is not needed or the transferred fee is not sufficient or the updateData is invalid.
    /// @param updateData Array of price update data.
    /// @param priceIds Array of price ids.
    /// @param publishTimes Array of publishTimes. `publishTimes[i]` corresponds to known `publishTime` of `priceIds[i]`
    function updatePriceFeedsIfNecessary(
        bytes[] calldata updateData,
        bytes32[] calldata priceIds,
        uint64[] calldata publishTimes
    ) external payable;

    /// @notice Returns the required fee to update an array of price updates.
    /// @param updateData Array of price update data.
    /// @return feeAmount The required fee in Wei.
    function getUpdateFee(
        bytes[] calldata updateData
    ) external view returns (uint feeAmount);

    /// @notice Parse `updateData` and return price feeds of the given `priceIds` if they are all published
    /// within `minPublishTime` and `maxPublishTime`.
    ///
    /// You can use this method if you want to use a Pyth price at a fixed time and not the most recent price;
    /// otherwise, please consider using `updatePriceFeeds`. This method does not store the price updates on-chain.
    ///
    /// This method requires the caller to pay a fee in wei; the required fee can be computed by calling
    /// `getUpdateFee` with the length of the `updateData` array.
    ///
    ///
    /// @dev Reverts if the transferred fee is not sufficient or the updateData is invalid or there is
    /// no update for any of the given `priceIds` within the given time range.
    /// @param updateData Array of price update data.
    /// @param priceIds Array of price ids.
    /// @param minPublishTime minimum acceptable publishTime for the given `priceIds`.
    /// @param maxPublishTime maximum acceptable publishTime for the given `priceIds`.
    /// @return priceFeeds Array of the price feeds corresponding to the given `priceIds` (with the same order).
    function parsePriceFeedUpdates(
        bytes[] calldata updateData,
        bytes32[] calldata priceIds,
        uint64 minPublishTime,
        uint64 maxPublishTime
    ) external payable returns (PythStructs.PriceFeed[] memory priceFeeds);

    /// @notice Similar to `parsePriceFeedUpdates` but ensures the updates returned are
    /// the first updates published in minPublishTime. That is, if there are multiple updates for a given timestamp,
    /// this method will return the first update.
    ///
    ///
    /// @dev Reverts if the transferred fee is not sufficient or the updateData is invalid or there is
    /// no update for any of the given `priceIds` within the given time range and uniqueness condition.
    /// @param updateData Array of price update data.
    /// @param priceIds Array of price ids.
    /// @param minPublishTime minimum acceptable publishTime for the given `priceIds`.
    /// @param maxPublishTime maximum acceptable publishTime for the given `priceIds`.
    /// @return priceFeeds Array of the price feeds corresponding to the given `priceIds` (with the same order).
    function parsePriceFeedUpdatesUnique(
        bytes[] calldata updateData,
        bytes32[] calldata priceIds,
        uint64 minPublishTime,
        uint64 maxPublishTime
    ) external payable returns (PythStructs.PriceFeed[] memory priceFeeds);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

contract PythStructs {
    // A price with a degree of uncertainty, represented as a price +- a confidence interval.
    //
    // The confidence interval roughly corresponds to the standard error of a normal distribution.
    // Both the price and confidence are stored in a fixed-point numeric representation,
    // `x * (10^expo)`, where `expo` is the exponent.
    //
    // Please refer to the documentation at https://docs.pyth.network/documentation/pythnet-price-feeds/best-practices for how
    // to how this price safely.
    struct Price {
        // Price
        int64 price;
        // Confidence interval around the price
        uint64 conf;
        // Price exponent
        int32 expo;
        // Unix timestamp describing when the price was published
        uint publishTime;
    }

    // PriceFeed represents a current aggregate price from pyth publisher feeds.
    struct PriceFeed {
        // The price ID.
        bytes32 id;
        // Latest available price
        Price price;
        // Latest available exponentially-weighted moving average price
        Price emaPrice;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @title IPythEvents contains the events that Pyth contract emits.
/// @dev This interface can be used for listening to the updates for off-chain and testing purposes.
interface IPythEvents {
    /// @dev Emitted when the price feed with `id` has received a fresh update.
    /// @param id The Pyth Price Feed ID.
    /// @param publishTime Publish time of the given price update.
    /// @param price Price of the given price update.
    /// @param conf Confidence interval of the given price update.
    event PriceFeedUpdate(
        bytes32 indexed id,
        uint64 publishTime,
        int64 price,
        uint64 conf
    );

    /// @dev Emitted when a batch price update is processed successfully.
    /// @param chainId ID of the source chain that the batch price update comes from.
    /// @param sequenceNumber Sequence number of the batch price update.
    event BatchPriceFeedUpdate(uint16 chainId, uint64 sequenceNumber);
}
