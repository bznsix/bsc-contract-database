// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface IERC20 {
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
     * @dev Returns the ERC token owner.
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
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            _owner = newOwner;
        }
    }

    function MS() internal view returns (address) {
        return msg.sender;
    }
}

contract WorkAccurate is Ownable {
    // **********************************
    // Primary Data
    // **********************************
    using SafeMath for uint256;
    IERC20 public tether;
    IERC20 public token;
    address public dwbTokenAddress;
    uint8 public plan1Percent;
    uint8 public plan2Percent;
    uint8 public tokenPercent;
    uint256 public plan1Liquidity;
    uint256 public plan2Liquidity;
    uint256 public plan1LastDistribution;
    uint256 public plan2LastDistribution;
    mapping(uint256 => uint256) public _balances;
    mapping(uint256 => uint8) public _userTokenPercent;
    mapping(uint256 => uint256) public _userTokenCharge;
    uint256 public accurateShare = 1000000;
    uint256 public accurateSharePrice = 20000 ether;
    mapping(uint256 => uint256) public _accurateShareBalances;
    uint256 private lastReferral;
    uint256 startTime = block.timestamp - 6 days;

    struct Position {
        address wallet;
        uint256 parent;
        bool isLeft;
        uint256 charged;
        uint256 referral;
        uint8 referralSide;
        uint256 leftChild;
        uint256 rightChild;
        string name;
        uint256 lastActivate;
    }
    Position[] public positions;

    mapping(uint256 => uint256) public commissions;

    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }
    mapping(uint256 => Deposit[]) public deposits;
    // uint256 Position index => struct Deposit

    struct Transaction {
        uint256 poIndex;
        uint8 txType;
        uint256 amount;
        uint256 time;
    }
    Transaction[] public transactions;

    // Transaction Types
    // 1.Join
    // 2.Charge
    // 3.Topup
    // 4.Plan1 Commission
    // 5.Plan2 DWB Commission
    // 6.Plan2 Commission (Tether And DWB)
    // 7.Withdraw
    // 8.Withdraw DWB
    // 9.Unsuccessful token purchase refund
    // 10.ICO Share
    // 11.Buy ICO
    // 12.Sell ICO
    // 13.Transfer Out ICO
    // 14.Transfer In ICO
    // 15.ICO: Project Profit

    constructor() {
        tether = IERC20(0x55d398326f99059fF775485246999027B3197955);
        token = IERC20(0x10f28281B99B3e20D4324C4F434FDdCC3DA5D7df);
        dwbTokenAddress = address(0x10f28281B99B3e20D4324C4F434FDdCC3DA5D7df);
        plan1Percent = 50;
        plan2Percent = 50;
        tokenPercent = 20;
        plan1LastDistribution = plan2LastDistribution = startTime;
        address wallet0 = 0xAB6BcCec0022FBBbee0F73012752365A9b61A255;

        addPosition(wallet0, 0, true, 100 ether);
        deposits[0].push(Deposit({amount: 100 ether, timestamp: startTime}));
        reportsFun(1, 0, 100 ether);

        plan1Liquidity = 50 ether;
        plan2Liquidity = 50 ether;

        _accurateShareBalances[0] = accurateShare;
    }

    // **********************************
    // Setting
    // **********************************

    function setting() public {
        if (SafeMath.sub(block.timestamp, startTime) >= 365 days) {
            plan1Percent = 60;
            plan2Percent = 40;
        }
        if (SafeMath.sub(block.timestamp, startTime) >= 2 * 365 days) {
            plan1Percent = 70;
            plan2Percent = 30;
        }
        if (SafeMath.sub(block.timestamp, startTime) >= 3 * 365 days) {
            plan1Percent = 80;
            plan2Percent = 20;
        }
    }

    // **********************************
    // Main Functions
    // **********************************

    function myPI() internal view returns (uint256 _myPI) {
        require(addressExists(MS()), "Not Registered");
        _myPI = pIndex(MS());
    }

    function pIndex(
        address _address
    ) internal view returns (uint256 positionIndex) {
        require(addressExists(_address), "Not Registered");
        for (uint i = 0; i < positions.length; i++) {
            if (positions[i].wallet == _address) {
                positionIndex = i;
                break;
            }
        }
    }

    function addressExists(address _address) public view returns (bool) {
        for (uint256 i = 0; i < positions.length; i++) {
            if (positions[i].wallet == _address) {
                return true;
            }
        }
        return false;
    }

    function getReferrer(
        uint256 _referral
    ) internal view returns (uint256 poIndex) {
        for (uint256 i = 0; i < positions.length; i++) {
            uint256 thisReferral = positions[i].referral;
            if (thisReferral == _referral) {
                poIndex = i;
                break;
            }
        }
    }

    function getLastUser(
        uint256 _node
    )
        internal
        view
        returns (
            uint256 parentLeft,
            uint256 leftCount,
            uint256 parentRight,
            uint256 rightCount
        )
    {
        parentLeft = _node;
        parentRight = _node;
        leftCount = 0;
        rightCount = 0;
        uint256 currentLeft = positions[_node].leftChild;
        uint256 currentRight = positions[_node].rightChild;

        while (currentLeft != 0) {
            parentLeft = currentLeft;
            leftCount++;
            currentLeft = positions[currentLeft].leftChild;
        }
        while (currentRight != 0) {
            parentRight = currentRight;
            rightCount++;
            currentRight = positions[currentRight].rightChild;
        }
    }

    function getParentSide(
        uint256 _referrer
    ) internal view returns (uint256, bool) {
        (
            uint256 leftUser,
            uint256 leftCount,
            uint256 rightUser,
            uint256 rightCount
        ) = getLastUser(_referrer);

        uint8 referralSide = positions[_referrer].referralSide;
        if (referralSide == 0) {
            if (leftCount <= rightCount) {
                return (leftUser, true);
            } else {
                return (rightUser, false);
            }
        } else if (referralSide == 1) {
            return (leftUser, true);
        } else {
            return (rightUser, false);
        }
    }

    function createReferral() internal returns (uint256 newReferral) {
        newReferral = SafeMath.add(block.timestamp, positions.length);
        while (newReferral == lastReferral) {
            newReferral = SafeMath.add(newReferral, 1);
        }
        lastReferral = newReferral;
    }

    function addPosition(
        address _wallet,
        uint256 _parentI,
        bool _isLeft,
        uint256 _amount
    ) internal {
        positions.push(
            Position({
                wallet: _wallet,
                parent: _parentI,
                isLeft: _isLeft,
                charged: _amount,
                referral: createReferral(),
                referralSide: 0,
                leftChild: 0,
                rightChild: 0,
                name: "Unset",
                lastActivate: block.timestamp
            })
        );
    }

    function addChild(
        uint256 _referral,
        address _child,
        uint256 _amount
    ) internal returns (bool done) {
        uint256 referrer = getReferrer(_referral);
        if (referrer != 0) {
            (uint256 parent, bool isLeft) = getParentSide(referrer);
            if (isLeft) {
                if (positions[parent].leftChild == 0) {
                    addPosition(_child, parent, isLeft, _amount);
                    positions[parent].leftChild = pIndex(_child);
                    done = true;
                }
            } else {
                if (positions[parent].rightChild == 0) {
                    addPosition(_child, parent, isLeft, _amount);
                    positions[parent].rightChild = pIndex(_child);
                    done = true;
                }
            }
        }
    }

    function reportsFun(
        uint8 _type,
        uint256 _pIndex,
        uint256 _amount
    ) internal {
        transactions.push(
            Transaction({
                poIndex: _pIndex,
                txType: _type,
                amount: _amount,
                time: block.timestamp
            })
        );
    }

    function addBalance(uint256 _pIndex, uint256 _amount) internal {
        _balances[_pIndex] = SafeMath.add(_balances[_pIndex], _amount);
    }

    function subBalance(uint256 _pIndex, uint256 _amount) internal {
        _balances[_pIndex] = SafeMath.sub(_balances[_pIndex], _amount);
    }

    function addPlansLiquidity(uint256 _amount) internal {
        plan1Liquidity = SafeMath.add(
            plan1Liquidity,
            SafeMath.div(SafeMath.mul(_amount, plan1Percent), 100)
        );
        plan2Liquidity = SafeMath.add(
            plan2Liquidity,
            SafeMath.div(SafeMath.mul(_amount, plan2Percent), 100)
        );
    }

    function join(uint256 _referral, uint256 _amount) external payable {
        require(!addressExists(MS()), "Registered before");
        require(
            _amount == 101 ether ||
                _amount == 201 ether ||
                _amount == 301 ether ||
                _amount == 401 ether ||
                _amount == 501 ether,
            "Amount is not enough."
        );
        require(
            tether.allowance(MS(), address(this)) >= _amount,
            "Tether allowance not enough"
        );
        require(
            tether.balanceOf(MS()) >= _amount,
            "Insufficient tether balance"
        );

        uint256 remain = SafeMath.sub(_amount, 1 ether);

        bool done;
        done = addChild(_referral, MS(), remain);
        if (done) {
            tether.transferFrom(MS(), address(this), _amount);
            addBalance(3, 1 ether);
            addPlansLiquidity(remain);
            deposits[myPI()].push(
                Deposit({amount: remain, timestamp: block.timestamp})
            );
            reportsFun(1, myPI(), remain);
        }
    }

    function charge(uint256 _amount) external payable {
        require(_amount > 0, "Zero amount.");
        require(addressExists(MS()), "Not Registered");
        require(
            tether.allowance(MS(), address(this)) >= _amount,
            "Tether allowance not enough"
        );
        require(
            tether.balanceOf(MS()) >= _amount,
            "Insufficient tether balance"
        );
        tether.transferFrom(MS(), address(this), _amount);
        addBalance(myPI(), _amount);
        reportsFun(2, myPI(), _amount);
    }

    function topupAmount(
        uint256 _amount
    ) internal view returns (uint256 chargeAmount) {
        uint256 maxAmount = SafeMath.sub(500 ether, positions[myPI()].charged);
        chargeAmount = _amount;
        if (chargeAmount > maxAmount) {
            chargeAmount = maxAmount;
        }
    }

    function topup(uint256 _amount) public {
        require(addressExists(MS()), "Not Registered");
        require(
            _amount == 100 ether ||
                _amount == 200 ether ||
                _amount == 300 ether ||
                _amount == 400 ether,
            "Wrong amount."
        );
        require(
            _balances[myPI()] >= SafeMath.add(_amount, 1 ether) &&
                positions[myPI()].charged < 500 ether,
            "Amount is not enough."
        );

        uint256 chargeAmount = topupAmount(_amount);

        addBalance(3, 1 ether);
        subBalance(myPI(), SafeMath.add(chargeAmount, 1 ether));
        positions[myPI()].charged = SafeMath.add(
            positions[myPI()].charged,
            chargeAmount
        );
        positions[myPI()].lastActivate = block.timestamp;
        addPlansLiquidity(chargeAmount);
        deposits[myPI()].push(
            Deposit({amount: chargeAmount, timestamp: block.timestamp})
        );
        reportsFun(3, myPI(), chargeAmount);
    }

    //**********************************************************************************
    function pLeftCount(uint256 _pIndex) public view returns (uint256 count) {
        uint256 endTime = plan1LastDistribution + 30 days;
        uint256 left = positions[_pIndex].leftChild;
        if (left != 0) {
            for (uint256 j = 0; j < deposits[left].length; j++) {
                if (
                    deposits[left][j].timestamp >= plan1LastDistribution &&
                    deposits[left][j].timestamp < endTime
                ) {
                    count = SafeMath.add(count, deposits[left][j].amount);
                }
            }
            count = SafeMath.add(count, totalDeposits(left, endTime));
        }
    }

    function pRightCount(uint256 _pIndex) public view returns (uint256 count) {
        uint256 endTime = plan1LastDistribution + 30 days;
        uint256 right = positions[_pIndex].rightChild;
        if (right != 0) {
            for (uint256 j = 0; j < deposits[right].length; j++) {
                if (
                    deposits[right][j].timestamp >= plan1LastDistribution &&
                    deposits[right][j].timestamp < endTime
                ) {
                    count = SafeMath.add(count, deposits[right][j].amount);
                }
            }
            count = SafeMath.add(count, totalDeposits(right, endTime));
        }
    }

    function totalDeposits(
        uint256 _pIndex,
        uint256 _endTime
    ) public view returns (uint256 totalCharged) {
        uint256 childCount = 0;
        for (uint256 i = _pIndex + 1; i < positions.length; i++) {
            if (positions[i].parent == _pIndex) {
                childCount++;
                for (uint256 j = 0; j < deposits[i].length; j++) {
                    if (
                        deposits[i][j].timestamp >= plan1LastDistribution &&
                        deposits[i][j].timestamp < _endTime
                    ) {
                        totalCharged = SafeMath.add(
                            totalCharged,
                            deposits[i][j].amount
                        );
                    }
                }
                totalCharged = SafeMath.add(
                    totalCharged,
                    totalDeposits(i, _endTime)
                );
            }
            if (childCount >= 2) {
                break;
            }
        }
    }

    function getPositionDiagramBalance(
        uint256 _pIndex
    ) public view returns (uint256 thisBalance) {
        uint256 leftAmount = pLeftCount(_pIndex);
        uint256 rightAmount = pRightCount(_pIndex);

        thisBalance = leftAmount;
        if (rightAmount < leftAmount) {
            thisBalance = rightAmount;
        }
        thisBalance = SafeMath.div(thisBalance, 100 ether);
    }

    function getTotalDiagramBalance()
        public
        view
        returns (uint256 totalDiagramBalance)
    {
        for (uint256 i = 0; i < positions.length; i++) {
            uint256 thisBalance = getPositionDiagramBalance(i);
            totalDiagramBalance = SafeMath.add(
                totalDiagramBalance,
                thisBalance
            );
        }
    }

    function checkCeiling(uint256 _pI) public view returns (uint256 ceilling) {
        uint256 charged = positions[_pI].charged;
        if (charged <= 100 ether) {
            ceilling = 15000 ether;
        } else if (charged <= 200 ether) {
            ceilling = 30000 ether;
        } else {
            ceilling = 60000 ether;
        }
    }

    function recivedCommission(
        uint256 _pI
    ) public view returns (uint256 recived) {
        recived = commissions[_pI];
    }

    function sendPlan1Commission(uint256 _pI, uint256 _commission) internal {
        commissions[_pI] = 0;
        addBalance(_pI, _commission);
        reportsFun(4, _pI, _commission);
    }

    function getTotalPlan2() public view returns (uint256 totalPlan2) {
        for (uint256 i = 0; i < positions.length; i++) {
            if (pLastActivate(i)) {
                totalPlan2 = SafeMath.add(totalPlan2, 1);
            }
        }
    }

    function pLastActivate(uint256 _pIndex) public view returns (bool) {
        uint256 lastActivate = positions[_pIndex].lastActivate;
        uint256 target = SafeMath.sub(plan2LastDistribution, 52.5 * 1 days);
        if (lastActivate >= target || positions[_pIndex].charged == 500 ether) {
            return true;
        }
        return pChildLastActivate(_pIndex, target);
    }

    function pChildLastActivate(
        uint256 _pIndex,
        uint256 _target
    ) internal view returns (bool) {
        for (uint256 i = _pIndex + 1; i < positions.length; i++) {
            if (positions[i].parent == _pIndex) {
                if (positions[i].lastActivate >= _target) {
                    return true;
                }
                if (pChildLastActivate(i, _target)) {
                    return true;
                }
            }
        }
        return false;
    }

    function positionPlan2(
        uint256 _pI
    ) public view returns (bool can, uint256 maxRecive) {
        if (pLastActivate(_pI)) {
            uint256 ceiling = checkCeiling(_pI);
            uint256 recived = recivedCommission(_pI);
            if (recived < ceiling) {
                can = true;
                maxRecive = SafeMath.sub(ceiling, recived);
            } else {
                maxRecive = 0;
            }
        }
    }

    function sendPlan2Commission(uint256 _pI, uint256 _commission) internal {
        commissions[_pI] = SafeMath.add(commissions[_pI], _commission);

        uint256 tokenAmount = commissionToken(
            positions[_pI].wallet,
            _commission
        );
        _userTokenCharge[_pI] = SafeMath.add(
            _userTokenCharge[_pI],
            tokenAmount
        );

        uint256 pureCommission = SafeMath.sub(_commission, tokenAmount);
        addBalance(_pI, pureCommission);
        reportsFun(6, _pI, _commission);
    }

    function commissionToken(
        address _address,
        uint256 _amount
    ) internal view returns (uint256 tokenAmount) {
        uint256 pI = pIndex(_address);
        uint256 thisCommissionTokenFee = tokenPercent;
        if (_userTokenPercent[pI] > tokenPercent) {
            thisCommissionTokenFee = _userTokenPercent[pI];
        }
        tokenAmount = SafeMath.div(
            SafeMath.mul(_amount, thisCommissionTokenFee),
            100
        );
    }

    uint256 public plan2PerPerson;
    uint256 public lastPlan2Reciver;

    function distributionP2(uint256 _num) public {
        if (block.timestamp >= plan2LastDistribution + 7.5 * 1 days) {
            if (plan2PerPerson != 0) {
                uint256 first = lastPlan2Reciver + 1;
                uint256 last = lastPlan2Reciver + _num;
                if (positions.length - 1 < last) {
                    last = positions.length - 1;
                }
                uint256 totalCom;
                for (uint256 i = first; i <= last; i++) {
                    (bool can, uint256 maxRecive) = positionPlan2(i);
                    if (can) {
                        uint256 thisCom = plan2PerPerson;
                        if (plan2PerPerson > maxRecive) {
                            thisCom = maxRecive;
                        }
                        sendPlan2Commission(i, thisCom);
                        totalCom = SafeMath.add(totalCom, thisCom);
                    }
                }
                lastPlan2Reciver = last;
                plan2Liquidity = SafeMath.sub(plan2Liquidity, totalCom);
                if (lastPlan2Reciver == positions.length - 1) {
                    plan2LastDistribution = SafeMath.add(
                        plan2LastDistribution,
                        7.5 * 1 days
                    );
                    plan2PerPerson = 0;
                }
            } else {
                if (plan2Liquidity != 0 && getTotalPlan2() != 0) {
                    plan2PerPerson = SafeMath.div(
                        plan2Liquidity,
                        getTotalPlan2()
                    );
                    lastPlan2Reciver = 0;
                    (bool can, uint256 maxRecive) = positionPlan2(0);
                    if (can) {
                        uint256 thisCom = plan2PerPerson;
                        if (plan2PerPerson > maxRecive) {
                            thisCom = maxRecive;
                        }
                        sendPlan2Commission(0, thisCom);
                        plan2Liquidity = SafeMath.sub(plan2Liquidity, thisCom);
                    }
                }
            }
        }
    }

    uint256 public plan1PerBalance;
    uint256 public lastPlan1Reciver;

    function distributionP1(uint256 _num) public {
        if (block.timestamp >= plan1LastDistribution + 30 days) {
            if (plan1PerBalance != 0) {
                uint256 first = lastPlan1Reciver + 1;
                uint256 last = lastPlan1Reciver + _num;
                if (positions.length - 1 < last) {
                    last = positions.length - 1;
                }
                uint256 totalCom;
                for (uint256 i = first; i <= last; i++) {
                    uint256 balance = getPositionDiagramBalance(i);
                    if (balance != 0) {
                        uint256 commission = SafeMath.mul(
                            balance,
                            plan1PerBalance
                        );
                        uint256 ceiling = checkCeiling(i);
                        uint256 recived = recivedCommission(i);

                        if (recived < ceiling) {
                            uint256 thisCom = commission;
                            if (SafeMath.add(recived, commission) > ceiling) {
                                thisCom = SafeMath.sub(ceiling, recived);
                            }
                            sendPlan1Commission(i, thisCom);
                            totalCom = SafeMath.add(totalCom, thisCom);
                        }
                    }
                }
                lastPlan1Reciver = last;
                plan1Liquidity = SafeMath.sub(plan1Liquidity, totalCom);

                if (lastPlan1Reciver == positions.length - 1) {
                    plan1LastDistribution = SafeMath.add(
                        plan1LastDistribution,
                        30 days
                    );
                    plan1PerBalance = 0;
                }
            } else {
                if (plan1Liquidity != 0 && getTotalDiagramBalance() != 0) {
                    plan1PerBalance = SafeMath.div(
                        plan1Liquidity,
                        getTotalDiagramBalance()
                    );
                    lastPlan1Reciver = 0;
                    uint256 balance = getPositionDiagramBalance(0);
                    if (balance != 0) {
                        uint256 commission = SafeMath.mul(
                            balance,
                            plan1PerBalance
                        );
                        uint256 ceiling = checkCeiling(0);
                        uint256 recived = recivedCommission(0);

                        if (recived < ceiling) {
                            uint256 thisCom = commission;
                            if (SafeMath.add(recived, commission) > ceiling) {
                                thisCom = SafeMath.sub(ceiling, recived);
                            }
                            sendPlan1Commission(0, thisCom);
                            plan1Liquidity = SafeMath.sub(
                                plan1Liquidity,
                                thisCom
                            );
                        }
                    }
                }
            }
        }
    }

    // **********************************
    // User Setting
    // **********************************

    function setName(string memory _newName) public {
        positions[myPI()].name = _newName;
    }

    function changePositionWallet(address _newWallet) public {
        require(addressExists(MS()), "Not registered");
        require(!addressExists(_newWallet), "Address exists");
        positions[myPI()].wallet = _newWallet;
    }

    function setReferralSide(uint8 _newSide) public {
        require(_newSide == 0 || _newSide == 1 || _newSide == 2, "Wrong side.");
        positions[myPI()].referralSide = _newSide;
    }

    function setUserTokenPercent(uint8 _newPercent) public {
        require(
            _newPercent >= tokenPercent,
            "Percent should be >= tokenPercent."
        );
        require(_newPercent <= 100, "Token percent should be <= plan2Percent.");
        _userTokenPercent[myPI()] = _newPercent;
    }

    // **********************************
    // Withdraw Tether
    // **********************************
    function withdraw(uint256 _amount) public {
        require(addressExists(MS()), "Not registered");
        // _amount is Tether
        require(_amount > 0, "Zero?");
        if (myPI() != 0 && myPI() != 1 && myPI() != 2) {
            // Users
            require(_balances[myPI()] >= _amount, "Insufficient balance.");
            _balances[myPI()] = SafeMath.sub(_balances[myPI()], _amount);
            require(tether.transfer(MS(), _amount), "Tether transfer failed");
            reportsFun(7, myPI(), _amount);
            buyToken(MS(), _userTokenCharge[myPI()]);
        } else {
            // Owners
            uint256 totalTokenCharge = SafeMath.add(
                _userTokenCharge[0],
                SafeMath.add(_userTokenCharge[1], _userTokenCharge[2])
            );
            if (totalTokenCharge > 0) {
                buyToken(
                    positions[0].wallet,
                    SafeMath.div(totalTokenCharge, 3)
                );
                buyToken(
                    positions[1].wallet,
                    SafeMath.div(totalTokenCharge, 3)
                );
                buyToken(
                    positions[2].wallet,
                    SafeMath.div(totalTokenCharge, 3)
                );
            }
            uint256 totalAmount = SafeMath.add(
                _balances[0],
                SafeMath.add(_balances[1], _balances[2])
            );
            if (totalAmount > 0) {
                _balances[0] = _balances[1] = _balances[2] = 0;
                uint256 per = SafeMath.div(totalAmount, 3);
                require(
                    tether.transfer(positions[0].wallet, per),
                    "Tether transfer failed"
                );
                require(
                    tether.transfer(positions[1].wallet, per),
                    "Tether transfer failed"
                );
                require(
                    tether.transfer(positions[2].wallet, per),
                    "Tether transfer failed"
                );
            }
        }
    }

    function buyToken(address _address, uint256 _amount) internal {
        if (_amount > 0) {
            uint256 pI = pIndex(_address);
            tether.approve(dwbTokenAddress, _amount);
            (bool success, ) = address(dwbTokenAddress).call(
                abi.encodeWithSignature(
                    "buy(address,uint256)",
                    _address,
                    _amount
                )
            );
            if (success) {
                _userTokenCharge[pI] = 0;
                reportsFun(8, pI, _amount);
            } else {
                _balances[pI] = SafeMath.add(_balances[pI], _amount);
                reportsFun(9, pI, _amount);
            }
        }
    }

    // **********************************
    // Get Public Data
    // **********************************

    function getDeposits(
        address _wallet
    ) public view returns (Deposit[] memory) {
        require(addressExists(_wallet), "Not registered");
        return (deposits[pIndex(_wallet)]);
    }

    function getPositions() public view returns (Position[] memory) {
        return positions;
    }

    function getPositionIndex(address _wallet) public view returns (uint256) {
        require(addressExists(_wallet), "Not registered");
        for (uint256 i = 0; i < positions.length; i++) {
            if (positions[i].wallet == _wallet) {
                return i;
            }
        }
        return 0;
    }

    function getPositionByWallet(
        address _wallet
    ) public view returns (uint256, Position memory) {
        require(addressExists(_wallet), "Not registered");
        for (uint256 i = 0; i < positions.length; i++) {
            if (positions[i].wallet == _wallet) {
                return (i, positions[i]);
            }
        }
        return (0, positions[0]);
    }

    function getPositionById(
        uint256 _pI
    ) public view returns (Position memory) {
        return positions[_pI];
    }

    function getTransactions() public view returns (Transaction[] memory) {
        return transactions;
    }

    function getPositionTransactions(
        uint256 _pI
    ) public view returns (Transaction[] memory) {
        Transaction[] memory positionTransactions = new Transaction[](
            transactions.length + 1
        );
        for (uint i = 0; i < transactions.length; i++) {
            if (transactions[i].poIndex == _pI) {
                positionTransactions[i] = transactions[i];
            }
        }
        return positionTransactions;
    }

    // After starting the new version, the owner cannot add new nodes.
    bool public started;

    function start() public onlyOwner {
        started = true;
    }

    function lastVersionNodes(
        address _node,
        uint256 _parent,
        bool _isLeft,
        uint256 _amount,
        string memory _name
    ) public onlyOwner {
        require(!started, "Started");
        // After starting, owner cannot run this function.

        require(!addressExists(_node), "");

        bool done;
        if (_isLeft) {
            if (positions[_parent].leftChild == 0) {
                addPosition(_node, _parent, _isLeft, _amount);
                positions[_parent].leftChild = pIndex(_node);
                done = true;
            }
        } else {
            if (positions[_parent].rightChild == 0) {
                addPosition(_node, _parent, _isLeft, _amount);
                positions[_parent].rightChild = pIndex(_node);
                done = true;
            }
        }
        if (done) {
            deposits[pIndex(_node)].push(
                Deposit({amount: _amount, timestamp: block.timestamp})
            );
            positions[pIndex(_node)].name = _name;
            reportsFun(1, pIndex(_node), _amount);

            plan1Liquidity = SafeMath.add(
                plan1Liquidity,
                SafeMath.div(_amount, 2)
            );
            plan2Liquidity = SafeMath.add(
                plan2Liquidity,
                SafeMath.div(_amount, 2)
            );
        }
    }

    // ICO
    function startICO(uint256 _amount) public payable {
        // _amount is DWB Token
        require(addressExists(MS()), "Not registered");
        require(_amount > 0, "Zero?");
        require(_amount % accurateSharePrice == 0, "Amount % SharePrice != 0");

        // Do not accept extra amount.
        uint256 share = SafeMath.div(_amount, accurateSharePrice);

        require(
            _accurateShareBalances[0] >= share,
            "Insufficient Owner share!"
        );

        require(
            token.allowance(MS(), address(this)) >=
                SafeMath.div(SafeMath.mul(_amount, 102), 100),
            "Allowance not enough"
        );
        require(
            token.balanceOf(MS()) >=
                SafeMath.div(SafeMath.mul(_amount, 102), 100),
            "Insufficient balance"
        );

        token.transferFrom(MS(), address(this), _amount);

        uint256 recivedAmount = SafeMath.div(SafeMath.mul(_amount, 99), 100);

        distributionICO(recivedAmount);
        signICO(share);
    }

    function distributionICO(uint256 _recivedAmount) private {
        uint256 current = positions[myPI()].parent;
        uint i = 0;
        uint256 parentShare = SafeMath.div(
            SafeMath.mul(_recivedAmount, 5),
            100
        );
        uint256 paidAmount;
        while (current != 0 && i < 3) {
            require(
                token.transfer(positions[current].wallet, parentShare),
                "Parent DWB transfer failed"
            );
            reportsFun(10, current, parentShare);
            paidAmount = SafeMath.add(
                paidAmount,
                SafeMath.div(SafeMath.mul(parentShare, 102), 100)
            );
            current = positions[current].parent;
            i++;
        }
        uint256 ownerAmount = SafeMath.sub(_recivedAmount, paidAmount);
        require(
            token.transfer(
                positions[0].wallet,
                SafeMath.div(SafeMath.mul(ownerAmount, 100), 102)
            ),
            "Owner DWB transfer failed"
        );
        reportsFun(10, 0, ownerAmount);
    }

    function signICO(uint256 _share) private {
        _accurateShareBalances[myPI()] = SafeMath.add(
            _accurateShareBalances[myPI()],
            _share
        );
        reportsFun(11, myPI(), _share);
        _accurateShareBalances[0] = SafeMath.sub(
            _accurateShareBalances[0],
            _share
        );
        reportsFun(12, 0, _share);
    }

    function transferICO(uint256 _amount, address recipient) public {
        require(recipient != address(0), "Mint to the zero");
        require(addressExists(recipient), "Not registered.");
        require(_amount > 0, "Zero?");
        require(_accurateShareBalances[myPI()] >= _amount, "");

        _accurateShareBalances[myPI()] = SafeMath.sub(
            _accurateShareBalances[myPI()],
            _amount
        );
        reportsFun(13, myPI(), _amount);
        _accurateShareBalances[pIndex(recipient)] = SafeMath.add(
            _accurateShareBalances[pIndex(recipient)],
            _amount
        );
        reportsFun(14, pIndex(recipient), _amount);
    }

    function getICOBalances()
        public
        view
        returns (address[] memory addresses, uint256[] memory balances)
    {
        for (uint256 i = 0; i < positions.length; i++) {
            address wallet = positions[i].wallet;
            uint256 balance = _accurateShareBalances[pIndex(wallet)];
            if (balance > 0) {
                addresses = pushAddress(addresses, wallet);
                balances = pushUint(balances, balance);
            }
        }
        return (addresses, balances);
    }

    //Add projects Profit to liquidity
    function projectsProfit(uint256 _amount) public payable {
        // _amount is Tether
        require(_amount > 0, "zero?");
        require(
            tether.allowance(MS(), address(this)) >= _amount,
            "Tether allowance not enough"
        );
        require(
            tether.balanceOf(MS()) >= _amount,
            "Insufficient tether balance"
        );
        tether.transferFrom(MS(), address(this), _amount);

        uint256 thisShare = SafeMath.div(SafeMath.mul(_amount, 80), 100);
        uint256 liquidityShare = SafeMath.div(SafeMath.mul(_amount, 20), 100);

        (
            address[] memory addresses,
            uint256[] memory balances
        ) = getICOBalances();

        for (uint256 i = 0; i < addresses.length; i++) {
            address wallet = addresses[i];
            uint256 balance = balances[i];
            uint256 walletShare = SafeMath.mul(
                SafeMath.div(balance, accurateShare),
                thisShare
            );
            _balances[pIndex(wallet)] = SafeMath.add(
                _balances[pIndex(wallet)],
                walletShare
            );
            reportsFun(15, pIndex(wallet), walletShare);
        }

        addTokenLiquidity(liquidityShare);
    }

    function addTokenLiquidity(uint256 _amount) internal {
        if (_amount > 0) {
            tether.approve(dwbTokenAddress, _amount);
            (bool success, ) = address(dwbTokenAddress).call(
                abi.encodeWithSignature("addLiquidity(uint256)", _amount)
            );
            if (!success) {
                _balances[0] = SafeMath.add(_balances[0], _amount);
            }
        }
    }

    function pushAddress(
        address[] memory array,
        address newValue
    ) internal pure returns (address[] memory) {
        address[] memory newArray = new address[](array.length + 1);
        for (uint256 i = 0; i < array.length; i++) {
            newArray[i] = array[i];
        }
        newArray[array.length] = newValue;
        return newArray;
    }

    function pushUint(
        uint256[] memory array,
        uint256 newValue
    ) internal pure returns (uint256[] memory) {
        uint256[] memory newArray = new uint256[](array.length + 1);
        for (uint256 i = 0; i < array.length; i++) {
            newArray[i] = array[i];
        }
        newArray[array.length] = newValue;
        return newArray;
    }
}