// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

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

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface AggregatorV3Interface {
    function latestAnswer() external view returns (int256);

    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Credit is Ownable {
    using SafeMath for uint256;

    uint32 internal dayTimeStemp = 86400;
    uint32 internal monthTimeStemp = 2592000;
    uint32 internal lastWithdrawDay = 19739;
    IERC20 public commissionToken;
    uint256 public commissionAmount = 3000 ether;
    IERC20 public creditToken;
    uint8 internal decimals = 18;
    uint256 private latePaymentFee = 30 ether;
    uint256 private earlyRepaymentFee = 30 ether;
    address public stakingAddress;
    uint256 public minAmount = 1000 ether;

    struct CreditData {
        uint24 loanRate;
        uint24 loanRateDiv;
        uint8 term;
    }

    struct DepositData {
        uint256 depositRate;
        uint256 depositRateDiv;
        address aggregatorV3Interface;
        uint8 decimals;
        uint32 lastWithdrawDay;
    }

    struct CreditorData {
        address depositTokenAddress;
        uint256 depositAmount;
        uint32 nextPaymentTimeStemp;
        uint8 term;
        uint256 paidOut;
        uint256 amount;
        uint256 interest;
    }

    mapping(address => DepositData) public depositTokens;
    mapping(uint8 => CreditData) public creditData;
    mapping(address => CreditorData) internal creditor;

    mapping(uint32 => mapping(address => uint256)) internal withdrawData;

    constructor(
        address _stakingAddress
    ) {
        creditToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
        commissionToken = IERC20(0xA80D88D15c315a8f40229fed2d01551747B97FD2);
        creditData[1] = CreditData(12, 100, 1);
        creditData[2] = CreditData(12, 100, 2);
        creditData[3] = CreditData(11, 100, 3);
        creditData[6] = CreditData(10, 100, 6);
        depositTokens[address(0)] = DepositData(7, 10, 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE, 18, 19739);
        depositTokens[0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c] = DepositData(7, 10, 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf, 18, 19739);
        depositTokens[0x2170Ed0880ac9A755fd29B2688956BD959F933F8] = DepositData(7, 10, 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e, 18, 19739);

        stakingAddress = _stakingAddress;
    }

    function getData() public view returns(CreditorData memory) {
        return creditor[msg.sender];
    }

    function credit(uint256 _amount, uint8 _term, address _depositToken) public {
        require(_amount >= minAmount, "Less than the minimum value");
        if (
            (creditor[msg.sender].paidOut < creditor[msg.sender].amount.add(creditor[msg.sender].interest.mul(creditor[msg.sender].term))) && 
            block.timestamp <= (creditor[msg.sender].nextPaymentTimeStemp + (15 * dayTimeStemp))
        ) {
            require(false, "You already have a loan");
        }

        require(_depositToken != address(0), "To deposit in BNB, you need to call creditBNB()");
        require(depositTokens[_depositToken].aggregatorV3Interface != address(0), "This token cannot be pawned");
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= creditToken.balanceOf(address(this)), "There are not enough funds on the contract");
        require(commissionAmount <= commissionToken.balanceOf(msg.sender), "Commision is more than the balance");
        require(creditData[_term].term == _term, "Term is invalid");
        require(_term != 0, "Term is invalid");

        uint256 _depositAmount = getDepositAmount(_amount, _depositToken);

        require(_depositAmount <= IERC20(_depositToken).balanceOf(msg.sender), "Amount is more than the balance");

        creditor[msg.sender] = CreditorData(
            _depositToken,
            _depositAmount,
            uint32(block.timestamp.add(monthTimeStemp)),
            _term,
            0,
            _amount,
            _amount.mul(creditData[_term].loanRate).div(creditData[_term].loanRateDiv).div(12)
        );

        withdrawData[uint32(block.timestamp.div(dayTimeStemp).add(46))][_depositToken] += _depositAmount;

        IERC20(_depositToken).transferFrom(msg.sender, address(this), _depositAmount);
        commissionToken.transferFrom(msg.sender, address(this), commissionAmount);
        creditToken.transfer(msg.sender, _amount);
    }

    function creditBNB(uint256 _amount, uint8 _term, address _depositToken) public payable {
        require(_amount >= minAmount, "Less than the minimum value");
        if (
        (creditor[msg.sender].paidOut < creditor[msg.sender].amount.add(creditor[msg.sender].interest.mul(creditor[msg.sender].term))) && 
        block.timestamp <= (creditor[msg.sender].nextPaymentTimeStemp + (15 * dayTimeStemp))) {
            require(false, "You already have a loan");
        }

        require(_depositToken == address(0), "To deposit in ERC20 token, you need to call credit()");
        require(depositTokens[_depositToken].aggregatorV3Interface != address(0), "This token cannot be pawned");
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= creditToken.balanceOf(address(this)), "There are not enough funds on the contract");
        require(commissionAmount <= commissionToken.balanceOf(msg.sender), "Commision is more than the balance");
        require(creditData[_term].term == _term, "Term is invalid");
        require(_term != 0, "Term is invalid");

        uint256 _depositAmount = getDepositAmount(_amount, _depositToken);

        require(msg.value == _depositAmount, "Error value");

        creditor[msg.sender] = CreditorData(
            _depositToken,
            _depositAmount,
            uint32(block.timestamp.add(monthTimeStemp)),
            _term,
            0,
            _amount,
            _amount.mul(creditData[_term].loanRate).div(creditData[_term].loanRateDiv).div(12)
        );

        withdrawData[uint32(block.timestamp.div(dayTimeStemp).add(46))][_depositToken] += _depositAmount;

        commissionToken.transferFrom(msg.sender, address(this), commissionAmount);
        creditToken.transfer(msg.sender, _amount);
    }

    function monthly() public {
        require(creditor[msg.sender].amount.add(creditor[msg.sender].interest.mul(creditor[msg.sender].term)) > creditor[msg.sender].paidOut, "You do not have a loan");
        require(block.timestamp <= (creditor[msg.sender].nextPaymentTimeStemp + (15 * dayTimeStemp)), "The loan is overdue");
        require(block.timestamp > (creditor[msg.sender].nextPaymentTimeStemp - monthTimeStemp), "The payment has already been made this month");

        uint256 fee = 0;
        if (block.timestamp > creditor[msg.sender].nextPaymentTimeStemp) {
            fee = latePaymentFee;
        }

        creditToken.transferFrom(
            msg.sender, 
            address(this), 
            creditor[msg.sender].amount
                .div(creditor[msg.sender].term)
                .add((creditor[msg.sender].interest.add(fee)).div(2))
            );

        creditToken.transferFrom(
            msg.sender, 
            stakingAddress, 
            creditor[msg.sender].interest.add(fee).div(2)
        );

        creditor[msg.sender].paidOut += creditor[msg.sender].amount.div(creditor[msg.sender].term).add(creditor[msg.sender].interest);

        withdrawData
            [uint32(uint256(creditor[msg.sender].nextPaymentTimeStemp).div(dayTimeStemp).add(16))]
            [creditor[msg.sender].depositTokenAddress] -= creditor[msg.sender].depositAmount;

        if (creditor[msg.sender].paidOut < creditor[msg.sender].amount.add(creditor[msg.sender].interest.mul(creditor[msg.sender].term))) {
            withdrawData
                [uint32(uint256(creditor[msg.sender].nextPaymentTimeStemp).div(dayTimeStemp).add(46))]
                [creditor[msg.sender].depositTokenAddress] += creditor[msg.sender].depositAmount;
            creditor[msg.sender].nextPaymentTimeStemp += monthTimeStemp;
        } else {
            if (creditor[msg.sender].depositTokenAddress != address(0)) {
                IERC20(creditor[msg.sender].depositTokenAddress).transfer(msg.sender, creditor[msg.sender].depositAmount);
            } else {
                (bool success, ) = msg.sender.call{value: creditor[msg.sender].depositAmount}("");
                require(success, "Failed to send Ether");
            }

        }
    }

    function earlyRepayment() public {
        require(creditor[msg.sender].amount.add(creditor[msg.sender].interest.mul(creditor[msg.sender].term)) > creditor[msg.sender].paidOut, "You do not have a loan");
        require(block.timestamp <= (creditor[msg.sender].nextPaymentTimeStemp + (15 * dayTimeStemp)), "The loan is overdue");

        uint8 monthsLeft = creditor[msg.sender].term - uint8(creditor[msg.sender].paidOut.div(creditor[msg.sender].amount.div(creditor[msg.sender].term).add(creditor[msg.sender].interest)));
        uint256 amount = creditor[msg.sender].amount.mul(monthsLeft).div(creditor[msg.sender].term);

        uint256 fee = 0;

        if (monthsLeft>1||(monthsLeft==1&&block.timestamp<creditor[msg.sender].nextPaymentTimeStemp-(30 *dayTimeStemp))) {
            fee = earlyRepaymentFee;
        }
        if (block.timestamp > creditor[msg.sender].nextPaymentTimeStemp) {
            fee += latePaymentFee;
        }

        creditToken.transferFrom(
            msg.sender, 
            address(this), 
            amount
                .add((creditor[msg.sender].interest.add(fee)).div(2))
        );
        
        creditToken.transferFrom(
            msg.sender, 
            stakingAddress, 
            creditor[msg.sender].interest.add(fee).div(2)
        );

        withdrawData
            [uint32(uint256(creditor[msg.sender].nextPaymentTimeStemp).div(dayTimeStemp).add(16))]
            [creditor[msg.sender].depositTokenAddress] -= creditor[msg.sender].depositAmount;

        creditor[msg.sender].paidOut = creditor[msg.sender].amount.add(creditor[msg.sender].interest.mul(creditor[msg.sender].term));

        if (creditor[msg.sender].depositTokenAddress != address(0)) {
            IERC20(creditor[msg.sender].depositTokenAddress).transfer(msg.sender, creditor[msg.sender].depositAmount);
        } else {
            (bool success, ) = msg.sender.call{value: creditor[msg.sender].depositAmount}("");
            require(success, "Failed to send Ether");
        }
    }

    function getDepositAmount(uint256 _amount, address _depositToken) public view returns(uint256) {
        if (depositTokens[_depositToken].decimals <= decimals) {
            return _amount
                .mul(depositTokens[_depositToken].depositRateDiv)
                .mul(10**AggregatorV3Interface(depositTokens[_depositToken].aggregatorV3Interface).decimals())
                .div(depositTokens[_depositToken].depositRate)
                .div(uint256(AggregatorV3Interface(depositTokens[_depositToken].aggregatorV3Interface).latestAnswer()))
                .div(10**(decimals - depositTokens[_depositToken].decimals));
        } else {
            return _amount
                .mul(depositTokens[_depositToken].depositRateDiv)
                .mul(10**AggregatorV3Interface(depositTokens[_depositToken].aggregatorV3Interface).decimals())
                .div(depositTokens[_depositToken].depositRate)
                .div(10**(depositTokens[_depositToken].decimals - decimals))
                .div(uint256(AggregatorV3Interface(depositTokens[_depositToken].aggregatorV3Interface).latestAnswer()));
        }
    }


    // owner

    function withdraw(address _depositToken, uint256 _amount) public onlyOwner {
        if (_depositToken == address(commissionToken)) {
            commissionToken.transfer(msg.sender, commissionToken.balanceOf(address(this)));
        } else if (_depositToken == address(creditToken)) {
            creditToken.transfer(msg.sender, _amount);
        } else {

            (uint256 amount, uint256 _newLastDay) = getWithdrawAmount(_depositToken);

            if (amount > 0) {
                if (_depositToken == address(0)) {
                    (bool success, ) = msg.sender.call{value: amount}("");
                    require(success, "Failed to send Ether");
                } else {
                    require(amount <= IERC20(_depositToken).balanceOf(address(this)), "Amount is more than the balance");
                    IERC20(_depositToken).transfer(msg.sender, amount);
                }
            }
            depositTokens[_depositToken].lastWithdrawDay = uint32(_newLastDay.add(1));
        }
    }

    function getWithdrawAmount(address _depositToken) public view onlyOwner returns(uint256, uint256) {
        uint256 _amount;
        uint256 _newLastDay = block.timestamp.div(dayTimeStemp);
        for (uint32 _i = depositTokens[_depositToken].lastWithdrawDay; _i <= _newLastDay; _i++) {
            _amount += withdrawData[_i][_depositToken];
        }
        return (_amount, _newLastDay);
    }

    function setCommissionAmount(uint256 _commissionAmount) public onlyOwner {
        commissionAmount = _commissionAmount;
    }

    function setDepositTokens(
        address _tokenAddress, 
        uint256 _depositRate, 
        uint256 _depositRateDiv, 
        address _aggregatorV3Interface, 
        uint8 _decimals
    ) public onlyOwner {
        depositTokens[_tokenAddress] = DepositData(
            _depositRate,
            _depositRateDiv,
            _aggregatorV3Interface,
            _decimals,
            depositTokens[_tokenAddress].lastWithdrawDay
        );
    }

    function setCreditData(uint8 _termId, uint24 _loanRate, uint24 _loanRateDiv, uint8 _term) public onlyOwner {
        creditData[_termId] = CreditData(
            _loanRate,
            _loanRateDiv,
            _term
        );
    }

    function setStakingAddress(address _stakingAddress) public onlyOwner {
        stakingAddress = _stakingAddress;
    }

    function setMinAmount(uint256 _minAmount) public onlyOwner {
        minAmount = _minAmount;
    }
}