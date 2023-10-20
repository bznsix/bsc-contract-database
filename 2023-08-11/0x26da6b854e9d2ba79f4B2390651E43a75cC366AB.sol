// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./ArborswapPrivateSaleERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract SalesPrivateFactoryERC20 is Ownable {
    IAdmin public admin;
    address payable public feeAddr;
    uint256 public fee;
    uint256 public serviceFee;
    address public immutable masterSale;
    mapping(uint256 => address) public saleIdToAddress;
    mapping(address => address) public saleAddressToSaleOwner;

    // Expose so query can be possible only by position as well
    address[] public allSales;

    event SaleDeployed(address saleContract);
    event LogSetFee(uint256 newFee);
    event LogSetFeeAddr(address newAddress);
    event LogWithdrawalBNB(address account, uint256 amount);

    modifier onlyAdmin() {
        require(admin.isAdmin(msg.sender), "Only Admin can deploy sales");
        _;
    }

    constructor(address _adminContract, address masterSale_) {
        require(_adminContract != address(0), "Invalid address");
        admin = IAdmin(_adminContract);
        masterSale = masterSale_;
    }

    function setFee(uint256 _fee) public onlyAdmin {
        require(fee != _fee, "Already set to this value");
        fee = _fee;
        emit LogSetFee(_fee);
    }

    function setServiceFee(uint256 _serviceFee) public onlyAdmin {
        require(serviceFee != _serviceFee, "Already set to this value");
        serviceFee = _serviceFee;
        emit LogSetFee(_serviceFee);
    }

    function setFeeAddr(address payable _feeAddr) public onlyAdmin {
        require(_feeAddr != address(0), "address zero validation");
        feeAddr = _feeAddr;
        emit LogSetFeeAddr(_feeAddr);
    }

    function deployERC20PrivateSale(
        address[] memory setupAddys,
        uint256[] memory uints,
        uint256[] memory _unlockingTimes,
        uint256[] memory _percents
    ) external payable  {
        require(msg.value >= fee, "Not enough bnb sent");

        uint8 decimals = IERC20Metadata(setupAddys[3]).decimals();
        
        uint256 amount = (uints[5] * uints[2]) /
            10**decimals;
       

        IERC20(setupAddys[1]).transferFrom(
            setupAddys[2],
            address(this),
            amount
        );


        address clone = Clones.clone(masterSale);

        ArborSwapPrivateSaleERC20(clone).init(
            setupAddys,
            uints,
            _unlockingTimes,
            _percents,
            feeAddr,
            serviceFee,
            decimals
        );

        
        IERC20(setupAddys[1]).approve(clone, amount);
        ArborSwapPrivateSaleERC20(clone).depositTokens();
        
        uint256 id = allSales.length;
        saleIdToAddress[id] = clone;
        saleAddressToSaleOwner[clone] = msg.sender;

        allSales.push(clone);
        feeAddr.transfer(msg.value);

        emit SaleDeployed(clone);
    }

    // Function to return number of pools deployed
    function getNumberOfSalesDeployed() external view returns (uint256) {
        return allSales.length;
    }

    function getSaleAddress(uint256 id) external view returns (address) {
        return saleIdToAddress[id];
    }

    // Function
    function getLastDeployedSale() external view returns (address) {
        //
        if (allSales.length > 0) {
            return allSales[allSales.length - 1];
        }
        return address(0);
    }

    // Function to get all sales
    function getAllSales(uint256 startIndex, uint256 endIndex)
        external
        view
        returns (address[] memory)
    {
        require(endIndex > startIndex, "Bad input");
        require(endIndex <= allSales.length, "access out of rage");

        address[] memory sales = new address[](endIndex - startIndex);
        uint256 index = 0;

        for (uint256 i = startIndex; i < endIndex; i++) {
            sales[index] = allSales[i];
            index++;
        }

        return sales;
    }

    function withdrawBNB(address payable account, uint256 amount)
        external
        onlyAdmin
    {
        require(amount <= (address(this)).balance, "Incufficient funds");
        account.transfer(amount);
        emit LogWithdrawalBNB(account, amount);
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";




interface IAdmin {
    function isAdmin(address user) external view returns (bool);
}

contract ArborSwapPrivateSaleERC20 {
    using SafeMath for uint256;

    IAdmin public admin;
   

    address public feeAddr;
    address public factory;
    uint256 public wlStartTime;
    uint256 public wlEndTime;
    bool public isWlEnabled;
    bool public isSaleSuccessful;
    bool public saleFinished;
    uint256 public minParticipation;
    uint256 public maxParticipation;
    uint256 public saleStartTime;
    uint256 public serviceFee;
    bool public leftoverWithdrawnCancelledSale;
    bool public isInitialized;

    // Times when portions are getting unlocked
    uint256[] public vestingPortionsUnlockTime;
    // Percent of the participation user can withdraw
    uint256[] public vestingPercentPerPortion;
    //Precision for percent for portion vesting
    uint256 public portionVestingPrecision ;

    uint8 public paymentTokenDecimals;

 

    struct Sale {
        // Token being sold
        IERC20 token;
        // Payment token
        IERC20 paymentToken;
        // Is sale created
        bool isCreated;
        // Are earnings withdrawn
        bool earningsWithdrawn;
        // Is leftover withdrawn
        bool leftoverWithdrawn;
        // Address of sale owner
        address saleOwner; 
        // Price of the token quoted in ERC20
        uint256 presaleRate;
        // Total tokens being sold
        uint256 totalTokensSold;
        // Total ERC20 Raised
        uint256 totalERC20Raised;
        // Sale end time
        uint256 saleEnd;
        // Sale start time
        uint256 saleStartTime;
        // Hard cap
        uint256 hardCap;
        // Soft cap
        uint256 softCap;
    }

    // Participation structure
    struct Participation {
        uint256 amountBought;
        uint256 amountERC20Paid;
        bool[] isPortionWithdrawn;
        bool areERC20sWithdrawn;
    }

    // Sale
    Sale public sale;

    // Number of users participated in the sale.
    uint256 public numberOfParticipants;

    mapping(address => Participation) public userToParticipation;
    // mapping if user is participated or not
    mapping(address => bool) public isParticipated;

    mapping(address => bool) public isWl;
   

    // Restricting calls only to sale owner
    modifier onlySaleOwner() {
        require(msg.sender == sale.saleOwner, "Restricted to sale owner.");
        _;
    }

    // Restricting calls only to factory
    modifier onlyFactory() {
        require(msg.sender == factory, "Restricted to factory.");
        _;
    }

    // Restricting calls only to sale owner or Admin
    modifier onlySaleOwnerOrAdmin() {
        require(
            msg.sender == sale.saleOwner || admin.isAdmin(msg.sender),
            "Restricted to sale owner and admin."
        );
        _;
    }

    // Restricting calls only to sale admin
    modifier onlyAdmin() {
        require(
            admin.isAdmin(msg.sender),
            "Only admin can call this function."
        );
        _;
    }

    // Events
    event TokensSold(address user, uint256 amount);
    event TokensWithdrawn(address user, uint256 amount);
    event SaleCreated(
        address saleOwner,
        uint256 presaleRate,
        uint256 saleEnd,
        uint256 _hardCap,
        uint256 _softCap
    );
    event LogwithdrawUserFundsIfSaleCancelled(address user, uint256 amount);
    event LogFinishSale(bool isSaleSuccessful);
    event LogEditMaxParticipation(uint256 maxP);
    event LogEditMinParticipation(uint256 minP);
    event LogChangeSaleOwner(address newOwner);
    event LogSetWLEnabled(bool enabled);
    event LogSetAddressWL(bool _isWL);

    function init(
        address[] memory setupAddys,
        uint256[] memory uints,
        uint256[] memory _unlockingTimes,
        uint256[] memory _percents,
        address _feeAddr,
        uint256 _serviceFee,
        uint8 _decimals
    )public{
        require(isInitialized == false, 'Already Initialized');
        require(setupAddys[0] != address(0), "Address zero validation");
        require(setupAddys[1] != address(0), "Address zero validation");
        require(setupAddys[2] != address(0), "Address zero validation");
        require(
            uints[0] < uints[1],
            "Max participation should be greater than min participation"
        );
        admin = IAdmin(setupAddys[0]);
        feeAddr = _feeAddr;
        serviceFee = _serviceFee;
        minParticipation = uints[0];
        maxParticipation = uints[1];
        portionVestingPrecision = uints[7];
        paymentTokenDecimals = _decimals;
        factory = msg.sender;
        isInitialized = true;
        setSaleParams(
            setupAddys[1],
            setupAddys[2],
            setupAddys[3],
            uints[2],
            uints[3],
            uints[4],
            uints[5],
            uints[6]
        );
        setVestingParams(_unlockingTimes, _percents);
    }

    /// @notice     Admin function to set sale parameters
    function setSaleParams(
        address _token,
        address _saleOwner,
        address _paymentToken,
        uint256 _presaleRate,
        uint256 _saleEnd,
        uint256 _saleStart,
        uint256 _hardCap,
        uint256 _softCap
    ) private {
        require(!sale.isCreated, "Sale already created.");
        require(
            _token != address(0),
            "setSaleParams: Token address can not be 0."
        );
        require(_saleOwner != address(0), "Invalid sale owner address.");
        require(
            _presaleRate != 0 &&
                _hardCap != 0 &&
                _softCap != 0 &&
                _saleEnd > block.timestamp,
            "Invalid input."
        );
        require(
            _saleEnd <= block.timestamp + 8640000,
            "Max sale duration is 100 days"
        );
        require(
            _saleStart >= block.timestamp,
            "Sale start should be in the future"
        );
        require(_saleStart < _saleEnd, "Sale start should be before sale end");

        // Set params
        sale.token = IERC20(_token);
        sale.isCreated = true;
        sale.saleOwner = _saleOwner;
        sale.presaleRate = _presaleRate;
        sale.saleEnd = _saleEnd;
        sale.hardCap = _hardCap;
        sale.softCap = _softCap;
        sale.saleStartTime = _saleStart;
        sale.paymentToken = IERC20(_paymentToken);
       

        // Emit event
        emit SaleCreated(
            sale.saleOwner,
            sale.presaleRate,
            sale.saleEnd,
            sale.hardCap,
            sale.softCap
        );
    }

    function setVestingParams(
        uint256[] memory _unlockingTimes,
        uint256[] memory _percents
    )
        internal
    {
        require(
            vestingPercentPerPortion.length == 0 &&
            vestingPortionsUnlockTime.length == 0
        );
        require(_unlockingTimes.length == _percents.length);



        uint256 sum;

        // Require that locking times are later than sale end
        require(_unlockingTimes[0] > sale.saleEnd, "Unlock time must be after the sale ends.");

        // Set vesting portions percents and unlock times
        for (uint256 i = 0; i < _unlockingTimes.length; i++) {
            if(i > 0) {
                require(_unlockingTimes[i] > _unlockingTimes[i-1], "Unlock time must be greater than previous.");
            }
            vestingPortionsUnlockTime.push(_unlockingTimes[i]);
            vestingPercentPerPortion.push(_percents[i]);
            sum = sum.add(_percents[i]);
        }

        require(sum == portionVestingPrecision, "Percent distribution issue.");
    }


    function changeSaleOwner(address _saleOwner) external onlySaleOwner {
        require(block.timestamp < sale.saleStartTime, "Sale already started");
        require(_saleOwner != sale.saleOwner, "Already set to this value");
        require(_saleOwner != address(0), "Address 0 validation");
        sale.saleOwner = _saleOwner;
        emit LogChangeSaleOwner(_saleOwner);
    }

    // Function for owner to deposit tokens, can be called only once.
    function depositTokens() external onlyFactory {
        // Require that setSaleParams was called
        require(sale.hardCap > 0, "Sale parameters not set.");

        uint256 amount = (sale.hardCap * sale.presaleRate) /
            10**paymentTokenDecimals;


        // Perform safe transfer
        sale.token.transferFrom(msg.sender, address(this), amount);
    }


    // Function to participate in the sales
    function participate(
        uint256 amountERC20
    ) external payable {
        require(block.timestamp >= sale.saleStartTime, "Sale haven't started yet");

        require(
            amountERC20 >= minParticipation,
            "Amount should be greater than minParticipation"
        );
        require(
            amountERC20 <= maxParticipation,
            "Amount should be not greater than maxParticipation"
        );

        require(
            sale.paymentToken.allowance(msg.sender, address(this)) >= amountERC20,
            "Allowance should be greater than amount"
        );
        require(
            sale.paymentToken.balanceOf(msg.sender) >= amountERC20,
            "Amount should be not greater than token balance"
        );

        require(
            sale.totalERC20Raised + amountERC20 <= sale.hardCap ,
            "Hard Cap Reached."
        );
        
        if(isWlEnabled && block.timestamp >= wlStartTime && block.timestamp <= wlEndTime){
            require(isWl[msg.sender] == true, "Only for whitelisted users");
        }

        require(block.timestamp <= sale.saleEnd, "Sale finished");
       
        Participation storage p = userToParticipation[msg.sender];

        if(isParticipated[msg.sender]){
           require(p.amountERC20Paid + amountERC20 <= maxParticipation, "Exceeds max participation");
        }

        uint256 amountOfTokensBuying = (amountERC20 * sale.presaleRate) / 10**paymentTokenDecimals;

        // Must buy more than 0 tokens
        require(amountOfTokensBuying > 0, "Can't buy 0 tokens");

        // Increase amount of sold tokens
        sale.totalTokensSold = sale.totalTokensSold + amountOfTokensBuying;

        // Increase amount of ERC20 raised
        sale.totalERC20Raised = sale.totalERC20Raised + amountERC20;

        // Empty bool array used to be set as initial for 'isPortionWithdrawn' 
        // Size determined by number of sale portions
        bool[] memory _empty = new bool[](
            vestingPortionsUnlockTime.length
        );


        p.amountBought = p.amountBought + amountOfTokensBuying;
        p.amountERC20Paid = p.amountERC20Paid + amountERC20;
        p.isPortionWithdrawn = _empty;
      
        userToParticipation[msg.sender] = p;
  
        // Mark user is participated
        if(!isParticipated[msg.sender]){
           isParticipated[msg.sender] = true;
        }
       
        // Increment number of participants in the Sale.
        numberOfParticipants++;

        if (sale.totalERC20Raised >= sale.hardCap) {
            sale.saleEnd = block.timestamp;
        }

        sale.paymentToken.transferFrom(msg.sender, address(this), amountERC20);

        emit TokensSold(msg.sender, amountOfTokensBuying);

    }

    // Expose function where user can withdraw sale tokens.
    function withdrawMultiplePortions(uint256 [] calldata portionIds) external {
        // require(block.timestamp > sale.saleEnd, "Sale is running");
        require(
            saleFinished == true && isSaleSuccessful == true,
            "Sale was cancelled"
        );
        require(isParticipated[msg.sender], "User is not a participant.");

        uint256 totalToWithdraw = 0;

        // Retrieve participation from storage
        Participation storage p = userToParticipation[msg.sender];

        

        for(uint i=0; i < portionIds.length; i++) {
            uint256 portionId = portionIds[i];
            require(portionId < vestingPercentPerPortion.length);

            if (
                !p.isPortionWithdrawn[portionId] &&
                vestingPortionsUnlockTime[portionId] <= block.timestamp
            ) {
                // Mark participation as withdrawn
                p.isPortionWithdrawn[portionId] = true;
                // Compute amount withdrawing
                uint256 amountWithdrawing = p
                    .amountBought
                    .mul(vestingPercentPerPortion[portionId])
                    .div(portionVestingPrecision);
                // Withdraw percent which is unlocked at that portion
                totalToWithdraw = totalToWithdraw.add(amountWithdrawing);
            }
        }


        if(totalToWithdraw > 0) {
            // Transfer tokens to user
            sale.token.transfer(msg.sender, totalToWithdraw);
            // Trigger an event
            emit TokensWithdrawn(msg.sender, totalToWithdraw);
        }
    }

    function setWLEnabled(bool _enabled, uint256 _wlStartTime, uint256 _wlEndTime) external onlySaleOwner {
        require(isWlEnabled != _enabled, "Already set to this value");
        isWlEnabled = _enabled;
        wlStartTime = _wlStartTime;
        wlEndTime = _wlEndTime;
        emit LogSetWLEnabled(_enabled);
    }

    function setMultiplyAddressesWL(address[] memory users, bool _isWL) external onlySaleOwner {
        for (uint256 i = 0; i < users.length; i++){
            setAddressWL(users[i], _isWL);
        }
    }

    function setAddressWL(address user, bool _isWL)  private {
        require(isWl[user] != _isWL, "Already set to this value");
        isWl[user] = _isWL;
        emit LogSetAddressWL(_isWL);
    }

    function finishSale() external onlySaleOwnerOrAdmin {
        require(block.timestamp >= sale.saleEnd, "Sale is not finished yet");
        require(saleFinished == false, "The function can be called only once");
        if (sale.totalERC20Raised >= sale.softCap) {
            isSaleSuccessful = true;
            saleFinished = true;
            withdrawEarningsInternal();
        } else {
            isSaleSuccessful = false;
            saleFinished = true;
            withdrawLeftoverIfSaleCancelled();
        }
        emit LogFinishSale(isSaleSuccessful);
    }

    function cancelSale() external onlySaleOwner {
        require(saleFinished == false, "The function can be called only once");
        saleFinished = true;
        isSaleSuccessful = false;
        withdrawLeftoverIfSaleCancelled();
        emit LogFinishSale(isSaleSuccessful);
    }

    // transfers ERC20 correctly
    function withdrawUserFundsIfSaleCancelled() external {
        require(
            saleFinished == true && isSaleSuccessful == false,
            "Sale wasn't cancelled."
        );
        require(isParticipated[msg.sender], "Did not participate.");
        // Retrieve participation from storage
        Participation storage p = userToParticipation[msg.sender];
        require(p.areERC20sWithdrawn == false, "Already withdrawn");
        p.areERC20sWithdrawn = true;
        uint256 amountERC20Withdrawing = p.amountERC20Paid;
        safeTransferERC20(msg.sender, amountERC20Withdrawing);
        emit LogwithdrawUserFundsIfSaleCancelled(
            msg.sender,
            amountERC20Withdrawing
        );
    }


    // Internal function to handle safe transfer
    function safeTransferERC20(address to, uint256 value) internal {
        sale.paymentToken.transfer(to, value);
    }

    // Function to withdraw only earnings
    function withdrawEarnings() external onlySaleOwner {
        withdrawEarningsInternal();
    }

    // Function to withdraw earnings
    function withdrawEarningsInternal() private {
        require(
            saleFinished == true && isSaleSuccessful == true,
            "Sale was cancelled"
        );
        // Make sure owner can't withdraw twice
        require(!sale.earningsWithdrawn, "can't withdraw twice");
        sale.earningsWithdrawn = true;
        // Earnings amount of the owner in ERC20
        uint256 totalFee = _calculateServiceFee(sale.totalERC20Raised);
        uint256 saleOwnerProfit = sale.totalERC20Raised - totalFee;

        safeTransferERC20(msg.sender, saleOwnerProfit);
        safeTransferERC20(feeAddr, totalFee);
    }

    function withdrawLeftoverIfSaleCancelled() private {
        require(
            saleFinished == true && isSaleSuccessful == false,
            "Sale wasnt cancelled"
        );


        // Make sure owner can't withdraw twice
        require(!leftoverWithdrawnCancelledSale, "can't withdraw twice");
        leftoverWithdrawnCancelledSale = true;

        // Amount of tokens which are not sold
        uint256 leftover = sale.token.balanceOf(address(this));

        if (leftover > 0) {
            sale.token.transfer(msg.sender, leftover);
        }
    }

    function getParticipation(address _user)
        external
        view
        returns (
            uint256,
            uint256,
            bool[] memory,
            bool
        )
    {
        Participation memory p = userToParticipation[_user];
        return (
            p.amountBought,
            p.amountERC20Paid,
            p.isPortionWithdrawn,
            p.areERC20sWithdrawn
        );
    }


    function _calculateServiceFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return (_amount * serviceFee) / 10000;
    }

}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
     * @dev Moves `amount` of tokens from `from` to `to`.
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
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
