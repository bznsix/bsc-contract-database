// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./OriginBytesCode.sol";
import "./abstracts/AOriginFactory.sol";
import "./abstracts/AOriginStrategy.sol";
import "../../registry/IAlphaRegistry.sol";
import "../../registry/IDAOManagers.sol";
import "../../constants/ProposalStatus.sol";
import "../modules/tokenPrices/ITokenPricesModule.sol";

contract OriginFactory is AOriginFactory {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address internal DAOManagerAddress;
    address internal bytesCodeAddress;
    ITokenPricesModule internal tokenPricesModule;

    bytes internal strategyCode;

    mapping(address /*ProposalAddress*/ => FundStruct[] /*Funds*/) internal proposalFunds;
    mapping(address /*InvestorAddress*/ => FundStruct[] /*Funds*/) internal investorFunds;
    
    address internal alphaRegistry;

    address[] dexSwapAddress;

    address[] authorizedTokens;

    modifier onlyAlphaRegistry() {
        require(alphaRegistry == msg.sender, '401: onlyAlphaRegistry');
        _;
    }

    modifier checkRiskyAmount(uint256 riskyAmount) {
        require(riskyAmount >= 10 ether, "riskyAmount >= 10 USD");
        _;
    }

    constructor(
        address alphaRegistryAddress,
        address bytesCodeAddress_,
        address DAOManagerAddress_,
        address _tokenPricesModule,

        address[] memory authorizedTokens_,
        address[] memory dexSwapAddress_
    ) {
        require(authorizedTokens_.length <= 50, "401: !authorizedTokens Too Long");

        tokenPricesModule = ITokenPricesModule(_tokenPricesModule);
        alphaRegistry = alphaRegistryAddress;
        bytesCodeAddress = bytesCodeAddress_;
        DAOManagerAddress = DAOManagerAddress_;

        authorizedTokens = authorizedTokens_;
        dexSwapAddress = dexSwapAddress_;

        for (uint i = 0; i < authorizedTokens_.length; i++) {
            tokenPricesModule.getTokenPrice(authorizedTokens_[i]);
        }

        emit AddAuthorizedTokensEvent(authorizedTokens);
    }

    function validateAuthTokens(address[] memory authorizedTokens_) public view {
        for (uint i = 0; i < authorizedTokens_.length; i++) {
            tokenPricesModule.getTokenPrice(authorizedTokens_[i]);
        }
    }

    function _deploy(
        OriginProposalStruct memory proposal
    ) internal checkRiskyAmount(proposal.riskyAmount) returns (address) {
        address strategyAddress = OriginBytesCode(bytesCodeAddress).deploy(proposal.proposalId);

        proposal.strategyAddress = strategyAddress;

        AOriginStrategy(strategyAddress).initialize(dexSwapAddress, authorizedTokens, proposal);

        emit InitializeStrategyEvent(proposal.proposalId, proposal.strategyAddress, proposal);

        return strategyAddress;
    }

    function getProposalFunds(address proposalAddress) view external returns (FundStruct[] memory){
        return proposalFunds[proposalAddress];
    }

    function getInvestorFunds(address investorAddress) view external  override returns (FundStruct[] memory){
        return investorFunds[investorAddress];
    }

    function getInvestorFundedAmountByProposal(
        address strategyAddress,
        address investorAddress
    ) external view override returns (uint256) {
        return _getInvestorFundedAmountByProposal(strategyAddress, investorAddress);
    }

    function runStopLoss(
        address strategyAddress_,
        SwapPathStruct[] memory pathTokens_
    ) external override {
        IDAOManagers iDAOManagers = IDAOManagers(DAOManagerAddress);
        require(iDAOManagers.isStopLossAdmin(msg.sender), "401: !stopLossAdmin");

        AOriginStrategy originStrategy = AOriginStrategy(strategyAddress_);
        OriginProposalStruct memory _proposal = originStrategy.getProposal();
        require(_proposal.status == LIVE, "404: !live proposal");

        FundStruct[] memory _fundInvestors = proposalFunds[strategyAddress_];
        originStrategy.runStopLoss(strategyAddress_, pathTokens_, _fundInvestors);

        IAlphaRegistry alphaRegistryContract = IAlphaRegistry(alphaRegistry);
        
        _proposal = originStrategy.getProposal();
        alphaRegistryContract.finishProposal(_getProposalStruct(_proposal));

        emit TriggerStopLossEvent(_proposal.proposalId, _proposal.strategyAddress, _proposal);
    }

    function distribute(address strategyAddress_, SwapPathStruct[] memory swapPaths_) external override {
        require(strategyAddress_.isContract(), "403: Invalid proposal");
        
        OriginProposalStruct memory _proposal = AOriginStrategy(strategyAddress_).getProposal();
        require(_proposal.status == LIVE, "404: !live proposal");

        FundStruct[] memory _fundInvestors = proposalFunds[strategyAddress_];
        AOriginStrategy(strategyAddress_).distribute(swapPaths_, _fundInvestors);

        IAlphaRegistry alphaRegistryContract = IAlphaRegistry(alphaRegistry);

        _proposal = AOriginStrategy(strategyAddress_).getProposal();
        alphaRegistryContract.finishProposal(_getProposalStruct(_proposal));

        emit TriggerDistributeEvent(_proposal.proposalId, _proposal.strategyAddress, _proposal);
    }

    function fundStrategy(address strategyAddress_, address investorAddress_, uint256 amount, address refererAddress) external override {
        require(strategyAddress_.isContract(), "403: Invalid proposal");
        require(investorAddress_ != address(0), "403: Invalid Investor Address");

        OriginProposalStruct memory proposal = AOriginStrategy(strategyAddress_).getProposal();
        require(proposal.status == PENDING, "404: !pending proposal");

        uint256 feeAmount = amount.mul(IDAOManagers(DAOManagerAddress).getProtocolFee()).div(10000);
        if(refererAddress != address(0x0)){
            require(
                IERC20(proposal.initialToken).transferFrom(
                    msg.sender,
                    refererAddress,
                    feeAmount.mul(IDAOManagers(DAOManagerAddress).getRefererFee()).div(10000)
                ),
                "cannot transfer referer Fee"
            );
            require(
                IERC20(proposal.initialToken).transferFrom(
                    msg.sender,
                    IDAOManagers(DAOManagerAddress).getBeneficiaryOfFees(),
                    feeAmount.mul(uint256(10000).sub(IDAOManagers(DAOManagerAddress).getRefererFee())).div(10000)
                ),
                "cannot transfer Fee"
            );
        } else {
            require(
                IERC20(proposal.initialToken).transferFrom(
                    msg.sender,
                    IDAOManagers(DAOManagerAddress).getBeneficiaryOfFees(),
                    feeAmount
                ),
                "cannot transfer Fee"
            );
        }
       
       
        require(
            IERC20(proposal.initialToken).transferFrom(
                msg.sender,
                proposal.strategyAddress,
                amount
            ),
            "cannot transfer to strategy"
        );

        proposal.collectedAmount = proposal.collectedAmount.add(amount);
        require(proposal.collectedAmount <= proposal.investorDeposit, "You have tried to over fund This proposal.");

        IAlphaRegistry(alphaRegistry).addInvestorToStrategy(investorAddress_, proposal.strategyAddress);
        
        uint256 currentTime = block.timestamp;

        if(proposal.collectedAmount == proposal.investorDeposit) {
            proposal.startedAt = currentTime;
            proposal.expiresOn = currentTime + proposal.duration;
            proposal.status = LIVE;

            IAlphaRegistry(alphaRegistry).startProposal(_getProposalStruct(proposal));

            emit ApproveProposalEvent(proposal.proposalId, proposal.strategyAddress, proposal);
        }

        FundStruct memory fund = FundStruct(
            proposal.strategyAddress,
            investorAddress_,
            proposal.initialToken,
            amount,
            currentTime
        );

        FundStruct[] storage currentProposalFunds = proposalFunds[proposal.strategyAddress];

        uint256 totalAmount = amount;
        uint256 proposalFundIndex = _fundIndexByInvestor(currentProposalFunds, investorAddress_);
        if(proposalFundIndex == currentProposalFunds.length) {
            proposalFunds[proposal.strategyAddress].push(fund);
        } else {
            proposalFunds[proposal.strategyAddress][proposalFundIndex].amount += amount;
            totalAmount = proposalFunds[proposal.strategyAddress][proposalFundIndex].amount;
        }

        uint256 minDeposit = proposal.investorDeposit.mul(IDAOManagers(DAOManagerAddress).getMinInvestmentPercentage()).div(10000);
        require(amount >= minDeposit, "Deposit amount too low");

        FundStruct[] storage currentInvestorFunds = investorFunds[investorAddress_];

        uint256 investorFundIndex = _fundIndexByStrategyAddress(currentInvestorFunds, proposal.strategyAddress);
        if(investorFundIndex == currentInvestorFunds.length) {
            investorFunds[investorAddress_].push(fund);
        } else {
            investorFunds[investorAddress_][investorFundIndex].amount += amount;
        }

        _updateProposal(proposal.strategyAddress, proposal);

        emit FundStrategyEvent(proposal.strategyAddress, investorAddress_, totalAmount);
    }

    function deFundStrategy(address strategyAddress_, uint256 amount) external override {
        bool found = false;
        uint256 totalAmount = 0;
        address investorAddress_ = msg.sender;
        IAlphaRegistry alphaRegistryContract = IAlphaRegistry(alphaRegistry);
        require(strategyAddress_.isContract(), "403: Invalid proposal");

        OriginProposalStruct memory proposal = AOriginStrategy(strategyAddress_).getProposal();
        require(proposal.status == PENDING, "404: !pending proposal");
        require(proposal.collectedAmount >= amount, "Amount to remove is greater than funded amount");

        //TODO: simplify this by only searching one time
        //Remove the funding form the proposal fund list
        FundStruct[] storage currentProposalFunds = proposalFunds[proposal.strategyAddress];

        for (uint i = 0; i < currentProposalFunds.length; i++) {
            if(currentProposalFunds[i].investorAddress == investorAddress_) {
                require(currentProposalFunds[i].amount >= amount, "Amount to remove is greater than funded amount");

                if(currentProposalFunds[i].amount == amount) {
                    alphaRegistryContract.removeInvestorFromStrategy(
                        investorAddress_,
                        strategyAddress_
                    );
                    currentProposalFunds[i] = currentProposalFunds[currentProposalFunds.length - 1];
                    currentProposalFunds.pop();
                } else {
                    currentProposalFunds[i].amount = currentProposalFunds[i].amount.sub(amount);
                    totalAmount =  currentProposalFunds[i].amount;

                    uint256 minDeposit = proposal.investorDeposit.mul(IDAOManagers(DAOManagerAddress).getMinInvestmentPercentage()).div(10000);
                    require(currentProposalFunds[i].amount >= minDeposit, "Deposit will be under min");
                }

                found = true;
                break;
            }
        }

        require(found, "Investment not found");

        found = false;
        //Remove the funding form the investor fund list
        FundStruct[] storage currentProposalInvestorFunds = investorFunds[investorAddress_];

        for (uint i = 0; i < currentProposalInvestorFunds.length; i++) {
            if(currentProposalInvestorFunds[i].strategyAddress == proposal.strategyAddress) {
                require(currentProposalInvestorFunds[i].amount >= amount, "Amount to remove is greater than funded amount");

                if(currentProposalInvestorFunds[i].amount == amount) {
                    currentProposalInvestorFunds[i] = currentProposalInvestorFunds[currentProposalInvestorFunds.length - 1];
                    currentProposalInvestorFunds.pop();
                } else {
                    currentProposalInvestorFunds[i].amount = currentProposalInvestorFunds[i].amount.sub(amount);
                }

                found = true;
                break;
            }
        }
        
        require(found, "Investment not found");

        proposal.collectedAmount = proposal.collectedAmount.sub(amount);
        _updateProposal(proposal.strategyAddress, proposal);

        AOriginStrategy(proposal.strategyAddress).factoryTransferFunds(
            investorAddress_,
            amount
        );
        

        emit DeFundStrategyEvent(proposal.strategyAddress, investorAddress_, totalAmount);
    }

    function cancelPendingProposal(address strategyAddress_) external override {
        require(strategyAddress_.isContract(), "403: Invalid proposal");

        AOriginStrategy strategy_ = AOriginStrategy(strategyAddress_);
        strategy_.cancelProposal(proposalFunds[strategyAddress_]);

        OriginProposalStruct memory proposal = strategy_.getProposal();
        
        require(proposal.traderAddress == msg.sender, "!OWNER");
        require(proposal.proposalId != 0, "404: !proposal");

        IAlphaRegistry alphaRegistryContract = IAlphaRegistry(alphaRegistry);

        proposal = strategy_.getProposal();
        alphaRegistryContract.finishProposal(_getProposalStruct(proposal));

        emit CancelPendingProposal(proposal.proposalId, proposal.strategyAddress, proposal);
    }

    function calculateStopLoss(
        uint256 riskyAmount,
        uint256 traderDeposit,
        uint256 investorDeposit
    ) pure public override checkRiskyAmount(riskyAmount) returns (uint256) {
        return traderDeposit.add(investorDeposit).sub(riskyAmount);
    }

    function addAuthorizedTokens(address[] memory authorizedTokens_) external override {
        IDAOManagers iDAOManagers = IDAOManagers(DAOManagerAddress);
        require(iDAOManagers.isStrategyAdmin(msg.sender), "401: !strategyAdmin");
        require(authorizedTokens_.length <= 50, "401: !authorizedTokens Too Long");

        authorizedTokens = authorizedTokens_;

        this.validateAuthTokens(authorizedTokens_);

        emit AddAuthorizedTokensEvent(authorizedTokens_);
    }

    function getAuthorizedTokens() view external override returns (address[] memory) {
        return authorizedTokens;
    }

    function isAuthorizedToken(address addr) view external override returns (bool) {
        return _checkIfAuthorizedTokenAlreadyExists(addr);
    }

    function _updateProposal(address strategyAddress, OriginProposalStruct memory proposal) internal {
        AOriginStrategy(strategyAddress).updateProposal(proposal);
    }

    function _fundIndexByInvestor(FundStruct[] memory funds, address investorAddress) pure internal returns (uint256) {
        for (uint i = 0; i < funds.length; i++) {
            if(funds[i].investorAddress == investorAddress) {
                return i;
            }
        }
        return funds.length;
    }

    function _fundIndexByStrategyAddress(FundStruct[] memory funds, address strategyAddress) pure internal returns (uint256) {
        for (uint i = 0; i < funds.length; i++) {
            if(funds[i].strategyAddress == strategyAddress) {
                return i;
            }
        }
        return funds.length;
    }

    function _checkIfAuthorizedTokenAlreadyExists(address addr) view internal returns (bool) {
        bool found = false;

        for (uint i = 0; i < authorizedTokens.length; i++) {
            if(authorizedTokens[i] == addr) {
                found = true;
                break;
            }
        }

        return found;
    }

//TODO: this is innesesary since investor-fund-strategy is always only 1 element.
    function _getInvestorFundedAmountByProposal (address strategyAddress, address investorAddress)
    internal view returns (uint256) {
        FundStruct[] memory currentProposalInvestorFunds = investorFunds[investorAddress];

        uint256 accumulatedAmount = 0;

        for (uint i = 0; i < currentProposalInvestorFunds.length; i++) {
            if(currentProposalInvestorFunds[i].strategyAddress == strategyAddress) {
                if(currentProposalInvestorFunds[i].amount > 0) {
                    accumulatedAmount = accumulatedAmount.add(currentProposalInvestorFunds[i].amount);
                }
            }
        }

        return accumulatedAmount;
    }

    function createProposal(
        uint256 traderDeposit,
        uint256 riskyAmount,
        uint256 investorDeposit,
        uint256 traderProfitPercentage,
        uint256 duration,
        address initialToken
    ) external override {
        require(duration >= 1 days, "duration >= 1 days");
        require(duration <= 180 days, "duration <= 180 days");

        require(investorDeposit <= 5000 ether, "Max investor funds is 100000");
        require(traderDeposit <= 1000 ether, "Max trader funds is 10000");
        require(traderProfitPercentage <= 10000, "Max trader % is 10000");

        IDAOManagers iDAOManagers = IDAOManagers(DAOManagerAddress);

        if(!iDAOManagers.isActiveAllowContractStrategies()) {
            //isContract can be skipped if the call cames from the contract constructor since it relies on address.code.length
            //But we put a more extrict validation on the strategy => msg.sender == msg.origin
            //We decide to avoid that validation here since ETH2 (Serenity) will no longer support tx.origin
            require(!address(msg.sender).isContract(), 'only External Owned Address Allowed');
        }

        //This way we ensure that the strategyFactory has been added to DAOManagers before creating an strategy
        require(iDAOManagers.isValidStrategyFactory(address(this)), "Invalid strategy Factory");

        require(_checkIfAuthorizedTokenAlreadyExists(initialToken), "Initial token is unauthorized token");

        uint256 stopLossAmount = calculateStopLoss(riskyAmount, traderDeposit, investorDeposit);
        bytes32 proposalId = iDAOManagers.generateProposalId();

        IERC20 iToken = IERC20(initialToken);

        OriginProposalStruct memory newProposal = OriginProposalStruct(
            proposalId,
            iDAOManagers.getProtocolFee(),
            iDAOManagers.getVIPProtocolFeeCashBack(),
            investorDeposit,
            0,
            traderDeposit,
            riskyAmount,
            stopLossAmount,
            traderProfitPercentage,
            duration,
            block.timestamp,
            0,
            0,
            initialToken,
            msg.sender,
            address(0x0),
            address(this),
            PENDING
        );

        address strategyAddress = _deploy(newProposal);
        newProposal.strategyAddress = strategyAddress;


      require(
            iToken.transferFrom(
                newProposal.traderAddress,
                strategyAddress,
                newProposal.traderDeposit
            ),
            "cannot transfer to strategy"
        );

        IAlphaRegistry alphaRegistryContract = IAlphaRegistry(alphaRegistry);
        alphaRegistryContract.addProposal(_getProposalStruct(newProposal));

        emit NewStrategyCreatedEvent(newProposal.proposalId, newProposal.strategyAddress, newProposal);
    }

    function getFeeForDeposit(uint256 amount) external view override returns(uint256){
        return amount.mul(IDAOManagers(DAOManagerAddress).getProtocolFee()).div(10000);
    }

    function _getProposalStruct(OriginProposalStruct memory proposal_) pure internal returns (ProposalStruct memory proposal) {
        return ProposalStruct(
            proposal_.proposalId,
            proposal_.duration,
            proposal_.createdAt,
            proposal_.startedAt,
            proposal_.expiresOn,
            proposal_.strategyAddress,
            proposal_.strategyFactoryAddress,
            proposal_.traderAddress,
            proposal_.status
        );
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
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
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../IBytesCode.sol";

import "../IStrategy.sol";

import "../../registry/IDAOManagers.sol";

contract OriginBytesCode is IBytesCode {
    using Address for address;
    using SafeMath for uint256;

    address internal firstUniqueTimeAdmin;
    address internal strategyFactory;
    address internal daoManagerAddress;

    bytes internal bytesCode;

    modifier onlyFirstUniqueAdmin() {
        require(firstUniqueTimeAdmin == msg.sender, '401: only firstUniqueAdmin');
        _;
    }

    modifier onlyStrategyFactory() {
        require(strategyFactory == msg.sender, '401: only StrategyFactory');
        _;
    }

    constructor(address daoManagerAddress_, bytes memory bytesCode_) {
        daoManagerAddress = daoManagerAddress_;
        bytesCode = bytesCode_;
        firstUniqueTimeAdmin = msg.sender;
    }

    function deploy(
        bytes32 salt_
    ) external override onlyStrategyFactory returns (address) {
        address addr;
        bytes memory code = bytesCode;
        assembly {
            addr := create2(0, add(code, 0x20), mload(code), salt_)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        IStrategy(addr).setStrategyFactory(msg.sender);

        return addr;
    }

    function setStrategyFactory(address addr) external override onlyFirstUniqueAdmin {
        firstUniqueTimeAdmin = address(0x0);
        strategyFactory = addr;
    }

    function getStrategyFactory() view external returns (address) {
        return strategyFactory;
    }

    function getBytesCode() view external override returns (bytes memory) {
        return bytesCode;
    }

    function setBytesCode(bytes memory bytesCode_) external override {
        IDAOManagers iDAOManagers = IDAOManagers(daoManagerAddress);

        require(iDAOManagers.isStrategyAdmin(msg.sender), "!strategyAdmin");

        bytesCode = bytesCode_;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

import "../../../structs/OriginProposalStruct.sol";
import "../../../structs/SwapPathStruct.sol";
import "../../../structs/FundStruct.sol";
import "../../../structs/RouterStruct.sol";
import "../../IFactory.sol";


abstract contract AOriginFactory is IFactory {
    event ApproveProposalEvent(bytes32 proposalId, address strategyAddress, OriginProposalStruct originProposalStruct);

    event NewStrategyCreatedEvent(bytes32 proposalId, address strategyAddress, OriginProposalStruct originProposalStruct);

    event InitializeStrategyEvent(bytes32 proposalId, address strategyAddress, OriginProposalStruct originProposalStruct);

    event TriggerStopLossEvent(bytes32 proposalId, address strategyAddress, OriginProposalStruct originProposalStruct);

    event TriggerDistributeEvent(bytes32 proposalId, address strategyAddress, OriginProposalStruct originProposalStruct);

    event AddAuthorizedTokensEvent(address[] authorizedTokens);
    event FundStrategyEvent(address strategyAddress, address investorAddress, uint256 amount);
    event DeFundStrategyEvent(address strategyAddress, address investorAddress, uint256 amount);
    event CancelPendingProposal(bytes32 proposalId, address strategyAddress, OriginProposalStruct originProposalStruct);

    function createProposal(
        uint256 traderDeposit,
        uint256 riskyAmount,
        uint256 investorDeposit,
        uint256 traderProfitPercentage,
        uint256 duration,
        address initialToken
    ) external virtual;

    function runStopLoss(address strategyAddress, SwapPathStruct[] memory pathTokens) external virtual;
    function distribute(address, SwapPathStruct[] memory) external virtual;
    function cancelPendingProposal(address strategyAddress_) external virtual;

    function fundStrategy(address strategyAddress, address investorAddress, uint256 amount, address refererAddress ) external virtual;
    function deFundStrategy(address strategyAddress, uint256 amount) external virtual;

    function calculateStopLoss(uint256, uint256, uint256) external virtual returns (uint256);

    function getInvestorFunds(address investorAddress) view external virtual returns (FundStruct[] memory);
    function isAuthorizedToken(address) view external virtual returns (bool);

    function getInvestorFundedAmountByProposal(address strategyAddress, address investorAddress) view external virtual returns (uint256);
    function getFeeForDeposit(uint256 amount) external view virtual returns(uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

import "../../../structs/OriginProposalStruct.sol";
import "../../../structs/OperationStruct.sol";
import "../../../structs/SwapPathStruct.sol";
import "../../../structs/FundStruct.sol";
import "../../IStrategy.sol";

abstract contract AOriginStrategy is IStrategy{
    event TriggerStopLossEvent(
        address strategyAddress,
        uint8 status,
        address[] successTokens,
        address[] failTokens,
        string[] errorReasons
    );

    event StrategyEndedEvent(
        address strategyAddress,
        uint8 status,
        uint256 traderAmount,
        uint256 investorAmount
    );

    event InitializeEvent(address routerAddress, address[] dexSwapAddress);

    event SwapEvent(
        address inputAddress,
        address outputAddress,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 createdAt
    );

    event UpdateProposal(bytes32 proposalId, address strategyAddress, OriginProposalStruct originProposalStruct);

    function initialize(
        address[] memory dexSwapAddress,
        address[] memory authTokens,
        OriginProposalStruct memory proposal
    ) external virtual;

    function swap(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external virtual returns (uint[] memory amounts);
    function claim() external virtual;
    function pendingRewardsOf(address account) public view virtual returns (uint256);
    function runStopLoss(address strategyAddress, SwapPathStruct[] memory pathTokens, FundStruct[] memory fundInvestors) external virtual;
    function updateProposal(OriginProposalStruct memory) external virtual;
    function cancelProposal(FundStruct[] memory) external virtual;
    function factoryTransferFunds(address investorAddress, uint256 amount) external virtual;

    function distribute(SwapPathStruct[] memory swapPaths, FundStruct[] memory fundInvestors) external virtual;

    function getOperations() view external virtual returns (OperationStruct[] memory);
    function getProposal() view external virtual returns (OriginProposalStruct memory);
    function getAuthTokens() view external virtual returns (address[] memory);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

import "../structs/ProposalStruct.sol";

interface IAlphaRegistry {
    event NewProposalEvent(bytes32 proposalId, address strategyAddress);
    event StartProposalEvent(bytes32 proposalId, address strategyAddress);
    event FinishProposalEvent(bytes32 proposalId, address strategyAddress);
    event NewInvestorEvent(address investorAddress, address strategyAddress);
    event RemoveInvestorEvent(address investorAddress, address strategyAddress);

    function getPendingProposals() view external returns (ProposalStruct[] memory);
    function getLiveProposals() view external returns (ProposalStruct[] memory);
    function getEndedProposals() view external returns (ProposalStruct[] memory);
    function getPendingProposalsByTraderAddress(address addr) view external returns (ProposalStruct[] memory);
    function getLiveProposalsByTraderAddress(address addr) view external returns (ProposalStruct[] memory);
    function getLiveProposalsByInvestorAddress(address addr) view external returns (ProposalStruct[] memory);

    function addProposal(ProposalStruct memory proposal_) external;
    function startProposal(ProposalStruct memory proposal_) external;
    function finishProposal(ProposalStruct memory proposal_) external;
    function addInvestorToStrategy(address investorAddress_, address strategyAddress_) external;
    function removeInvestorFromStrategy(address investorAddress_, address strategyAddress_) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

import "../structs/StrategyFactoryStruct.sol";

interface IDAOManagers {
    event DAOManagersInitEvent(
        address strategyAdmin,
        address beneficiaryOfFees,
        address stopLossAdmin,
        bool allowContractStrategies,
        uint256 protocolFee
    );

    event NewAllowContractStrategiesEvent(bool allowContractStrategies);
    event NewStopLossAdminEvent(address newAdmin);
    event NewStrategyAdminEvent(address newAdmin);
    event NewBeneficiaryFeesEvent(address beneficiary);

    event NewStrategyFactoryEvent(string name, address factory, address[] authTokens);
    event RemoveStrategyFactoryEvent(string name, address factory);

    function setAllowContractStrategies(bool _allowContractStrategies) external;

    function setStopLossAdmin(address addr_) external;
    function setStrategyAdmin(address addr_) external;
    function addStrategyFactory(string memory name, address addr) external;
    function removeStrategyFactory(address addr_) external;
    function setBeneficiaryFees(address addr_) external;
    function generateProposalId() external returns (bytes32 proposalId);

    function setProtocolFee(uint256 protocolFee_) external;
    function setVIPProtocolFeeCashBack(uint256 VIPProtocolFee_) external;
    function setMinInvestmentPercentage(uint256 minInvestmentPercentage_) external;
    function setRefererFee(uint256 refererFee_) external;

    function getStrategyFactories() view external returns (StrategyFactoryStruct[] memory);

    function getBeneficiaryOfFees() view external returns (address);
    function getProtocolFee() view external returns (uint256);
    function getRefererFee() view external returns (uint256);
    function getVIPProtocolFeeCashBack() view external returns (uint256);
    function getMinInvestmentPercentage() view external returns (uint256);

    function isValidStrategyFactory(address addr) view external returns (bool);
    function isStopLossAdmin(address addr) view external returns (bool);
    function isStrategyAdmin(address addr) view external returns (bool);
    function isBeneficiaryAdmin(address addr) view external returns (bool);

    function isActiveAllowContractStrategies() view external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

uint8 constant  PENDING = 1;
uint8 constant  LIVE = 2;
uint8 constant  ENDED = 3;
uint8 constant  CANCELED = 4;
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ITokenPricesModule {
    function getTokenPrice(
        address token
    ) view external returns (int256 amount);

    function getTokenPriceDecimals(
        address token
    ) view external returns (uint8 amount);

    function addTokenAggregator(address token, address aggregator) external;
    function changeTolerance(uint256 token) external;

    function isInTolerance(
        uint256 amountIn,
        uint256 amountOut,
        address originToken,
        address targetToken
    ) external returns (bool isValid);
    
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

interface IBytesCode {
    function deploy(bytes32) external returns (address);

    function getBytesCode() view external returns (bytes memory);

    function setStrategyFactory(address addr) external;

    function setBytesCode(bytes memory bytesCode_) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

interface IStrategy {
    function setStrategyFactory(address addr) external;
    function getTokens() view external returns (address[] memory);
    function withdrawFailedToken(address tokenAddress) external;
    function isVIP() view external returns (bool);

    event WithdrawFailedTokenEvent(address tokenAddress, uint256 tokenBalance);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

struct StrategyFactoryStruct {
    string name;
    address addr;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

struct OriginProposalStruct {
    bytes32 proposalId;

    uint256 protocolFee;
    uint256 VIPProtocolFeeCashBack;
    uint256 investorDeposit;
    uint256 collectedAmount;
    uint256 traderDeposit;
    uint256 riskyAmount;
    uint256 stopLossAmount;
    uint256 traderProfitPercentage;
    uint256 duration;
    uint256 createdAt;
    uint256 startedAt;
    uint256 expiresOn;

    address initialToken;

    address traderAddress;

    address strategyAddress;
    address strategyFactoryAddress;

    uint8 status;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

struct SwapPathStruct {
    address addr;
    address[] path;
    uint256 amountIn;
    uint256 amountOut;
    uint256 deadline;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;
import "./ProposalStruct.sol";

struct FundStruct {
    address strategyAddress;
    address investorAddress;
    address baseCurrencyAddress;
    uint256 amount;
    uint256 createdAt;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

struct RouterStruct {
    string name;
    address addr;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

interface IFactory {
    function getAuthorizedTokens() view external returns (address[] memory);
    function addAuthorizedTokens(address[] memory) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

struct ProposalStruct {
    bytes32 proposalId;

    uint256 duration;
    uint256 createdAt;
    uint256 startedAt;
    uint256 expiresOn;

    address strategyAddress;
    address strategyFactoryAddress;
    //@TODO: we should rename this to Owner address because not always the owener will be a trader but we always have an strategy Owner
    address traderAddress;

    uint8 status;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.11 <0.8.9;

struct OperationStruct {
    address inputAddress;
    address outputAddress;

    uint256 inputAmount;
    uint256 outputAmount;
    uint256 createdAt;
}
