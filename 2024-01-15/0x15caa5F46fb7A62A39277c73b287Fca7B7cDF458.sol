/**
 *Submitted for verification at Etherscan.io on 2022-07-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-22
 */

// File: Libraries.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library EnumerableSet {
    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }
}

pragma solidity ^0.8.4;

contract BTD is IBEP20, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public excluded;
    mapping(address => bool) public excludedFromStaking;
    mapping(address => bool) public automatedMarketMakers;


    //Token Info
    string public constant name = "BuyTheDip";
    string public constant symbol = "BTDP";
    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 999990958407043 * 10**decimals;
    uint256 public MaxWallet=totalSupply/100;
    uint256 public constant MaxTax = 250;

    uint256 private _buyTax = 0;
    uint256 private _sellTax = 120;
    uint256 private _transferTax = 0;
    uint256 private _negativeBuyTax = 20;
    uint256 private _liquidityTax = 168;
    uint256 private _stakingTax = 416;
    uint256 private _marketingTax = 416;
    uint256 private constant TaxDenominator = 1000;

    uint256 public LaunchTimestamp = type(uint256).max;

    address private _pancakePairAddress;
    IDEXRouter private _pancakeRouter;

    address private constant PancakeRouter =

       0x10ED43C718714eb63d5aA57B78B54704E256024E;//Mainnet
    IBEP20 RewardsToken=
    IBEP20(0x76A797A59Ba2C17726896976B7B3747BfD1d220f);//Mainnet

    address public constant NegativeTaxWallet= address(0xFFFF);
    address public MarketingWallet;
    bool _lock;
    modifier Lock() {
        require(!_lock);
        _lock = true;
        _;
        _lock = false;
    }

    constructor() {
        _pancakeRouter = IDEXRouter(PancakeRouter);
        _pancakePairAddress = IPancakeFactory(_pancakeRouter.factory())
            .createPair(address(this), _pancakeRouter.WETH());
        excluded[address(0xdead)] = true;
        automatedMarketMakers[_pancakePairAddress] = true;

        excludedFromStaking[_pancakePairAddress] = true;
        excludedFromStaking[address(this)] = true;
        excludedFromStaking[address(0xdead)] = true;
        excludedFromStaking[NegativeTaxWallet]=true;

        _addToken(msg.sender, totalSupply);
        emit Transfer(address(0), msg.sender, totalSupply);

        MarketingWallet = msg.sender;
        excluded[MarketingWallet] = true;
        excluded[msg.sender] = true;
        excluded[address(this)] = true;
        _approve(address(this), address(_pancakeRouter), type(uint).max);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "from zero");
        require(recipient != address(0), "to zero");

        if (excluded[sender] || excluded[recipient]) {
            _feelessTransfer(sender, recipient, amount);
            return;
        }

        require(block.timestamp >= LaunchTimestamp, "trading not yet enabled");
        _regularTransfer(sender, recipient, amount);
    }

    function _regularTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(balanceOf[sender] >= amount, "exceeds balance");
        bool isBuy = automatedMarketMakers[sender];
        bool isSell = automatedMarketMakers[recipient];
        uint256 tax;
        if (isSell) {
            tax = _sellTax;
        } else if (isBuy) {
            require(balanceOf[recipient]+amount<=MaxWallet,"Exceeds max Wallet");
            uint256 negativeTaxAmount=amount*_negativeBuyTax/TaxDenominator;
            if(balanceOf[NegativeTaxWallet]>=negativeTaxAmount&&negativeTaxAmount>0){
                _removeToken(NegativeTaxWallet,negativeTaxAmount);
                _addToken(recipient,negativeTaxAmount);
                emit Transfer(NegativeTaxWallet,recipient,negativeTaxAmount);
            }
            tax = _buyTax;
        } else {
            tax = _transferTax;
        }

        if (
            (sender != _pancakePairAddress) &&
            (!swapAndLiquifyDisabled) &&
            (!_isSwappingContractModifier)
        ) {
            _swapContractToken();
        }
        _transferTaxed(sender, recipient, amount, tax);
    }

    function _transferTaxed(
        address sender,
        address recipient,
        uint256 amount,
        uint256 tax
    ) private {
        uint256 totalTaxedToken = (amount * tax) / TaxDenominator;
        uint256 taxedAmount = amount - totalTaxedToken;

        _removeToken(sender, amount);
        if(totalTaxedToken>0)
        {
        _addToken(address(this), totalTaxedToken);
        emit Transfer(sender, address(this), totalTaxedToken);
        }
        _addToken(recipient, taxedAmount);
        emit Transfer(sender, recipient, taxedAmount);
        _autoPayout();
    }

    function _feelessTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(balanceOf[sender] >= amount, ">balance");
        _removeToken(sender, amount);
        _addToken(recipient, amount);

        emit Transfer(sender, recipient, amount);
    }

    EnumerableSet.AddressSet private _autoPayoutList;

    function isAutoPayout(address account) public view returns (bool) {
        return _autoPayoutList.contains(account);
    }

    function setMyAutoPayout(bool flag) external {
        if (flag) _autoPayoutList.add(msg.sender);
        else _autoPayoutList.remove(msg.sender);
    }

    uint256 constant AutoPayoutCount = 5;
    uint256 currentPayoutIndex;



    function _autoPayout() private Lock {
        if (currentPayoutIndex >= _autoPayoutList.length())
            currentPayoutIndex = 0;


        for (uint256 i = 0; i < AutoPayoutCount; i++) {
            address current = _autoPayoutList.at(currentPayoutIndex);
            currentPayoutIndex++;
            uint256 dividents = getDividents(current);
            if (dividents > 0) {
                alreadyPaidShares[current] =
                    profitPerShare *
                    getShares(current);

                RewardsToken.transfer(current,dividents);
            }

            if (currentPayoutIndex >= _autoPayoutList.length()) {
                currentPayoutIndex = 0;
                return;
            }
        }
    }

    function swapForToken(uint256 amount)
        private
        returns (uint256 newAmount)
    {
        address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH(); //BNB
        path[1] = address(RewardsToken);

        _pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, address(this), block.timestamp);
        newAmount = RewardsToken.balanceOf(address(this));
    }


    uint256 private constant DistributionMultiplier = 2**64;
    uint256 public profitPerShare;
    uint256 public totalShares;
    uint256 public totalStakingReward;
    uint256 public totalPayouts;
    mapping(address => uint256) private alreadyPaidShares;
    mapping(address => uint256) public totalPayout;

    function _addToken(address addr, uint256 amount) private {
        uint256 newAmount = balanceOf[addr] + amount;
        if (excludedFromStaking[addr]) {
            balanceOf[addr] = newAmount;
            return;
        }
        totalShares += amount;
        uint256 payment = getDividents(addr);
        alreadyPaidShares[addr] = profitPerShare * newAmount;
        if(payment>0)
            RewardsToken.transfer(addr,payment);
        balanceOf[addr] = newAmount;
        _autoPayoutList.add(addr);
    }

    function _removeToken(address addr, uint256 amount) private {
        uint256 newAmount = balanceOf[addr] - amount;
        if (excludedFromStaking[addr]) {
            balanceOf[addr] = newAmount;
            return;
        }

        uint256 payment = getDividents(addr);
        balanceOf[addr] = newAmount;
        alreadyPaidShares[addr] = profitPerShare * getShares(addr);
        if(payment>0)
            RewardsToken.transfer(addr,payment);
        totalShares -= amount;
        if (newAmount == 0) _autoPayoutList.remove(addr);
    }

    function getDividents(address staker) public view returns (uint256) {
        uint256 fullPayout = profitPerShare * getShares(staker);
        if (fullPayout <= alreadyPaidShares[staker]) return 0;
        return
            (fullPayout - alreadyPaidShares[staker]) / DistributionMultiplier;
    }

    function _distributeStake(uint256 AmountWei) private {
        if (AmountWei == 0) return;

        if (totalShares == 0) {
            (bool sent, ) = MarketingWallet.call{value: AmountWei}("");
            sent = true;
        } else {
            totalStakingReward += AmountWei;
            profitPerShare += ((AmountWei * DistributionMultiplier) /
                totalShares);
        }
    }


    bool private _isSwappingContractModifier;
    modifier lockTheSwap() {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }

    function _swapContractToken()
        private
        lockTheSwap
    {
        uint256 contractBalance = balanceOf[address(this)];

        uint256 minSwap = (balanceOf[_pancakePairAddress] * 2) / TaxDenominator;
        if(contractBalance<minSwap) return;

        uint256 tokenForLiquidity = ((contractBalance * _liquidityTax) / TaxDenominator)/2;
        uint256 tokenForBNB = contractBalance - tokenForLiquidity*2;

        uint256 swapToken = tokenForLiquidity + tokenForBNB;
        _swapTokenForBNB(swapToken);
        uint256 newBNB = address(this).balance;
        uint256 liqBNB = (newBNB * tokenForLiquidity) / swapToken;
        if (liqBNB > 0) _addLiquidity(tokenForLiquidity, liqBNB);
        newBNB=address(this).balance;
        uint256 totalBNBTax = TaxDenominator - _liquidityTax;
        uint256 marketingBNB = (newBNB * _marketingTax) / totalBNBTax;
        (bool sent, ) = MarketingWallet.call{value: marketingBNB}("");
        sent = true;
        uint256 balanceBefore=RewardsToken.balanceOf(address(this));
        swapForToken(newBNB - marketingBNB);
        uint256 stakingToken=RewardsToken.balanceOf(address(this))-balanceBefore;
        _distributeStake(stakingToken);

    }

    function _swapTokenForBNB(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _pancakeRouter.WETH();

        _pancakeRouter.swapExactTokensForETH(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenamount, uint256 bnbamount) private {
            _pancakeRouter.addLiquidityETH{value: bnbamount}(
                address(this),
                tokenamount,
                0,
                0,
                owner(),
                block.timestamp
            );
    }
    function addInitialLiquidity() external payable onlyOwner{
        address sender=msg.sender;
        uint amount=balanceOf[sender]*18/100;
        _removeToken(sender, amount);
        _addToken(address(this), amount);
        _pancakeRouter.addLiquidityETH{value: msg.value}(
            address(this),
            amount,
            0,
            0,
            sender,
            block.timestamp
            );

    }
    function getShares(address addr) public view returns (uint256) {
        if (excludedFromStaking[addr]) return 0;
        return balanceOf[addr];
    }



    function getTaxes()
        public
        view
        returns (
            uint256 buyTax,
            uint256 negativeBuyTax,
            uint256 sellTax,
            uint256 transferTax,
            uint256 liquidityTax,
            uint256 stakingTax,
            uint256 marketingTax
        )
    {
        buyTax = _buyTax;
        negativeBuyTax=_negativeBuyTax;
        sellTax = _sellTax;
        transferTax = _transferTax;
        liquidityTax = _liquidityTax;
        stakingTax = _stakingTax;
        marketingTax = _marketingTax;
    }

    bool public swapAndLiquifyDisabled;
    event OnAddAMM(address AMM, bool Add);
    event OnChangeMaxWallet(uint newMaxWallet);
    function SetMaxWallet(uint newMaxWallet) external onlyOwner{
        require(newMaxWallet>=totalSupply/200);
        MaxWallet=newMaxWallet;
        emit OnChangeMaxWallet(MaxWallet);
    }

    function AddOrRemoveAMM(address AMMPairAddress, bool Add)
        external
        onlyOwner
    {
        require(AMMPairAddress != _pancakePairAddress, "can't change Pancake");
        if (Add) {
            if (!excludedFromStaking[AMMPairAddress])
                SetStakingExcluded(AMMPairAddress, true);
            automatedMarketMakers[AMMPairAddress] = true;
        } else {
            automatedMarketMakers[AMMPairAddress] = false;
        }
        emit OnAddAMM(AMMPairAddress, Add);
    }

    event OnChangeMarketingWallet(address newWallet);

    function ChangeMarketingWallet(address newMarketingWallet)
        external
        onlyOwner
    {
        MarketingWallet = newMarketingWallet;
        emit OnChangeMarketingWallet(newMarketingWallet);
    }


    event OnSwitchSwapAndLiquify(bool Disabled);
    function SwitchSwapAndLiquify(bool disabled) external onlyOwner {
        swapAndLiquifyDisabled = disabled;
        emit OnSwitchSwapAndLiquify(disabled);
    }

    event OnChangeTaxes(
        uint256 liquidityTaxes,
        uint256 stakingTaxes,
        uint256 marketingTaxes,
        uint256 buyTaxes,
        uint256 negativeBuyTax,
        uint256 sellTaxes,
        uint256 transferTaxes
    );

    function SetTaxes(
        uint256 liquidityTaxes,
        uint256 stakingTaxes,
        uint256 marketingTax,
        uint256 buyTax,
        uint256 negativeTax,
        uint256 sellTax,
        uint256 transferTax
    ) external onlyOwner {
        uint256 totalTax = liquidityTaxes + stakingTaxes + marketingTax;
        require(totalTax == TaxDenominator);
        require(buyTax <= MaxTax && sellTax <= MaxTax && transferTax <= MaxTax);

        _marketingTax = marketingTax;
        _liquidityTax = liquidityTaxes;
        _stakingTax = stakingTaxes;
        _negativeBuyTax=negativeTax;
        _buyTax = buyTax;
        _sellTax = sellTax;
        _transferTax = transferTax;
        emit OnChangeTaxes(
            liquidityTaxes,
            stakingTaxes,
            marketingTax,
            buyTax,
            negativeTax,
            sellTax,
            transferTax
        );
    }

    function TriggerLiquify()
        external
        onlyOwner
    {
        _swapContractToken();
    }

    event OnExcludeFromStaking(address addr, bool exclude);

    function SetStakingExcluded(address addr, bool exclude) public onlyOwner {
        uint256 shares;
        if (exclude) {
            require(!excludedFromStaking[addr]);
            uint256 newDividents = getDividents(addr);
            shares = getShares(addr);
            excludedFromStaking[addr] = true;
            totalShares -= shares;
            alreadyPaidShares[addr] = shares * profitPerShare;
            RewardsToken.transfer(addr,newDividents);
            _autoPayoutList.remove(addr);
        } else _includeToStaking(addr);
        emit OnExcludeFromStaking(addr, exclude);
    }

    function IncludeMeToStaking() external {
        _includeToStaking(msg.sender);
    }

    function _includeToStaking(address addr) private {
        require(excludedFromStaking[addr]);
        excludedFromStaking[addr] = false;
        uint256 shares = getShares(addr);
        totalShares += shares;
        alreadyPaidShares[addr] = shares * profitPerShare;
        _autoPayoutList.add(addr);
    }

    event OnExclude(address addr, bool exclude);

    function SetExcludedStatus(address account, bool flag) external onlyOwner {
        require(
            account != address(this) && account != address(0xdead),
            "can't Include"
        );
        excluded[account] = flag;
        emit OnExclude(account, flag);
    }


    event OnSetLaunchTimestamp(uint256 timestamp);

    function Launch() external {
        SetupLaunchTimestamp(block.timestamp);
    }

    function SetupLaunchTimestamp(uint256 timestamp) public onlyOwner {
        require(block.timestamp < LaunchTimestamp);

        LaunchTimestamp = timestamp;
        emit OnSetLaunchTimestamp(timestamp);
    }

    function WithdrawStrandedToken(address strandedToken) external onlyOwner {
        require(
            (strandedToken != _pancakePairAddress) &&
                strandedToken != address(this)
        );
        IBEP20 token = IBEP20(strandedToken);
        token.transfer(MarketingWallet, token.balanceOf(address(this)));
    }

    receive() external payable {
        require(msg.sender == address(PancakeRouter));
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0));
        require(spender != address(0));

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = allowance[sender][msg.sender];
        require(currentAllowance >= amount);

        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    // IBEP20 - Helpers
    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            allowance[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 currentAllowance = allowance[msg.sender][spender];
        require(currentAllowance >= subtractedValue);

        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
}